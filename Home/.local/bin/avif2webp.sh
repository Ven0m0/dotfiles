#!/usr/bin/env bash
# Usage: bash avif2webp.sh /path/to/dir

dir="${1:?missing directory}"
shopt -s nullglob

cd "$dir" || exit 1
for avif in *.avif; do
  [[ -f $avif ]] || continue
  webp="${avif%.avif}.webp"
  tmp=$(mktemp --suffix=.png)
  avifdec "$avif" "$tmp" >/dev/null 2>&1 || { echo "fail: $avif"; rm -f "$tmp"; continue; }
  cwebp -quiet "$tmp" -o "$webp" >/dev/null 2>&1 || echo "fail: $avif"
  rm -f "$tmp"
done
