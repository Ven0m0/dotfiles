#!/bin/bash
set -euo pipefail; shopt -s nullglob globstar extglob; IFS=$'\n\t' LC_ALL=C LANG=C
# Function to convert a single file
convert_to_webp(){
  local src="$1"
  local out="${src%.*}.webp"
  # Skip if output already exists
  [[ -e "$out" ]] && return 0
  # Check extension (case-insensitive handling via the case statement)
  case "${src##*.}" in
  png | PNG) cwebp -lossless -z 9 -mt -quiet "$src" -o "$out" || printf 'ERR: %s\n' "$src" >&2 ;;
  jpg | jpeg | JPG | JPEG) cwebp -q 85 -m 6 -mt -quiet "$src" -o "$out" || printf 'ERR: %s\n' "$src" >&2 ;;
  *) ;;
  esac
}
# If no arguments are provided, defaults to current directory (.)
targets=("${@:-.}")
# Loop through all arguments passed by Dolphin
for target in "${targets[@]}"; do
  if [[ -d "$target" ]]; then
    # It's a directory: use fd to find images recursively inside
    fd -tf -E '*.webp' -e png -e jpg -e jpeg . "$target" | while IFS= read -r file; do
      convert_to_webp "$file"
    done
  elif [[ -f "$target" ]]; then
    # It's a file: convert directly
    convert_to_webp "$target"
  fi
done
