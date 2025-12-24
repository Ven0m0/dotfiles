#!/usr/bin/env python3
"""
Unified Video/Audio Converter - Merge of av1.py, bulk_handbrake.py, robust_convert.py, formtool.

Backends: ffmpeg (primary), ffzap (wrapper), HandBrakeCLI (optional)
Formats: av1, x264, mp3, opus, flac, wav
Features: batch, recursive, retry, deinterlace, grain synthesis, size reporting

Usage:
    vidconv av1 *.mp4                    # Compress to AV1
    vidconv x264 --crf 20 video.mkv      # H.264 with custom CRF
    vidconv flac **/*.wav --delete       # Convert WAV to FLAC, remove originals
    vidconv av1 -r /source -o /dest      # Recursive directory mode
    vidconv av1 --backend handbrake ...  # Use HandBrakeCLI
"""
from __future__ import annotations
import argparse
import os
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Final, TypeAlias

# ─────────────────────────────────────────────────────────────────────────────
# Constants & Types
# ─────────────────────────────────────────────────────────────────────────────

PathList: TypeAlias = list[Path]

VIDEO_EXTS: Final[frozenset[str]] = frozenset({
    '.mp4', '.mkv', '.m4v', '.avi', '.mov', '.ts', '.flv', '.wmv', '.webm'
})
AUDIO_EXTS: Final[frozenset[str]] = frozenset({
    '.wav', '.flac', '.mp3', '.ogg', '.opus', '.m4a', '.aac', '.wma'
})
ALL_EXTS: Final[frozenset[str]] = VIDEO_EXTS | AUDIO_EXTS

# ANSI colors (no tput fork)
C_RED: Final[str] = '\033[31m'
C_GREEN: Final[str] = '\033[32m'
C_YELLOW: Final[str] = '\033[33m'
C_BLUE: Final[str] = '\033[34m'
C_CYAN: Final[str] = '\033[36m'
C_RESET: Final[str] = '\033[0m'
C_BOLD: Final[str] = '\033[1m'

# ─────────────────────────────────────────────────────────────────────────────
# Format Presets
# ─────────────────────────────────────────────────────────────────────────────

@dataclass(frozen=True, slots=True)
class FormatPreset:
    """Encoding preset configuration."""
    name: str
    suffix: str
    params: tuple[tuple[str, str | None], ...]
    is_video: bool = True
    container: str = 'mkv'

PRESETS: Final[dict[str, FormatPreset]] = {
    'av1': FormatPreset(
        name='av1',
        suffix='.av1-crf{crf}',
        params=(
            ('-c:v', 'libsvtav1'),
            ('-crf', '{crf}'),
            ('-preset', '{preset}'),
            ('-svtav1-params', 'tune=0:film-grain={grain}:enable-qm=1:qm-min=0:scd=1'),
            ('-c:a', 'libopus'),
            ('-b:a', '{audio_bitrate}'),
            ('-vbr', 'on'),
        ),
        container='mp4',
    ),
    'x264': FormatPreset(
        name='x264',
        suffix='.x264-crf{crf}',
        params=(
            ('-c:v', 'libx264'),
            ('-crf', '{crf}'),
            ('-preset', '{preset}'),
            ('-c:a', 'aac'),
            ('-b:a', '{audio_bitrate}'),
        ),
        container='mp4',
    ),
    'mp3': FormatPreset(
        name='mp3',
        suffix='.v{quality}',
        params=(
            ('-c:a', 'libmp3lame'),
            ('-q:a', '{quality}'),
        ),
        is_video=False,
        container='mp3',
    ),
    'opus': FormatPreset(
        name='opus',
        suffix='.{audio_bitrate}',
        params=(
            ('-c:a', 'libopus'),
            ('-b:a', '{audio_bitrate}'),
            ('-vbr', 'on'),
        ),
        is_video=False,
        container='opus',
    ),
    'flac': FormatPreset(
        name='flac',
        suffix='',
        params=(
            ('-c:a', 'flac'),
            ('-compression_level', '8'),
        ),
        is_video=False,
        container='flac',
    ),
    'wav': FormatPreset(
        name='wav',
        suffix='',
        params=(
            ('-c:a', 'pcm_s16le'),
        ),
        is_video=False,
        container='wav',
    ),
}

