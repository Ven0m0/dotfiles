#!/usr/bin/env python3
"""Unified video/audio converter with SVT-AV1, VP9, H.265, x264 support."""
import argparse
import os
import shutil
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass, field
from pathlib import Path
from typing import Final

# TODO: implement features of https://github.com/hykilpikonna/formtool

# ─── Constants ───
VIDEO_EXTS: Final = frozenset({'.mp4','.mkv','.m4v','.avi','.mov','.ts','.flv','.wmv','.webm'})
AUDIO_EXTS: Final = frozenset({'.mp3','.ogg','.opus','.m4a','.aac','.wma'})
PASSTHROUGH_EXTS: Final = frozenset({'.wav','.flac'})
C_RED: Final = '\033[31m'
C_GREEN: Final = '\033[32m'
C_YELLOW: Final = '\033[33m'
C_CYAN: Final = '\033[36m'
C_RESET: Final = '\033[0m'

@dataclass(frozen=True, slots=True)
class Preset:
  name: str
  suffix: str
  params: tuple[tuple[str, str | None], ...]
  is_video: bool = True
  ext: str = 'mkv'

PRESETS: Final = {
  'av1': Preset('av1', '.av1-crf{crf}', (
    ('-c:v','libsvtav1'), ('-crf','{crf}'), ('-preset','{preset}'), ('-g','{keyint}'),
    ('-pix_fmt','{pix_fmt}'),
    ('-svtav1-params','tune=0:film-grain={grain}:enable-qm=1:qm-min=0:enable-variance-boost=1:tf-strength=1:sharpness=-2:tile-columns=1:tile-rows=0:enable-dlf=2:scd=1{fast_decode}'),
    ('-c:a','libopus'), ('-b:a','{audio_bitrate}'), ('-ac','{audio_channels}'),
    ('-rematrix_maxval','1.0'), ('-vbr','on'), ('-map_metadata','0'), ('-sn',None),
  ), ext='mkv'),
  'vp9': Preset('vp9', '.vp9-crf{crf}', (
    ('-c:v','libvpx-vp9'), ('-crf','{crf}'), ('-b:v','0'),
    ('-cpu-used','{preset}'), ('-row-mt','1'), ('-g','{keyint}'),
    ('-pix_fmt','{pix_fmt}'),
    ('-c:a','libopus'), ('-b:a','{audio_bitrate}'), ('-ac','{audio_channels}'),
    ('-rematrix_maxval','1.0'), ('-vbr','on'), ('-map_metadata','0'), ('-sn',None),
  ), ext='webm'),
  'h265': Preset('h265', '.h265-crf{crf}', (
    ('-c:v','libx265'), ('-crf','{crf}'), ('-preset','{preset_name}'),
    ('-x265-params','log-level=error'),
    ('-pix_fmt','{pix_fmt}'),
    ('-c:a','libopus'), ('-b:a','{audio_bitrate}'), ('-ac','{audio_channels}'),
    ('-rematrix_maxval','1.0'), ('-vbr','on'), ('-map_metadata','0'), ('-sn',None),
  ), ext='mkv'),
  'x264': Preset('x264', '.x264-crf{crf}', (
    ('-c:v','libx264'), ('-crf','{crf}'), ('-preset','{preset_name}'),
    ('-c:a','aac'), ('-b:a','{audio_bitrate}'),
    ('-map_metadata','0'), ('-sn',None),
  ), ext='mp4'),
  'opus': Preset('opus', '.{audio_bitrate}', (
    ('-c:a','libopus'), ('-b:a','{audio_bitrate}'), ('-vbr','on'),
  ), False, 'opus'),
}

