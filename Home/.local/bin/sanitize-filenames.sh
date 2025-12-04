#!/usr/bin/env bash
# sanitize-filenames - Recursively rename files to be Linux-safe

# Source shared library
# shellcheck source=../lib/bash/stdlib.bash
. "${HOME}/.local/lib/bash/stdlib.bash" 2>/dev/null \
  || . "$(dirname "$(realpath "$0")")/../lib/bash/stdlib.bash" 2>/dev/null \
  || { echo "Error: stdlib.bash not found" >&2; exit 1; }

IFS=$'\n\t'

need iconv
if has sd; then
  sanitize(){ sd '[^A-Za-z0-9._-]+' '_' | sd '^_+|_+$' '' | sd '_+' '_'; }
elif has sed; then
  sanitize(){ sed -E 's/[^A-Za-z0-9._-]+/_/g; s/^_+|_+$//g; s/_+/_/g'; }
else
  die "sed/sd required"
fi
if [[ $FD != "find" ]]; then finder=("$FD" -tf -td -H -I -0 .); else finder=(find . -print0); fi
count=0
"${finder[@]}" | sort -zr | while IFS= read -r -d '' f; do
  [[ -e $f ]] || continue
  dir="${f%/*}"
  base="${f##*/}"
  new=$(printf '%s' "$base" | iconv -f utf8 -t ascii//translit 2>/dev/null | sanitize)
  [[ $base != "$new" ]] || continue
  target="$dir/$new"
  [[ ! -e $target ]] || {
    warn "Collision: $f"
    continue
  }
  mv -f -- "$f" "$target" && printf '%s → %s\n' "$base" "$new" && ((count++)) || :
done
log "Renamed $count item(s)"