@dataclass(slots=True)
class EncodingConfig:
    """Runtime encoding configuration."""
    crf: int = 28
    preset: int = 6
    grain: int = 15
    audio_bitrate: str = '128k'
    quality: int = 0  # For MP3 VBR
    deinterlace: bool = False
    extra_params: list[str] = field(default_factory=list)

# ─────────────────────────────────────────────────────────────────────────────
# Logging Utilities
# ─────────────────────────────────────────────────────────────────────────────

class Logger:
    """Simple logger with color support."""

    def __init__(self, quiet: bool = False, silent: bool = False) -> None:
        self.quiet = quiet or silent
        self.silent = silent
        self._use_color = sys.stdout.isatty()

    def _fmt(self, color: str, msg: str) -> str:
        if self._use_color:
            return f"{color}{msg}{C_RESET}"
        return msg

    def info(self, msg: str) -> None:
        if not self.quiet:
            print(self._fmt(C_CYAN, msg))

    def success(self, msg: str) -> None:
        if not self.quiet:
            print(self._fmt(C_GREEN, f"✓ {msg}"))

    def warn(self, msg: str) -> None:
        if not self.silent:
            print(self._fmt(C_YELLOW, f"⚠ {msg}"), file=sys.stderr)

    def error(self, msg: str) -> None:
        print(self._fmt(C_RED, f"✗ {msg}"), file=sys.stderr)

    def progress(self, current: int, total: int, filename: str) -> None:
        if not self.quiet:
            pct = (current / total) * 100 if total else 0
            bar_len = 20
            filled = int(bar_len * current / total) if total else 0
            bar = '█' * filled + '░' * (bar_len - filled)
            print(f"\r{C_BLUE}[{bar}] {pct:5.1f}% ({current}/{total}) {filename[:40]:<40}{C_RESET}", end='', flush=True)

    def progress_done(self) -> None:
        if not self.quiet:
            print()


# ─────────────────────────────────────────────────────────────────────────────
# Tool Detection
# ─────────────────────────────────────────────────────────────────────────────

def has_cmd(name: str) -> bool:
    """Check if command exists (cached)."""
    return shutil.which(name) is not None


def check_required_tools(backend: str) -> list[str]:
    """Verify required tools are installed. Returns missing tools."""
    missing: list[str] = []

    if backend == 'handbrake':
        if not has_cmd('HandBrakeCLI'):
            missing.append('HandBrakeCLI')
    else:  # ffmpeg/ffzap
        if not has_cmd('ffmpeg'):
            missing.append('ffmpeg')

    return missing


# ─────────────────────────────────────────────────────────────────────────────
# File Discovery
# ─────────────────────────────────────────────────────────────────────────────

def find_files_glob(patterns: list[str], extensions: frozenset[str]) -> PathList:
    """Expand glob patterns to file list."""
    import glob
    files: PathList = []
    for pattern in patterns:
        expanded = Path(pattern).expanduser()
        for p in glob.glob(str(expanded), recursive=True):
            path = Path(p)
            if path.is_file() and path.suffix.lower() in extensions:
                files.append(path)
    return files


def find_files_recursive(source_dir: Path, extensions: frozenset[str]) -> PathList:
    """Recursively find media files using fd or os.walk fallback."""
    files: PathList = []

    # Try fd first (faster)
    if has_cmd('fd'):
        cmd = ['fd', '--type', 'f']
        for ext in extensions:
            cmd.extend(['-e', ext.lstrip('.')])
        cmd.extend(['.', str(source_dir)])

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            for line in result.stdout.strip().split('\n'):
                if line:
                    files.append(Path(line))
            return files
        except subprocess.CalledProcessError:
            pass  # Fall through to os.walk

    # Fallback: os.walk
    for root, _, filenames in os.walk(source_dir):
        for fname in filenames:
            path = Path(root) / fname
            if path.suffix.lower() in extensions:
                files.append(path)

    return files


# ─────────────────────────────────────────────────────────────────────────────
# FFmpeg Backend
# ─────────────────────────────────────────────────────────────────────────────

def build_ffmpeg_params(
    preset: FormatPreset,
    config: EncodingConfig,
) -> list[str]:
    """Build ffmpeg parameter list from preset and config."""
    params: list[str] = []

    # Deinterlace filter (video only)
    if config.deinterlace and preset.is_video:
        params.extend(['-vf', 'bwdif'])

    # Format parameters with config values
    fmt_map = {
        'crf': str(config.crf),
        'preset': str(config.preset),
        'grain': str(config.grain),
        'audio_bitrate': config.audio_bitrate,
        'quality': str(config.quality),
    }

    for key, val in preset.params:
        params.append(key)
        if val is not None:
            formatted = val.format(**fmt_map)
            params.append(formatted)

    # Extra passthrough params
    params.extend(config.extra_params)

    return params


