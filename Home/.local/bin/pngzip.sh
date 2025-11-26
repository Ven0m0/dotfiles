#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
export LC_ALL=C LANG=C
src_dir="${1:-$PWD}"

[[ -d "$src_dir" ]] || { printf "Error: not a directory\n" >&2; exit 1; }
# pngquant (lossy) - skip errors, optimize in temp file
fd -tf -e png -H -I . "$src_dir" -x sh -c '
  tmp="${1}.tmp.$$"
  pngquant -Q 70-95 -s 1 --strip --force --output "$tmp" -- "$1" 2>/dev/null && mv -f "$tmp" "$1" || rm -f "$tmp"
' _ {}
# oxipng (lossless) - skip errors, optimize in-place
fd -tf -e png -H -I . "$src_dir" -x sh -c '
  oxipng -o max --strip all --alpha --zopfli -P --zi 25 --fix --scale16 -- "$1" 2>/dev/null || :
' _ {}
