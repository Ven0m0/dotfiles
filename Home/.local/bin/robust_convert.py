#!/usr/bin/env python3
import os
import subprocess
import time
import shutil
import sys
import argparse
from pathlib import Path

# --- DEFAULT CONFIGURATION ---
EXTENSIONS = {'mp4', 'mkv', 'avi', 'mov', 'ts', 'wmv', 'flv'}

def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Robust Bulk SVT-AV1 Converter (Uses ffzap with ffmpeg fallback).",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    
    # Required Arguments
    parser.add_argument("source", type=str, help="Root folder containing source videos")
    parser.add_argument("destination", type=str, help="Root folder for output videos")

    # Optional Encoding Arguments
    parser.add_argument("--crf", type=int, default=28, help="SVT-AV1 CRF quality value (Lower is better)")
    parser.add_argument("--preset", type=int, default=4, help="SVT-AV1 Encoder Preset (0-13, Higher is faster)")
    parser.add_argument("--grain", type=int, default=15, help="Film Grain Synthesis level (0-50, hides artifacts)")
    parser.add_argument("--audio-bitrate", type=str, default="128k", help="Opus audio bitrate (e.g., 128k, 192k)")
    
    # NEW: Deinterlace Flag
    parser.add_argument("--deinterlace", action="store_true", help="Fix 'weird lines' (combing) in older videos")
    
    return parser.parse_args()

def check_tools():
    missing = []
    if not shutil.which("fd"): missing.append("fd (fd-find)")
    if not shutil.which("ffmpeg"): missing.append("ffmpeg")
    
    if missing:
        print(f"Error: Missing required tools: {', '.join(missing)}")
        print("Install them with: sudo pacman -S fd ffmpeg")
        sys.exit(1)

def get_files(source_dir):
    try:
        # fd --type f -e mp4 -e mkv ... . /source
        cmd = ["fd", "--type", "f"]
        for ext in EXTENSIONS:
            cmd.extend(["-e", ext])
        cmd.append(".")
        cmd.append(source_dir)
        
        result = subprocess.check_output(cmd, text=True)
        paths = [Path(p) for p in result.strip().split('\n') if p]
        return paths
    except subprocess.CalledProcessError:
        print(f"Error: Could not scan directory '{source_dir}'. Check permissions or path.")
        sys.exit(1)

def build_ffmpeg_args(args):
    """Constructs the encoding arguments based on CLI inputs."""
    
    cmd_args = []
    
    # 1. Video Filters (Deinterlacing)
    if args.deinterlace:
        # bwdif is a high-quality deinterlacer.
        cmd_args.extend(["-vf", "bwdif"])
    
    # 2. SVT-AV1 Params
    # tune=0 (VQ), enable-qm=1 (Quantization Matrices)
    svt_params = f"tune=0:film-grain={args.grain}:enable-qm=1:qm-min=0:scd=1"
    
    cmd_args.extend([
        "-c:v", "libsvtav1",
        "-preset", str(args.preset),
        "-crf", str(args.crf),
        "-svtav1-params", svt_params,
        "-c:a", "libopus", "-b:a", args.audio_bitrate
    ])
    
    return cmd_args

def convert_file(input_path, output_path, ffmpeg_args):
    # 1. Define Commands
    
    # Standard FFmpeg command
    base_ffmpeg_cmd = [
        "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
        "-i", str(input_path)
    ] + ffmpeg_args + [str(output_path)]
    
    # ffzap command (Wrapper)
    ffzap_bin = shutil.which("ffzap")
    ffzap_cmd = None
    if ffzap_bin:
        # ffzap takes -i and -o, then passes the rest to ffmpeg
        ffzap_cmd = [ffzap_bin, "-i", str(input_path), "-o", str(output_path)] + ffmpeg_args

    # 2. Robust Retry Loop
    max_retries = 3
    
    for attempt in range(1, max_retries + 1):
        use_ffzap = (attempt == 1 and ffzap_cmd is not None)
        cmd = ffzap_cmd if use_ffzap else base_ffmpeg_cmd
        tool_name = "ffzap" if use_ffzap else "ffmpeg"
        
        print(f"  [{attempt}/{max_retries}] Encoding via {tool_name}...", end="", flush=True)
        start_time = time.time()
        
        try:
            # Run command
            subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
            print(f" Done ({time.time() - start_time:.1f}s)")
            return True
            
        except subprocess.CalledProcessError:
            print(" Failed!")
            if not use_ffzap:
                time.sleep(3)
                
    return False

def main():
    args = parse_arguments()
    check_tools()
    
    source_dir = Path(args.source).resolve()
    dest_dir = Path(args.destination).resolve()

    if not source_dir.exists():
        print(f"Error: Source directory '{source_dir}' does not exist.")
        sys.exit(1)

    print(f"--- SVT-AV1 Bulk Converter ---")
    print(f"Source:  {source_dir}")
    print(f"Dest:    {dest_dir}")
    print(f"Profile: Preset {args.preset}, CRF {args.crf}, Grain {args.grain}")
    if args.deinterlace:
        print(f"Filters: Deinterlace (bwdif) ENABLED")
    print("-" * 40)

    print("Scanning files...")
    files = get_files(str(source_dir))
    
    if not files:
        print("No video files found.")
        sys.exit(0)
        
    print(f"Found {len(files)} videos to process.")
    
    failures = []
    ffmpeg_args = build_ffmpeg_args(args)

    for i, input_path in enumerate(files):
        rel_path = input_path.relative_to(source_dir)
        output_path = dest_dir / rel_path.with_suffix(".mkv")
        
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        if output_path.exists():
            print(f"Skipping (Exists): {rel_path}")
            continue
            
        print(f"\nProcessing {i+1}/{len(files)}: {rel_path}")
        success = convert_file(input_path, output_path, ffmpeg_args)
        
        if not success:
            print(f"CRITICAL: Failed to convert {rel_path}")
            failures.append(str(rel_path))
            if output_path.exists():
                output_path.unlink()

    if failures:
        print("\n" + "="*40)
        print(f"Done with {len(failures)} errors:")
        for f in failures:
            print(f" - {f}")
    else:
        print("\nAll files processed successfully.")

if __name__ == "__main__":
    main()