def run_ffmpeg(
    input_path: Path,
    output_path: Path,
    params: list[str],
    quiet: bool = False,
    use_ffzap: bool = False,
) -> bool:
    """Execute ffmpeg/ffzap command."""
    if use_ffzap and has_cmd('ffzap'):
        cmd = ['ffzap', '-i', str(input_path), '-o', str(output_path)] + params
    else:
        cmd = [
            'ffmpeg', '-y', '-hide_banner',
            '-loglevel', 'error' if quiet else 'warning',
            '-i', str(input_path),
        ] + params + [str(output_path)]

    try:
        if quiet:
            subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        else:
            subprocess.run(cmd, check=True)
        return True
    except subprocess.CalledProcessError:
        return False


def convert_ffmpeg(
    input_path: Path,
    output_path: Path,
    preset: FormatPreset,
    config: EncodingConfig,
    log: Logger,
    retries: int = 3,
) -> bool:
    """Convert file with ffmpeg, retry on failure."""
    params = build_ffmpeg_params(preset, config)

    for attempt in range(1, retries + 1):
        # Try ffzap on first attempt
        use_ffzap = attempt == 1 and has_cmd('ffzap')
        tool = 'ffzap' if use_ffzap else 'ffmpeg'

        log.info(f"  [{attempt}/{retries}] Encoding via {tool}...")
        start = time.perf_counter()

        if run_ffmpeg(input_path, output_path, params, log.quiet, use_ffzap):
            elapsed = time.perf_counter() - start
            log.success(f"  Done ({elapsed:.1f}s)")
            return True

        log.warn(f"  Attempt {attempt} failed")
        if attempt < retries:
            time.sleep(2)

    return False


# ─────────────────────────────────────────────────────────────────────────────
# HandBrake Backend
# ─────────────────────────────────────────────────────────────────────────────

def convert_handbrake(
    input_path: Path,
    output_path: Path,
    preset_file: Path | None,
    preset_name: str,
    log: Logger,
) -> bool:
    """Convert using HandBrakeCLI."""
    cmd = ['HandBrakeCLI']

    if preset_file and preset_file.exists():
        cmd.extend(['--preset-import-file', str(preset_file), '-Z', preset_name])
    else:
        # Use built-in preset
        cmd.extend(['-Z', preset_name])

    cmd.extend(['-i', str(input_path), '-o', str(output_path)])

    try:
        subprocess.run(
            cmd,
            check=True,
            stdout=subprocess.DEVNULL if log.quiet else None,
            stderr=subprocess.PIPE,
        )
        return True
    except subprocess.CalledProcessError:
        return False


# ─────────────────────────────────────────────────────────────────────────────
# Output Path Generation
# ─────────────────────────────────────────────────────────────────────────────

def generate_output_path(
    input_path: Path,
    preset: FormatPreset,
    config: EncodingConfig,
    output_dir: Path | None = None,
    source_root: Path | None = None,
) -> Path:
    """Generate output path with format suffix."""
    # Build suffix with config values
    fmt_map = {
        'crf': str(config.crf),
        'preset': str(config.preset),
        'grain': str(config.grain),
        'audio_bitrate': config.audio_bitrate,
        'quality': str(config.quality),
    }
    suffix = preset.suffix.format(**fmt_map)

    # Sanitize suffix
    suffix = ''.join(c for c in suffix if c.isalnum() or c in '._-+')

    new_name = f"{input_path.stem}{suffix}.{preset.container}"

    if output_dir:
        # Preserve directory structure relative to source_root
        if source_root:
            rel = input_path.parent.relative_to(source_root)
            target_dir = output_dir / rel
        else:
            target_dir = output_dir
        target_dir.mkdir(parents=True, exist_ok=True)
        return target_dir / new_name

    return input_path.with_name(new_name)


# ─────────────────────────────────────────────────────────────────────────────
# Main Conversion Logic
# ─────────────────────────────────────────────────────────────────────────────

