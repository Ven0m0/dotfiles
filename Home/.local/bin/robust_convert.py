import os
import subprocess
import time
import shutil
import sys
from pathlib import Path

# --- CONFIGURATION ---
SOURCE_DIR = "/path/to/source"
DEST_DIR = "/path/to/destination"

# Extensions to convert
EXTENSIONS = {'mp4', 'mkv', 'avi', 'mov', 'ts', 'wmv', 'flv'}

# Encoder Settings (SVT-AV1 Essential Profile)
# Preset 4 is the sweet spot. Tune 0 = Visual Quality (VQ). Grain 15 prevents "plastic" look.
FFMPEG_ARGS = [
    "-c:v", "libsvtav1",
    "-preset", "4",
    "-crf", "28",
    "-svtav1-params", "tune=0:film-grain=15:enable-qm=1:qm-min=0:scd=1",
    "-c:a", "libopus", "-b:a", "128k"
]

# --- LOGIC ---

def check_tools():
    """Ensure required tools are installed."""
    missing = []
    if not shutil.which("fd"): missing.append("fd (fd-find)")
    if not shutil.which("ffmpeg"): missing.append("ffmpeg")
    # We don't fail if ffzap is missing, we just warn and skip to fallback
    if missing:
        print(f"Error: Missing required tools: {', '.join(missing)}")
        sys.exit(1)

def get_files(source):
    """Use 'fd' to get a fast list of video files."""
    try:
        # fd -e mp4 -e mkv ... --type f . /source
        cmd = ["fd", "--type", "f"]
        for ext in EXTENSIONS:
            cmd.extend(["-e", ext])
        cmd.append(".")
        cmd.append(source)
        
        result = subprocess.check_output(cmd, text=True)
        return [Path(p) for p in result.strip().split('\n') if p]
    except subprocess.CalledProcessError:
        print("Error running 'fd'. Is the source path correct?")
        sys.exit(1)

def convert_file(input_path, output_path):
    """
    Tries to convert using ffzap first, then falls back to ffmpeg.
    Retries on failure.
    """
    
    # 1. Define Commands
    # ffzap command (wraps ffmpeg)
    # Note: ffzap syntax might vary by version, but usually follows ffmpeg-like syntax or specific flags.
    # We assume standard ffmpeg-passing behavior or use specific ffzap flags if known. 
    # Since ffzap is a wrapper, we pass the encoding args to it.
    
    # FFmpeg command (standard)
    ffmpeg_cmd = [
        "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
        "-i", str(input_path),
        *FFMPEG_ARGS,
        str(output_path)
    ]
    
    # ffzap command construction (assuming standard CLI usage)
    # If ffzap is not found, this will be None
    ffzap_bin = shutil.which("ffzap")
    ffzap_cmd = None
    if ffzap_bin:
        # standard ffzap usually takes -i and -o and passes the rest to ffmpeg
        ffzap_cmd = [ffzap_bin, "-i", str(input_path), "-o", str(output_path)] 
        # We need to pass the codec args. Some ffzap versions take them as a string or list.
        # Assuming we can pass raw args:
        ffzap_cmd.extend(FFMPEG_ARGS)

    # 2. Attempt Logic
    max_retries = 3
    
    for attempt in range(1, max_retries + 1):
        tool_used = "ffzap" if (attempt == 1 and ffzap_cmd) else "ffmpeg"
        current_cmd = ffzap_cmd if tool_used == "ffzap" else ffmpeg_cmd
        
        print(f"  [{attempt}/{max_retries}] Encoding with {tool_used}...", end="", flush=True)
        
        start_time = time.time()
        try:
            subprocess.run(current_cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
            duration = time.time() - start_time
            print(f" Done ({duration:.1f}s)")
            return True # Success
            
        except subprocess.CalledProcessError:
            print(f" Failed!")
            # If we failed with ffzap, we loop to attempt 2 which will default to ffmpeg
            # If we failed with ffmpeg, we wait and retry
            if tool_used == "ffmpeg":
                time.sleep(5) # Cooldown before retry
    
    return False # All attempts failed

def main():
    check_tools()
    
    print(f"Scanning '{SOURCE_DIR}' with fd...")
    files = get_files(SOURCE_DIR)
    print(f"Found {len(files)} files.")
    
    failures = []
    
    for i, input_path in enumerate(files):
        # Calculate relative path to maintain structure
        rel_path = input_path.relative_to(SOURCE_DIR)
        output_path = Path(DEST_DIR) / rel_path.with_suffix(".mkv")
        
        # Create folder structure
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Skip if exists
        if output_path.exists():
            print(f"Skipping: {rel_path} (Exists)")
            continue
            
        print(f"\nProcessing {i+1}/{len(files)}: {rel_path}")
        success = convert_file(input_path, output_path)
        
        if not success:
            print(f"CRITICAL: Could not convert {rel_path}")
            failures.append(str(rel_path))
            # Optional: Delete partial file
            if output_path.exists():
                output_path.unlink()

    if failures:
        print("\n" + "="*40)
        print(f"Finished with {len(failures)} errors:")
        for f in failures:
            print(f" - {f}")
    else:
        print("\nAll files processed successfully.")

if __name__ == "__main__":
    main()
