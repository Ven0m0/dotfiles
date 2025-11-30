#!/usr/bin/env bash
# sanitize-filenames - Recursively rename files to be Linux-safe
set -euo pipefail; shopt -s globstar nullglob; IFS=$'\n\t'; export LC_ALL=C LANG=C
# repo-std: perf, idioms, quoting
has(){ command -v "$1" &>/dev/null; }
die(){ printf 'Error: %s\n' "$*" >&2; exit 1; }

has iconv || die "iconv required"
if has sd; then
  sanitize() { sd '[^A-Za-z0-9._-]+' '_' | sd '^_+|_+$' '' | sd '_+' '_'; }
elif has sed; then
  sanitize() { sed -E 's/[^A-Za-z0-9._-]+/_/g; s/^_+|_+$//g; s/_+/_/g'; }
else
  die "sed/sd required"
fi
if has fd; then finder=(fd -tf -td -H -I -0 .); else finder=(find . -print0); fi
count=0
"${finder[@]}" | sort -zr | while IFS= read -r -d '' f; do
  [[ -e "$f" ]] || continue
  dir="${f%/*}"
  base="${f##*/}"
  new=$(printf '%s' "$base" | iconv -f utf8 -t ascii//translit 2>/dev/null | sanitize)
  [[ "$base" != "$new" ]] || continue
  target="$dir/$new"
  [[ ! -e "$target" ]] || {
    printf 'Collision: %s\n' "$f" >&2
		continue
	}
	mv -f -- "$f" "$target" && printf '%s → %s\n' "$base" "$new" && ((count++)) || :
done
printf 'Renamed %d item(s)\n' "$count"