@dataclass(slots=True)
class Config:
  crf: int = 26
  preset: int = 3
  preset_name: str = 'slow'
  grain: int = 6
  audio_bitrate: str = '128k'
  audio_channels: int = 2
  max_dim: tuple[int, int] = (1920, 1080)
  pix_fmt: str = 'yuv420p10le'
  keyint: int = 600
  fast_decode: bool = False
  default_denoise: bool = True
  default_deband: bool = True
  deinterlace: str | None = None
  denoise: str | None = None
  denoise_strength: str = 'light'
  deblock: str | None = None
  rotate: int = 0
  crop: str | None = None
  scale: str | None = None
  extra: list[str] = field(default_factory=list)

@dataclass(slots=True)
class Stats:
  processed: int = 0
  skipped: int = 0
  failed: int = 0
  input_bytes: int = 0
  output_bytes: int = 0
  failures: list[str] = field(default_factory=list)

class Log:
  def __init__(self, quiet: bool = False, silent: bool = False) -> None:
    self.quiet = quiet or silent
    self.silent = silent
    self.color = sys.stdout.isatty()
  def _c(self, col: str, msg: str) -> str:
    return f"{col}{msg}{C_RESET}" if self.color else msg
  def info(self, msg: str) -> None:
    if not self.quiet: print(self._c(C_CYAN, msg))
  def ok(self, msg: str) -> None:
    if not self.quiet: print(self._c(C_GREEN, f"✓ {msg}"))
  def warn(self, msg: str) -> None:
    if not self.silent: print(self._c(C_YELLOW, f"⚠ {msg}"), file=sys.stderr)
  def err(self, msg: str) -> None:
    print(self._c(C_RED, f"✗ {msg}"), file=sys.stderr)
  def prog(self, cur: int, tot: int, fname: str) -> None:
    if not self.quiet:
      pct = (cur/tot)*100 if tot else 0
      bar = '█'*int(20*cur/tot) + '░'*(20-int(20*cur/tot)) if tot else '░'*20
      print(f"\r[{bar}] {pct:5.1f}% ({cur}/{tot}) {fname[:40]:<40}", end='', flush=True)
  def prog_done(self) -> None:
    if not self.quiet: print()

def has(cmd: str) -> bool:
  return shutil.which(cmd) is not None

def find_files_fd(root: Path, exts: frozenset[str]) -> list[Path]:
  if not has('fd'): return []
  cmd = ['fd', '--type', 'f'] + [x for e in exts for x in ['-e', e.lstrip('.')]] + ['.', str(root)]
  try:
    out = subprocess.run(cmd, capture_output=True, text=True, check=True).stdout
    return [Path(p) for p in out.strip().split('\n') if p]
  except subprocess.CalledProcessError:
    return []

def find_files_walk(root: Path, exts: frozenset[str]) -> list[Path]:
  files: list[Path] = []
  for r, _, fnames in os.walk(root):
    for f in fnames:
      if os.path.splitext(f)[1].lower() in exts:
        files.append(Path(r) / f)
  return files

def find_files(root: Path, exts: frozenset[str]) -> list[Path]:
  return find_files_fd(root, exts) or find_files_walk(root, exts)

def build_filters(cfg: Config, is_video: bool) -> list[str]:
  if not is_video: return []
  filters: list[str] = []
  if cfg.deinterlace and cfg.deinterlace != 'off':
    m = {'bwdif':'bwdif=mode=send_frame:parity=auto:deint=all',
         'yadif':'yadif=mode=send_frame:parity=auto:deint=all',
         'decomb':'yadif=mode=send_field:parity=auto'}
    if cfg.deinterlace in m: filters.append(m[cfg.deinterlace])
  if cfg.default_denoise or (cfg.denoise and cfg.denoise != 'off'):
    if cfg.denoise == 'nlmeans':
      h = {'ultralight':2,'light':4,'medium':6,'strong':8}.get(cfg.denoise_strength, 4)
      filters.append(f'nlmeans=h={h}')
    elif cfg.denoise == 'hqdn3d':
      h = {'ultralight':2,'light':4,'medium':6,'strong':8}.get(cfg.denoise_strength, 4)
      filters.append(f'hqdn3d={h}')
    else:
      filters.append('hqdn3d=1.5:1.5:6:6')
  if cfg.deblock and cfg.deblock != 'off': filters.append(f'deblock={cfg.deblock}')
  if cfg.rotate:
    rm = {90:'transpose=1', 180:'transpose=1,transpose=1', 270:'transpose=2'}
    if cfg.rotate in rm: filters.append(rm[cfg.rotate])
  if cfg.crop and cfg.crop != 'off':
    filters.append('cropdetect=24:16:0' if cfg.crop == 'auto' else f'crop={cfg.crop}')
  if cfg.scale:
    filters.append(f'scale={cfg.scale}:flags=lanczos')
  elif cfg.max_dim:
    w, h = cfg.max_dim
    filters.append(f"scale='if(gte(iw,ih),min({w},iw),-2)':'if(gte(iw,ih),-2,min({h},ih))':flags=lanczos")
  if cfg.default_deband: filters.append('deband')
  filters.append(f'format={cfg.pix_fmt}')
  return filters

