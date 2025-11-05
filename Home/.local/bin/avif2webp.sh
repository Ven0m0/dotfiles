#!/usr/bin/env bash
shopt -s nullglob
# Usage: bash avif2webp.sh /path/to/dir
avif2webp(){
  dir="${1:?missing directory}"
  cd "$dir" || exit 1
  for avif in *.avif; do
    [[ -f $avif ]] || continue
    webp="${avif%.avif}.webp" tmp=$(mktemp --suffix=.png)
    avifdec "$avif" "$tmp" &>/dev/null || { echo "fail: $avif"; rm -f "$tmp"; continue; }
    cwebp -quiet -mt -m 6 -q 85 -pass 10 "$tmp" -o "$webp" || echo "fail: $avif"
    rm -f "$tmp"
done
