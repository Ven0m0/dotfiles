#!/usr/bin/env bash
set -eo pipefail; shopt -s nullglob
export LC_ALL=C LANG=C
root="${1:-.}"

# find images
fd -tf -E '*.webp' -e png -e jpg -e jpeg "$root" \
| while IFS= read -r src; do
  out="${src%.*}.webp"
  [[ -e "$out" ]] && continue
  case "${src##*.}" in
    png|PNG) cwebp -lossless -z 9 -mt -quiet "$src" -o "$out" || printf 'ERR: %s\n' "$src" >&2 ;;
    jpg|jpeg|JPG|JPEG) cwebp -q 85 -m 6 -mt -quiet "$src" -o "$out" || printf 'ERR: %s\n' "$src" >&2 ;;
    *) ;;
  esac
done