def build_params(preset: Preset, cfg: Config) -> list[str]:
  filters = build_filters(cfg, preset.is_video)
  params = ['-vf', ','.join(filters)] if filters else []
  fmt = {
    'crf': str(cfg.crf), 'preset': str(cfg.preset), 'preset_name': cfg.preset_name,
    'grain': str(cfg.grain), 'audio_bitrate': cfg.audio_bitrate,
    'keyint': str(cfg.keyint), 'pix_fmt': cfg.pix_fmt, 'audio_channels': str(cfg.audio_channels),
    'fast_decode': ':fast-decode=1' if cfg.fast_decode else '',
  }
  for k, v in preset.params:
    params.append(k)
    if v is not None: params.append(v.format(**fmt))
  params.extend(cfg.extra)
  return params

def run_ffmpeg(inp: Path, out: Path, params: list[str], quiet: bool, use_ffzap: bool) -> bool:
  if use_ffzap and has('ffzap'):
    cmd = ['ffzap', '-i', str(inp), '-o', str(out)] + params
  else:
    cmd = ['ffmpeg', '-y', '-hide_banner', '-nostdin',
           '-v', 'fatal', '-loglevel', 'error', '-stats' if not quiet else '-nostats',
           '-i', str(inp)] + params + [str(out)]
  try:
    if quiet:
      subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
      subprocess.run(cmd, check=True)
    return True
  except subprocess.CalledProcessError:
    return False

def convert(inp: Path, out: Path, preset: Preset, cfg: Config, log: Log, retries: int = 3) -> bool:
  params = build_params(preset, cfg)
  for attempt in range(1, retries + 1):
    use_ffzap = attempt == 1 and has('ffzap')
    tool = 'ffzap' if use_ffzap else 'ffmpeg'
    log.info(f"  [{attempt}/{retries}] {tool}...")
    start = time.perf_counter()
    if run_ffmpeg(inp, out, params, log.quiet, use_ffzap):
      log.ok(f"  {time.perf_counter()-start:.1f}s")
      return True
    log.warn(f"  Attempt {attempt} failed")
    if attempt < retries: time.sleep(2)
  return False

def gen_out_path(inp: Path, preset: Preset, cfg: Config, out_dir: Path | None, src_root: Path | None) -> Path:
  fmt = {'crf':str(cfg.crf), 'preset':str(cfg.preset), 'grain':str(cfg.grain),
         'audio_bitrate':cfg.audio_bitrate}
  suffix = ''.join(c for c in preset.suffix.format(**fmt) if c.isalnum() or c in '._-+')
  new_name = f"{inp.stem}{suffix}.{preset.ext}"
  if out_dir:
    if src_root:
      rel = inp.parent.relative_to(src_root)
      target = out_dir / rel
    else:
      target = out_dir
    target.mkdir(parents=True, exist_ok=True)
    return target / new_name
  return inp.with_name(new_name)