@dataclass(slots=True)
class ConversionStats:
    """Track conversion statistics."""
    processed: int = 0
    skipped: int = 0
    failed: int = 0
    total_input_bytes: int = 0
    total_output_bytes: int = 0
    failures: list[str] = field(default_factory=list)


def process_file(
    input_path: Path,
    output_path: Path,
    preset: FormatPreset,
    config: EncodingConfig,
    backend: str,
    log: Logger,
    delete_original: bool,
    handbrake_preset_file: Path | None,
    handbrake_preset_name: str,
) -> tuple[bool, int, int]:
    """
    Process single file. Returns (success, input_size, output_size).
    """
    input_size = input_path.stat().st_size

    # Skip if output already has target suffix
    if output_path.name == input_path.name or input_path.name.endswith(f".{preset.container}"):
        stem_check = f"{input_path.stem}."
        if output_path.stem.startswith(stem_check[:-1]) and output_path.suffix == f".{preset.container}":
            pass  # Proceed

    log.info(f"  {input_path.name} → {output_path.name}")

    # Convert
    if backend == 'handbrake':
        success = convert_handbrake(
            input_path, output_path,
            handbrake_preset_file, handbrake_preset_name, log
        )
    else:
        success = convert_ffmpeg(input_path, output_path, preset, config, log)

    if not success:
        # Cleanup partial output
        if output_path.exists():
            output_path.unlink()
        return False, input_size, 0

    output_size = output_path.stat().st_size
    ratio = output_size / input_size if input_size else 0

    log.info(f"  Size: {input_size / 1_000_000:.2f}MB → {output_size / 1_000_000:.2f}MB ({ratio:.1%})")

    # Delete original if requested and output is smaller
    if delete_original:
        if output_size < input_size:
            input_path.unlink()
            log.success(f"  Removed original")
        else:
            log.warn(f"  Output larger than input, keeping original")

    return True, input_size, output_size


def run_conversion(
    files: PathList,
    preset: FormatPreset,
    config: EncodingConfig,
    backend: str,
    log: Logger,
    output_dir: Path | None,
    source_root: Path | None,
    delete_original: bool,
    handbrake_preset_file: Path | None,
    handbrake_preset_name: str,
) -> ConversionStats:
    """Run batch conversion."""
    stats = ConversionStats()
    total = len(files)

    log.info(f"Processing {total} files...")
    log.info(f"Backend: {backend}, Format: {preset.name}, CRF: {config.crf}, Preset: {config.preset}")
    if config.deinterlace:
        log.info("Deinterlace: enabled")
    print()

    for i, input_path in enumerate(files, 1):
        log.progress(i, total, input_path.name)
        print()

        output_path = generate_output_path(input_path, preset, config, output_dir, source_root)

        # Skip existing
        if output_path.exists():
            log.warn(f"  Skipping (exists): {output_path.name}")
            stats.skipped += 1
            continue

        # Skip if input == output
        if input_path == output_path:
            log.warn(f"  Skipping (same file): {input_path.name}")
            stats.skipped += 1
            continue

        success, in_size, out_size = process_file(
            input_path, output_path, preset, config, backend, log,
            delete_original, handbrake_preset_file, handbrake_preset_name
        )

        if success:
            stats.processed += 1
            stats.total_input_bytes += in_size
            stats.total_output_bytes += out_size
        else:
            stats.failed += 1
            stats.failures.append(str(input_path))
            log.error(f"  Failed: {input_path.name}")

        print()

    log.progress_done()
    return stats


def print_summary(stats: ConversionStats, log: Logger) -> None:
    """Print conversion summary."""
    print()
    log.info("═" * 50)
    log.info(f"Processed: {stats.processed}, Skipped: {stats.skipped}, Failed: {stats.failed}")

    if stats.total_input_bytes:
        ratio = stats.total_output_bytes / stats.total_input_bytes
        saved = stats.total_input_bytes - stats.total_output_bytes
        log.info(
            f"Total: {stats.total_input_bytes / 1_000_000:.2f}MB → "
            f"{stats.total_output_bytes / 1_000_000:.2f}MB ({ratio:.1%})"
        )
        if saved > 0:
            log.success(f"Saved: {saved / 1_000_000:.2f}MB")

    if stats.failures:
        log.error("Failures:")
        for f in stats.failures:
            log.error(f"  - {f}")

    log.info("═" * 50)


