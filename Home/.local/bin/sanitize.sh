#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar dotglob
IFS=$'\n\t'

BLD=$'\e[1m' GRN=$'\e[32m' YLW=$'\e[33m' RED=$'\e[31m' DEF=$'\e[0m'
has() { command -v "$1" &>/dev/null; }
die() {
  printf '%b==> ERROR:%b %s\n' "${BLD}${RED}" "$DEF" "$*" >&2
  exit 1
}
log() { printf '%b==>%b %s\n' "${BLD}" "$DEF" "$*"; }
ok() { printf '%b==>%b %s\n' "${BLD}${GRN}" "$DEF" "$*"; }

usage() {
  cat <<'EOF'
sanitize - File sanitization utilities

USAGE:
  sanitize COMMAND [OPTIONS] [PATH...]

COMMANDS:
  whitespace [PATH...]    Remove whitespace issues
  filenames [PATH...]     Rename files to Linux-safe names

WHITESPACE OPTIONS:
  --check              Check only, don't fix
  --cr                 Remove carriage returns
  --blank              Remove consecutive blank lines
  --trailing           Remove trailing whitespace
  --unicode            Remove non-standard Unicode spaces
  --all                Apply all fixes (default)

FILENAME OPTIONS:
  -n, --dry-run        Show renames without doing
  -v, --verbose        Show skipped files
  --preserve-case      Keep original case
  --allow-spaces       Keep spaces

EXAMPLES:
  sanitize whitespace --check /path/to/dir
  sanitize filenames -n . 
  sanitize whitespace --unicode --trailing file.txt
  sanitize filenames --preserve-case docs/

DEPENDENCIES:
  awk, sed, find/fd (whitespace)
  iconv, find/fd (filenames)
EOF
}

# ============================================================================
# WHITESPACE
# ============================================================================
cmd_whitespace() {
  local checkonly=0 status=0
  local do_cr=0 do_blank=0 do_trailing=0 do_unicode=0
  local -a paths=()
  remove_cr() { [[ $checkonly -eq 1 ]] && grep -q $'\r' "$1" && {
    printf 'CR: %s\n' "$1"
    return 1
  } || sed -i 's/\r//g' "$1"; }
  remove_blank() {
    [[ $checkonly -eq 1 ]] && return 0
    awk 'BEGIN{last=""}{if(NF==0&&last=="")next;else{print;last=$0}}' "$1" >"$1.tmp" && mv "$1.tmp" "$1"
  }
  remove_trailing() {
    [[ $checkonly -eq 1 ]] && return 0
    sed -i 's/[ \t]\+$//' "$1"
  }
  remove_unicode() {
    [[ $checkonly -eq 1 ]] && return 0
    has perl || die "perl required"
    perl -CS -0777 -pe 's/[\x{00A0}\x{202F}\x{200B}\x{00AD}]+/ /g;s/[ \t]+$//mg;' -i "$1"
  }
  while [[ $# -gt 0 ]]; do
    case $1 in
    --check) checkonly=1 ;;
    --cr) do_cr=1 ;;
    --blank) do_blank=1 ;;
    --trailing) do_trailing=1 ;;
    --unicode) do_unicode=1 ;;
    --all) do_cr=1 do_blank=1 do_trailing=1 do_unicode=1 ;;
    -*) die "Unknown option: $1" ;;
    *) paths+=("$1") ;;
    esac
    shift
  done
  [[ ${#paths[@]} -eq 0 ]] && die "Must provide path"
  [[ $((do_cr + do_blank + do_trailing + do_unicode)) -eq 0 ]] && do_cr=1 do_blank=1 do_trailing=1 do_unicode=1
  for p in "${paths[@]}"; do
    [[ -f $p ]] || {
      log "skip: $p"
      continue
    }
    [[ $do_cr -eq 1 ]] && { remove_cr "$p" || status=$?; }
    [[ $do_unicode -eq 1 ]] && { remove_unicode "$p" || status=$?; }
    [[ $do_trailing -eq 1 ]] && { remove_trailing "$p" || status=$?; }
    [[ $do_blank -eq 1 ]] && { remove_blank "$p" || status=$?; }
  done
  [[ $checkonly -eq 1 && $status -eq 1 ]] && {
    printf 'Issues found\n'
    exit 1
  }
  ok "Done"
}

# ============================================================================
# FILENAMES
# ============================================================================
cmd_filenames() {
  local dryrun=0 verbose=0 transliterate=1 lowercase=1 allow_spaces=0
  if has fd; then FD=fd; elif has fdfind; then FD=fdfind; else FD=find; fi
  has iconv || transliterate=0

  sanitize_name() {
    local name=$1 cleaned=$name
    [[ $transliterate -eq 1 ]] && cleaned=$(printf '%s' "$cleaned" | iconv -f utf8 -t ascii//translit 2>/dev/null || printf '%s' "$cleaned")
    cleaned=${cleaned//[\`\$\!\*\?\<\>\|\"\'\:\;]/}
    cleaned=${cleaned//\&/and}
    cleaned=${cleaned//@/at}
    [[ $allow_spaces -eq 0 ]] && cleaned=${cleaned//[[:space:]]/_}
    cleaned=$(printf '%s' "$cleaned" | sed -E 's/[^A-Za-z0-9._-]+/_/g;s/^[._-]+|[._-]+$//g;s/_+/_/g')
    [[ $lowercase -eq 1 ]] && cleaned=${cleaned,,}
    [[ -z $cleaned ]] && cleaned="_${RANDOM}"
    printf '%s' "$cleaned"
  }
  local -a paths=()
  while [[ $# -gt 0 ]]; do
    case $1 in
    -n | --dry-run) dryrun=1 ;;
    -v | --verbose) verbose=1 ;;
    --preserve-case) lowercase=0 ;;
    --allow-spaces) allow_spaces=1 ;;
    -*) die "Unknown option: $1" ;;
    *) paths+=("$1") ;;
    esac
    shift
  done
  [[ ${#paths[@]} -eq 0 ]] && paths=(.)
  for p in "${paths[@]}"; do
    [[ -e $p ]] || continue
    local dir=${p%/*} base=${p##*/}
    [[ $dir == "$p" ]] && dir=.
    local new=$(sanitize_name "$base")
    [[ $base == "$new" ]] && continue
    if [[ $dryrun -eq 1 ]]; then
      printf '[DRY] %s → %s\n' "$base" "$new"
    else
      mv -n -- "$p" "$dir/$new" 2>/dev/null && ok "$base → $new"
    fi
  done
  log "Complete"
}

# ============================================================================
# MAIN
# ============================================================================
main() {
  local cmd="${1:-}"
  shift || :
  case "$cmd" in
  whitespace | ws | w) cmd_whitespace "$@" ;;
  filenames | fn | f) cmd_filenames "$@" ;;
  -h | --help | help | "") usage ;;
  *) die "Unknown: $cmd" ;;
  esac
}

main "$@"