def process(inp: Path, out: Path, preset: Preset, cfg: Config, log: Log, delete: bool) -> tuple[bool, int, int]:
  in_sz = inp.stat().st_size
  log.info(f"  {inp.name} → {out.name}")
  if not convert(inp, out, preset, cfg, log):
    if out.exists(): out.unlink()
    return False, in_sz, 0
  out_sz = out.stat().st_size
  ratio = out_sz / in_sz if in_sz else 0
  log.info(f"  {in_sz/1e6:.2f}MB → {out_sz/1e6:.2f}MB ({ratio:.1%})")
  if delete:
    if out_sz < in_sz:
      inp.unlink()
      log.ok("  Removed original")
    else:
      log.warn("  Output larger, kept original")
  return True, in_sz, out_sz

def process_item(inp: Path, preset: Preset, cfg: Config, out_dir: Path | None, src_root: Path | None, delete: bool, log: Log) -> tuple[Stats, str]:
  stats = Stats()
  out = gen_out_path(inp, preset, cfg, out_dir, src_root)
  if out.exists():
    stats.skipped += 1
    return stats, f"Skipped (exists): {out.name}"
  if inp == out:
    stats.skipped += 1
    return stats, f"Skipped (same): {inp.name}"

  # Use quiet log for parallel workers to prevent interleaved output
  ok, in_sz, out_sz = process(inp, out, preset, cfg, log, delete)

  if ok:
    stats.processed += 1
    stats.input_bytes += in_sz
    stats.output_bytes += out_sz
    ratio = out_sz / in_sz if in_sz else 0
    return stats, f"{inp.name} → {out.name}: {in_sz/1e6:.2f}MB → {out_sz/1e6:.2f}MB ({ratio:.1%})"
  else:
    stats.failed += 1
    stats.failures.append(str(inp))
    return stats, f"Failed: {inp.name}"

def run_batch(files: list[Path], preset: Preset, cfg: Config, log: Log,
              out_dir: Path | None, src_root: Path | None, delete: bool, jobs: int) -> Stats:
  stats = Stats()
  total = len(files)
  log.info(f"Processing {total} files")
  log.info(f"Format: {preset.name} (.{preset.ext}), CRF {cfg.crf}, Preset {cfg.preset}, Grain {cfg.grain}")
  if preset.is_video:
    log.info(f"Audio: {cfg.audio_bitrate}, {cfg.audio_channels}ch")
    filters: list[str] = []
    if cfg.max_dim: filters.append(f"max-dim={cfg.max_dim[0]}x{cfg.max_dim[1]}")
    if cfg.default_denoise: filters.append("denoise=hqdn3d:1.5:1.5:6:6")
    if cfg.deinterlace: filters.append(f"deinterlace={cfg.deinterlace}")
    if cfg.denoise: filters.append(f"denoise={cfg.denoise}:{cfg.denoise_strength}")
    if cfg.deblock: filters.append(f"deblock={cfg.deblock}")
    if cfg.default_deband: filters.append("deband")
    if cfg.rotate: filters.append(f"rotate={cfg.rotate}")
    if cfg.crop: filters.append(f"crop={cfg.crop}")
    if cfg.scale: filters.append(f"scale={cfg.scale}")
    if filters: log.info(f"Filters: {', '.join(filters)}")
  if src_root and out_dir:
    log.info(f"Input:  {src_root}")
    log.info(f"Output: {out_dir}")
  print()

  if jobs > 1:
    log.info(f"Parallel execution with {jobs} jobs")
    quiet_log = Log(quiet=True, silent=log.silent)
    try:
      with ThreadPoolExecutor(max_workers=jobs) as executor:
        futures = {executor.submit(process_item, f, preset, cfg, out_dir, src_root, delete, quiet_log): f for f in files}
        for i, future in enumerate(as_completed(futures), 1):
          inp = futures[future]
          try:
            s, msg = future.result()
            stats.processed += s.processed
            stats.skipped += s.skipped
            stats.failed += s.failed
            stats.input_bytes += s.input_bytes
            stats.output_bytes += s.output_bytes
            stats.failures.extend(s.failures)
            log.info(f"[{i}/{total}] {msg}")
          except Exception as e:
            stats.failed += 1
            stats.failures.append(str(inp))
            log.err(f"Error processing {inp.name}: {e}")
    except KeyboardInterrupt:
      log.err("Interrupted")
      sys.exit(130)
    return stats

  for i, inp in enumerate(files, 1):
    log.prog(i, total, inp.name)
    print()
    out = gen_out_path(inp, preset, cfg, out_dir, src_root)
    if out.exists():
      log.warn(f"  Skipping (exists): {out.name}")
      stats.skipped += 1
      continue
    if inp == out:
      log.warn(f"  Skipping (same): {inp.name}")
      stats.skipped += 1
      continue
    ok, in_sz, out_sz = process(inp, out, preset, cfg, log, delete)
    if ok:
      stats.processed += 1
      stats.input_bytes += in_sz
      stats.output_bytes += out_sz
    else:
      stats.failed += 1
      stats.failures.append(str(inp))
      log.err(f"  Failed: {inp.name}")
    print()
  log.prog_done()
  return stats