# ─────────────────────────────────────────────────────────────────────────────
# CLI
# ─────────────────────────────────────────────────────────────────────────────

def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        prog='vidconv',
        description='Unified Video/Audio Converter',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  vidconv av1 *.mp4                      # Compress videos to AV1
  vidconv x264 --crf 20 video.mkv        # H.264 with custom CRF
  vidconv flac **/*.wav --delete         # WAV→FLAC, remove originals
  vidconv av1 -r /src -o /dst            # Recursive directory mode
  vidconv av1 --backend handbrake ...    # Use HandBrakeCLI
""",
    )

    # Format selection
    parser.add_argument(
        'format',
        choices=list(PRESETS.keys()),
        help='Output format preset',
    )

    # Input files/directory
    parser.add_argument(
        'files',
        nargs='*',
        help='Input files (glob patterns supported)',
    )

    # Directory mode
    parser.add_argument(
        '-r', '--recursive',
        type=Path,
        metavar='DIR',
        help='Recursively process directory',
    )
    parser.add_argument(
        '-o', '--output',
        type=Path,
        metavar='DIR',
        help='Output directory (required with -r)',
    )

    # Backend
    parser.add_argument(
        '--backend',
        choices=['ffmpeg', 'handbrake'],
        default='ffmpeg',
        help='Encoding backend (default: ffmpeg)',
    )

    # Encoding options
    parser.add_argument('--crf', type=int, default=28, help='Video CRF (default: 28)')
    parser.add_argument('--preset', type=int, default=6, help='Encoder preset (default: 6)')
    parser.add_argument('--grain', type=int, default=15, help='Film grain synthesis 0-50 (default: 15)')
    parser.add_argument('--audio-bitrate', default='128k', help='Audio bitrate (default: 128k)')
    parser.add_argument('--quality', type=int, default=0, help='MP3 VBR quality 0-9 (default: 0)')
    parser.add_argument('--deinterlace', action='store_true', help='Apply deinterlace filter')

    # HandBrake options
    parser.add_argument(
        '--hb-preset-file',
        type=Path,
        default=Path.home() / '.config/ghb/main.json',
        help='HandBrake preset JSON file',
    )
    parser.add_argument(
        '--hb-preset-name',
        default='main',
        help='HandBrake preset name (default: main)',
    )

    # Behavior
    parser.add_argument('--delete', action='store_true', help='Delete original after successful conversion')
    parser.add_argument('--quiet', action='store_true', help='Suppress progress output')
    parser.add_argument('--silent', action='store_true', help='Suppress all output except errors')

    return parser.parse_known_args()


def main() -> int:
    """Main entry point."""
    args, extra = parse_args()
    log = Logger(args.quiet, args.silent)

    # Validate inputs
    if args.recursive and args.files:
        log.error("Cannot use both --recursive and file arguments")
        return 1

    if not args.recursive and not args.files:
        log.error("Provide files or use --recursive")
        return 1

    if args.recursive and not args.output:
        log.error("--output required with --recursive")
        return 1

    # Check tools
    missing = check_required_tools(args.backend)
    if missing:
        log.error(f"Missing tools: {', '.join(missing)}")
        return 1

    # Get preset and config
    preset = PRESETS[args.format]
    config = EncodingConfig(
        crf=args.crf,
        preset=args.preset,
        grain=args.grain,
        audio_bitrate=args.audio_bitrate,
        quality=args.quality,
        deinterlace=args.deinterlace,
        extra_params=extra,
    )

    # Determine extensions to search
    extensions = VIDEO_EXTS if preset.is_video else AUDIO_EXTS

    # Find files
    if args.recursive:
        source_root = args.recursive.resolve()
        if not source_root.exists():
            log.error(f"Source directory does not exist: {source_root}")
            return 1
        files = find_files_recursive(source_root, extensions)
    else:
        source_root = None
        files = find_files_glob(args.files, extensions)

    if not files:
        log.warn("No files found")
        return 0

    # Run conversion
    stats = run_conversion(
        files=files,
        preset=preset,
        config=config,
        backend=args.backend,
        log=log,
        output_dir=args.output,
        source_root=source_root,
        delete_original=args.delete,
        handbrake_preset_file=args.hb_preset_file,
        handbrake_preset_name=args.hb_preset_name,
    )

    print_summary(stats, log)
    return 1 if stats.failed else 0


if __name__ == '__main__':
    sys.exit(main())
