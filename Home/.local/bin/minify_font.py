#!/usr/bin/env python3
import sys
from pathlib import Path

try:
  import fontforge
except ImportError:
  print("Error: fontforge module not available. Install python-fontforge.", file=sys.stderr)
  sys.exit(1)


def minify_font(input_path: str) -> int:
  """
  Minify a font file by removing bitmaps, hints, and other size-consuming features.

  Returns 0 on success, 1 on failure.
  """
  input_file = Path(input_path)

  if not input_file.exists():
    print(f"Error: File not found: {input_path}", file=sys.stderr)
    return 1

  if not input_file.is_file():
    print(f"Error: Not a file: {input_path}", file=sys.stderr)
    return 1

  # 1. Open the font file
  try:
    font = fontforge.open(str(input_file))
  except (OSError, EnvironmentError) as e:
    print(f"Error opening font: {e}", file=sys.stderr)
    return 1

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
  output_path = input_file.parent / f"{input_file.stem}_minified.ttf"

  # 5. Generate the Font with Minification Flags
  # 'short-post': Drops internal glyph names (e.g., "afii10017" becomes an index).
  #               This is safe for TTF/Web use and saves considerable space.
  # 'no-hints':   Ensures no hinting tables are written to the file.
  # 'no-flex':    Removes flex hints (postscript specific, but good hygiene).
  try:
    font.generate(str(output_path), flags=('short-post', 'no-hints', 'no-flex'))
    print(f"Success! Minified font saved to: {output_path}")
    return 0
  except (OSError, EnvironmentError) as e:
    print(f"Error generating font: {e}", file=sys.stderr)
    return 1
  finally:
    font.close()


if __name__ == "__main__":
  if len(sys.argv) < 2:
    print("Usage: minify_font.py <input_font.ttf>", file=sys.stderr)
    print("   or: fontforge -script minify_font.py <input_font.ttf>", file=sys.stderr)
    sys.exit(1)

  exit_code = minify_font(sys.argv[1])
  sys.exit(exit_code)
