#!/usr/bin/env bash
# sanitize-filenames - Recursively rename files to be Linux-safe

set -euo pipefail
IFS=$'\n\t'

# ANSI colors
BLD=$'\e[1m' YLW=$'\e[33m' BLU=$'\e[34m' DEF=$'\e[0m'

# Helper functions
has() { command -v "$1" &>/dev/null; }
die() { printf '%b==> ERROR:\e[0m %s\n' "${BLD}${YLW}" "$*" >&2; exit "${2:-1}"; }
need() { has "$1" || die "Required command not found: $1"; }
warn() { printf '%b==> WARNING:\e[0m %s\n' "${BLD}${YLW}" "$*"; }
log() { printf '%b==>\e[0m %s\n' "${BLD}${BLU}" "$*"; }

# Tool detection (fd fallback chain: fdf → fd → fdfind → find)
if has fdf; then FD=fdf; elif has fd; then FD=fd; elif has fdfind; then FD=fdfind; else FD=find; fi

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
