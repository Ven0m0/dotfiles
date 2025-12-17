#!/usr/bin/env python3
import os
import subprocess
import pathlib

# --- CONFIGURATION ---
# UPDATE THESE TWO PATHS BEFORE RUNNING
SOURCE_ROOT = "/path/to/your/source_videos"
DEST_ROOT = "/path/to/your/optimized_videos"

# Path to the optimized config file we worked on
PRESET_FILE = os.path.expanduser("~/.config/ghb/main.json")
# The name of the preset inside that file (it is "main" based on your original file)
PRESET_NAME = "main"

# File extensions to look for
VIDEO_EXTS = {'.mkv', '.mp4', '.m4v', '.avi', '.mov', '.ts', '.flv', '.wmv'}

def main():
    # check if HandBrakeCLI is installed
    if shutil.which("HandBrakeCLI") is None:
        print("Error: HandBrakeCLI is not found. Install it via: sudo pacman -S handbrake-cli")
        return

    print(f"Scanning: {SOURCE_ROOT}")
    print(f"Target:   {DEST_ROOT}")
    print("-" * 40)

    for root, dirs, files in os.walk(SOURCE_ROOT):
        # Calculate the relative path (e.g., "Vacation/2023")
        rel_path = os.path.relpath(root, SOURCE_ROOT)
        
        # Create the corresponding directory in the destination
        current_dest_dir = os.path.join(DEST_ROOT, rel_path)
        if not os.path.exists(current_dest_dir):
            os.makedirs(current_dest_dir)
            print(f"Created Folder: {rel_path}")

        for file in files:
            input_path = pathlib.Path(os.path.join(root, file))
            
            # Check if it is a video file
            if input_path.suffix.lower() in VIDEO_EXTS:
                # Construct output filename (forcing .mkv as per your preset)
                output_filename = input_path.stem + ".mkv"
                output_path = os.path.join(current_dest_dir, output_filename)

                # Skip if file already exists
                if os.path.exists(output_path):
                    print(f"Skipping (Exists): {output_filename}")
                    continue

                print(f"Encoding: {file} ...")
                
                # Construct the command
                # -Z selects the preset
                # --preset-import-file loads your specific config
                cmd = [
                    "HandBrakeCLI",
                    "--preset-import-file", PRESET_FILE,
                    "-Z", PRESET_NAME,
                    "-i", str(input_path),
                    "-o", output_path
                ]

                try:
                    # Run HandBrakeCLI and suppress massive output (show only progress bars if possible, 
                    # but typically CLI is verbose. We capture output to keep terminal clean-ish)
                    # Remove 'stdout=subprocess.DEVNULL' if you want to see the HandBrake logs live.
                    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
                    print(f"  [OK] Done")
                except subprocess.CalledProcessError as e:
                    print(f"  [ERROR] Failed to convert {file}")

import shutil
if __name__ == "__main__":
    main()