def print_summary(stats: Stats, log: Log) -> None:
  print()
  log.info("═" * 50)
  log.info(f"Processed: {stats.processed}, Skipped: {stats.skipped}, Failed: {stats.failed}")
  if stats.input_bytes:
    ratio = stats.output_bytes / stats.input_bytes
    saved = stats.input_bytes - stats.output_bytes
    log.info(f"Total: {stats.input_bytes/1e6:.2f}MB → {stats.output_bytes/1e6:.2f}MB ({ratio:.1%})")
    if saved > 0: log.ok(f"Saved: {saved/1e6:.2f}MB")
  if stats.failures:
    log.err("Failures:")
    for f in stats.failures: log.err(f"  - {f}")
  log.info("═" * 50)

def parse_args() -> tuple[argparse.Namespace, list[str]]:
  p = argparse.ArgumentParser(
    prog='vidconv',
    description='Unified video/audio converter (Priority: av1→vp9→h265→x264)',
    formatter_class=argparse.RawDescriptionHelpFormatter,
    epilog="""Examples:
  vidconv av1 *.mp4                      # Compress to AV1 (default: 1080p, denoise, deband)
  vidconv av1 --max-dim 1280 720 *.mp4   # Limit to 720p
  vidconv av1 -i /src -o /dst            # Directory mode, preserve structure
  vidconv av1 --deinterlace bwdif old.avi  # Fix interlaced video
  vidconv opus **/*.mp3 --delete         # MP3→Opus, remove originals
  vidconv vp9 --crf 30 video.mkv         # VP9 with custom CRF
"""
  )
  p.add_argument('format', choices=list(PRESETS.keys()), help='Output format')
  p.add_argument('files', nargs='*', help='Input files (glob patterns)')
  p.add_argument('-i', '--input-dir', type=Path, metavar='DIR', help='Input directory (recursive)')
  p.add_argument('-o', '--output-dir', type=Path, metavar='DIR', help='Output directory')
  p.add_argument('--crf', type=int, default=26, help='Video CRF (default: 26)')
  p.add_argument('--preset', type=int, default=3, help='SVT-AV1/VP9 preset (default: 3)')
  p.add_argument('--preset-name', default='slow', help='x264/x265 preset name (default: slow)')
  p.add_argument('--grain', type=int, default=6, help='Film grain 0-50 (default: 6)')
  p.add_argument('--audio-bitrate', default='128k', help='Audio bitrate (default: 128k)')
  v = p.add_argument_group('video')
  v.add_argument('--max-dim', type=int, nargs=2, metavar=('W','H'), default=[1920,1080], help='Max dimensions (default: 1920 1080)')
  v.add_argument('--pix-fmt', default='yuv420p10le', help='Pixel format (default: yuv420p10le)')
  v.add_argument('--keyint', type=int, default=600, help='Keyframe interval (default: 600)')
  v.add_argument('--fast-decode', action='store_true', help='Enable SVT-AV1 fast-decode')
  v.add_argument('--no-denoise', action='store_true', help='Disable default denoise')
  v.add_argument('--no-deband', action='store_true', help='Disable default deband')
  v.add_argument('--audio-channels', type=int, default=2, help='Audio channels (default: 2)')
  f = p.add_argument_group('filters')
  f.add_argument('--deinterlace', choices=['off','bwdif','yadif','decomb'], help='Deinterlace filter')
  f.add_argument('--denoise', choices=['off','nlmeans','hqdn3d'], help='Custom denoise filter')
  f.add_argument('--denoise-strength', choices=['ultralight','light','medium','strong'], default='light')
  f.add_argument('--deblock', metavar='PARAMS', help='Deblock filter (e.g., "weak")')
  f.add_argument('--rotate', type=int, choices=[0,90,180,270], default=0, help='Rotate degrees')
  f.add_argument('--crop', metavar='W:H:X:Y', help='Crop video (or "auto")')
  f.add_argument('--scale', metavar='WxH', help='Scale video (e.g., "1920x1080")')
  p.add_argument('--delete', action='store_true', help='Delete original after conversion')
  p.add_argument('-j', '--jobs', type=int, default=1, help='Number of parallel jobs (default: 1)')
  p.add_argument('--quiet', action='store_true', help='Suppress progress output')
  p.add_argument('--silent', action='store_true', help='Suppress all output except errors')
  return p.parse_known_args()

