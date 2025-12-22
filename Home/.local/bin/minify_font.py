#!/usr/bin/env python3
import os
import sys
import fontforge
import pathlib

def minify_font(input_path):
    # 1. Open the font file provided as an argument
    try:
        font = fontforge.open(input_path)
    except Exception as e:
        print(f"Error opening font: {e}")
        return
    # 2. Remove embedded bitmaps (sbit)
    # Many old TTFs contain pixel versions of the font for low-res screens.
    # These are rarely needed today and take up massive space.
    font.bitmaps = None
    # 3. Clear Grid Fitting / Hints (Optional but recommended for smallest size)
    # This removes instructions on how to render pixels at very small sizes.
    # It significantly reduces file size but may soften edges on Windows XP/7.
    # For modern high-DPI screens, this is usually fine.
    font.simplify()
    # 4. Prepare Output Filename
    base_name, ext = os.path.splitext(input_path)
    output_path = f"{base_name}_minified.ttf"
    # 5. Generate the Font with Minification Flags
    # 'short-post': Drops internal glyph names (e.g., "afii10017" becomes an index).
    #               This is safe for TTF/Web use and saves considerable space.
    # 'no-hints':   Ensures no hinting tables are written to the file.
    # 'no-flex':    Removes flex hints (postscript specific, but good hygiene).
    try:
        font.generate(output_path, flags=('short-post', 'no-hints', 'no-flex'))
        print(f"Success! Minified font saved to: {output_path}")
    except Exception as e:
        print(f"Error generating font: {e}")
    finally:
        font.close()
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: fontforge -script minify_font.py <input_font.ttf>")
    else:
        minify_font(sys.argv[1])
