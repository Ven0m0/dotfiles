#!/usr/bin/env bash
# sanitize-filenames.sh
# Recursively rename files to be Linux-safe
LC_ALL=C
shopt -s globstar nullglob
for f in **/*; do
  [[ -f "$f" ]] || continue
  dir=${f%/*}
  base=${f##*/}
  new=$(printf '%s' "$base" |
    iconv -f utf8 -t ascii//translit 2>/dev/null |
    sed -E 's/[^A-Za-z0-9._-]+/_/g; s/^_+|_+$//g; s/_+/_/g')
  [[ "$base" == "$new" ]] && continue
  printf 'Renaming: %s -> %s\n' "$f" "$dir/$new"
  mv -n -- "$f" "$dir/$new"
done