def main() -> int:
  args, extra = parse_args()
  log = Log(args.quiet, args.silent)
  if args.input_dir and args.files:
    log.err("Cannot use both --input-dir and file arguments")
    return 1
  if not args.input_dir and not args.files:
    log.err("Provide files or use --input-dir")
    return 1
  if args.input_dir and not args.output_dir:
    log.err("--output-dir required with --input-dir")
    return 1
  if not has('ffmpeg'):
    log.err("Missing: ffmpeg")
    return 1
  preset = PRESETS[args.format]
  cfg = Config(
    crf=args.crf, preset=args.preset, preset_name=args.preset_name, grain=args.grain,
    audio_bitrate=args.audio_bitrate, audio_channels=args.audio_channels,
    max_dim=tuple(args.max_dim), pix_fmt=args.pix_fmt, keyint=args.keyint,
    fast_decode=args.fast_decode,
    default_denoise=not args.no_denoise, default_deband=not args.no_deband,
    deinterlace=args.deinterlace, denoise=args.denoise, denoise_strength=args.denoise_strength,
    deblock=args.deblock, rotate=args.rotate, crop=args.crop, scale=args.scale, extra=extra,
  )
  if preset.is_video:
    exts = VIDEO_EXTS
  else:
    exts = AUDIO_EXTS | PASSTHROUGH_EXTS
  if args.input_dir:
    src_root = args.input_dir.resolve()
    if not src_root.exists():
      log.err(f"Source directory does not exist: {src_root}")
      return 1
    files = find_files(src_root, exts)
    if args.format == 'opus':
      files = [f for f in files if f.suffix.lower() not in PASSTHROUGH_EXTS]
    out_dir = args.output_dir.resolve()
  else:
    import glob
    src_root = None
    files = []
    for pat in args.files:
      for p in glob.glob(str(Path(pat).expanduser()), recursive=True):
        path = Path(p)
        if path.is_file() and path.suffix.lower() in exts:
          if args.format == 'opus' and path.suffix.lower() in PASSTHROUGH_EXTS:
            continue
          files.append(path)
    out_dir = args.output_dir.resolve() if args.output_dir else None
  if not files:
    log.warn("No files found")
    return 0
  stats = run_batch(files, preset, cfg, log, out_dir, src_root, args.delete, args.jobs)
  print_summary(stats, log)
  return 1 if stats.failed else 0

if __name__ == '__main__':
  sys.exit(main())
