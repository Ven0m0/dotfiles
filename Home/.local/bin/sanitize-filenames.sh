#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar dotglob
IFS=$'\n\t'
# sanitize-filenames - Recursively rename files to be Linux-safe
# Usage: sanitize-filenames. sh [OPTIONS] [path...]
# Options:
#   -n, --dry-run      Show what would be renamed without doing it
#   -v, --verbose      Show skipped files
#   -d, --depth N      Max recursion depth (default: unlimited)
#   --no-transliterate Skip iconv transliteration (faster, ASCII-only)
#   --preserve-case    Keep original case (default: lowercase)
#   --allow-spaces     Keep spaces instead of replacing with underscores

BLD=$'\e[1m' GRN=$'\e[32m' YLW=$'\e[33m' BLU=$'\e[34m' RED=$'\e[31m' DEF=$'\e[0m'
has(){ command -v "$1" &>/dev/null; }
die(){ printf '%b==> ERROR:\e[0m %s\n' "${BLD}${RED}" "$*" >&2; exit "${2:-1}"; }
warn(){ printf '%b==> WARN:\e[0m %s\n' "${BLD}${YLW}" "$*"; }
log(){ printf '%b==>\e[0m %s\n' "${BLD}${BLU}" "$*"; }
ok(){ printf '%b==>\e[0m %s\n' "${BLD}${GRN}" "$*"; }
dryrun=0 verbose=0 maxdepth= transliterate=1 lowercase=1 allow_spaces=0
if has fd; then FD=fd; elif has fdfind; then FD=fdfind; else FD=find; fi
has iconv || transliterate=0

sanitize(){
  local name=$1 cleaned=$name
  [[ $transliterate -eq 1 ]] && cleaned=$(printf '%s' "$cleaned" | iconv -f utf8 -t ascii//translit 2>/dev/null || printf '%s' "$cleaned")
  cleaned=${cleaned//\`/}
  cleaned=${cleaned//\$/}
  cleaned=${cleaned//\!/}
  cleaned=${cleaned//\*/}
  cleaned=${cleaned//\? /}
  cleaned=${cleaned//\</}
  cleaned=${cleaned//\>/}
  cleaned=${cleaned//\|/}
  cleaned=${cleaned//\"/}
  cleaned=${cleaned//\'/}
  cleaned=${cleaned//\\/}
  cleaned=${cleaned//:/}
  cleaned=${cleaned//;/}
  cleaned=${cleaned//\&/and}
  cleaned=${cleaned//@/at}
  cleaned=${cleaned//#/num}
  cleaned=${cleaned//%/pct}
  cleaned=${cleaned//+/plus}
  cleaned=${cleaned//=/eq}
  cleaned=${cleaned//\[/}
  cleaned=${cleaned//\]/}
  cleaned=${cleaned//\(/}
  cleaned=${cleaned//\)/}
  cleaned=${cleaned//\{/}
  cleaned=${cleaned//\}/}
  if [[ $allow_spaces -eq 0 ]]; then
    cleaned=$(printf '%s' "$cleaned" | sed -E 's/[[:space:]]+/_/g')
  else
    cleaned=$(printf '%s' "$cleaned" | sed -E 's/[[:space:]]+/ /g')
  fi
  cleaned=$(printf '%s' "$cleaned" | sed -E 's/[^A-Za-z0-9._-]+/_/g; s/^[._-]+|[._-]+$//g; s/_+/_/g; s/\. +/./g; s/-+/-/g')
  [[ $lowercase -eq 1 ]] && cleaned=${cleaned,,}
  local ext= stem=$cleaned
  if [[ $cleaned =~ \.  && $cleaned != . * ]]; then
    ext=${cleaned##*.}
    stem=${cleaned%.*}
    [[ ${#stem} -gt 200 ]] && stem=${stem:0:200}
    cleaned="$stem.$ext"
  else
    [[ ${#cleaned} -gt 255 ]] && cleaned=${cleaned:0:255}
  fi
  [[ -z $cleaned || $cleaned == "." || $cleaned == ".." ]] && cleaned="_${RANDOM}"
  printf '%s' "$cleaned"
}

rename_item(){
  local item=$1 dir base new target
  [[ -e $item ]] || return 0
  dir=${item%/*}
  [[ $dir == "$item" ]] && dir=. 
  base=${item##*/}
  [[ $base == "." || $base == ".." ]] && return 0
  new=$(sanitize "$base")
  [[ $base == "$new" ]] && { [[ $verbose -eq 1 ]] && log "skip: $item"; return 0; }
  target=$dir/$new
  if [[ -e $target && $target != "$item" ]]; then
    local n=1
    local stem=$new ext=
    if [[ $new =~ \.  && $new != .* ]]; then
      ext=. ${new##*.}
      stem=${new%.*}
    fi
    while [[ -e $dir/${stem}_$n$ext ]]; do ((n++)); done
    target=$dir/${stem}_$n$ext
    new=${stem}_$n$ext
    warn "Collision: $base → $new"
  fi
  if [[ $dryrun -eq 1 ]]; then
    printf '[DRY] %s → %s\n' "$base" "$new"; return 0
  fi
  if mv -n -- "$item" "$target" 2>/dev/null; then
    ok "$base → $new"; return 0
  else
    warn "Failed: $item"; return 1
  fi
}

process_paths(){
  local -a paths=("$@")
  local -a items=() finder_args=()
  if [[ $FD != find ]]; then
    finder_args=("$FD" -tf -td -H -I -u -0)
    [[ -n $maxdepth ]] && finder_args+=(-d "$maxdepth")
    for p in "${paths[@]}"; do
      mapfile -t -d '' found < <("${finder_args[@]}" .  "$p")
      items+=("${found[@]}")
    done
  else
    finder_args=(find)
    [[ -n $maxdepth ]] && finder_args+=(-maxdepth "$maxdepth")
    finder_args+=(-mindepth 1 -print0)
    for p in "${paths[@]}"; do
      mapfile -t -d '' found < <("${finder_args[@]}" "$p")
      items+=("${found[@]}")
    done
  fi
  printf '%s\0' "${items[@]}" | sort -zr | while IFS= read -r -d '' item; do
    rename_item "$item"
  done
}

main(){
  local -a paths=()
  while [[ $# -gt 0 ]]; do
    case $1 in
      -n|--dry-run) dryrun=1;;
      -v|--verbose) verbose=1;;
      -d|--depth) shift; maxdepth=$1;;
      --no-transliterate) transliterate=0;;
      --preserve-case) lowercase=0;;
      --allow-spaces) allow_spaces=1;;
      -h|--help)
        printf 'Usage: %s [OPTIONS] [path...]\n' "$0" >&2
        printf 'See script header for options\n' >&2
        exit 0;;
      -*) die "Unknown option: $1";;
      *) paths+=("$1");;
    esac
    shift
  done
  [[ ${#paths[@]} -eq 0 ]] && paths=(.)
  local count=0
  for p in "${paths[@]}"; do
    [[ -e $p ]] || { warn "Not found: $p"; continue; }
    ((count++))
  done
  [[ $count -eq 0 ]] && die "No valid paths provided"
  process_paths "${paths[@]}"
  log "Complete"
}
main "$@"
