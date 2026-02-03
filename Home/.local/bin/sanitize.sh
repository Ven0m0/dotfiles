#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar dotglob
IFS=$'\n\t'; export LC_ALL=C

# Helper functions and constants
readonly BLD=$'\e[1m' GRN=$'\e[32m' RED=$'\e[31m' YLW=$'\e[33m' DEF=$'\e[0m'
export BLD GRN RED YLW DEF

has(){ command -v -- "$1" &>/dev/null; }
export -f has

die(){ printf '%bERROR:%b %s\n' "${BLD}${RED}" "$DEF" "$*" >&2; exit 1; }
log(){ printf '%b==>%b %s\n' "${BLD}" "$DEF" "$*"; }
ok(){ printf '%b✓%b %s\n' "${GRN}" "$DEF" "$*"; }
err(){ printf '%b✗%b %s\n' "${RED}" "$DEF" "$*"; }
export -f log ok err

# Worker function for parallel execution
_sanitize_worker() {
  # Config from environment variables: DO_CR, DO_EOF, DO_TRAILING, DO_UNICODE, CHECK
  local sed_script="" dirty=0
  local -a file_issues=()
  local out_buffer=""

  # Local output helpers to buffer output
  _ok(){ out_buffer+="$(ok "$@")"$'\n'; }
  _err(){ out_buffer+="$(err "$@")"$'\n'; }

  for f in "$@"; do
    [[ -f $f ]] || continue
    grep -qP -m1 '\x00' <(head -c 8000 -- "$f") && continue

    sed_script=""
    dirty=0
    file_issues=()
    out_buffer=""

    [[ $DO_TRAILING -eq 1 ]] && grep -q '[[:space:]]$' "$f" && {
      file_issues+=("trailing-ws")
      sed_script+='s/[[:space:]]\+$//;'
    }
    [[ $DO_CR -eq 1 ]] && grep -q $'\r' "$f" && {
      file_issues+=("crlf")
      sed_script+='s/\r//g;'
    }
    [[ $CHECK -eq 0 && -n $sed_script ]] && {
      sed -i "$sed_script" -- "$f"
      dirty=1
    }
    if [[ $DO_UNICODE -eq 1 ]] && has perl; then
      if perl -ne 'exit 1 if /[\x{00A0}\x{202F}\x{200B}\x{00AD}]/' -- "$f"; then
        :
      else
        file_issues+=("unicode")
        [[ $CHECK -eq 0 ]] && {
          perl -CS -0777 -i -pe 's/[\x{00A0}\x{202F}\x{200B}\x{00AD}]+/ /g' -- "$f"
          dirty=1
        }
      fi
    fi
    [[ $DO_EOF -eq 1 && -s $f ]] && [[ -n "$(tail -c 1 "$f")" ]] && {
      file_issues+=("no-eof-newline")
      [[ $CHECK -eq 0 ]] && {
        echo >>"$f"
        dirty=1
      }
    }
    [[ ${#file_issues[@]} -gt 0 ]] && {
      [[ $CHECK -eq 1 ]] && _err "$f: ${file_issues[*]}" || _ok "$f (fixed: ${file_issues[*]})"
      printf "%s" "$out_buffer"
    }
  done
}
export -f _sanitize_worker

usage(){
  cat <<EOF
sanitize - File sanitization utilities
USAGE: 
  sanitize ws [OPTS] [PATH|--git|--staged]... 
  sanitize fn [OPTS] [PATH]... 
COMMANDS:
  ws, whitespace   Fix whitespace (Trailing, EOF, CR, Unicode)
  fn, filenames    Rename to Linux-safe (lowercase, no spaces, ascii)
WHITESPACE OPTIONS:
  --check          Audit mode (exit 1 if issues found)
  --git            Check files modified in working tree
  --staged         Check files staged for commit
  --all            Enable all fixers (default)
  --eof --trailing --cr --unicode
FILENAME OPTIONS:
  -n, --dry-run    Preview renames
  --allow-spaces   Don't replace spaces
EOF
}

resolve_paths(){
  local -n _in="$1" _out="$2"
  local use_git=0 use_staged=0
  for p in "${_in[@]}"; do
    case "$p" in
      --git) use_git=1;;
      --staged) use_staged=1;;
      *)
        if [[ -d $p ]]; then
          if has fd; then
            mapfile -t -O "${#_out[@]}" _out < <(fd --type f --hidden --exclude .git .  "$p")
          else
            mapfile -t -O "${#_out[@]}" _out < <(find "$p" -type f -not -path '*/.git/*')
          fi
        elif [[ -f $p ]]; then
          _out+=("$p")
        fi
        ;;
    esac
  done
  [[ $use_staged -eq 1 ]] && mapfile -t -O "${#_out[@]}" _out < <(git diff --name-only --cached --diff-filter=ACMR)
  [[ $use_git -eq 1 ]] && mapfile -t -O "${#_out[@]}" _out < <(git diff --name-only --diff-filter=ACMR HEAD)
  mapfile -t _out < <(printf '%s\n' "${_out[@]}" | sort -u)
}

cmd_whitespace(){
  local check=0 do_cr=0 do_eof=0 do_trailing=0 do_unicode=0
  local -a args=() files=()
  while [[ $# -gt 0 ]]; do
    case $1 in
      --check) check=1;;
      --cr) do_cr=1;;
      --eof) do_eof=1;;
      --trailing) do_trailing=1;;
      --unicode) do_unicode=1;;
      --all) do_cr=1 do_eof=1 do_trailing=1 do_unicode=1;;
      -h|--help) usage; return 0;;
      *) args+=("$1");;
    esac
    shift
  done
  [[ $((do_cr + do_eof + do_trailing + do_unicode)) -eq 0 ]] && do_cr=1 do_eof=1 do_trailing=1 do_unicode=1
  resolve_paths args files
  [[ ${#files[@]} -eq 0 ]] && die "No files found.  Pass path or --git."
  log "Processing ${#files[@]} files..."

  export DO_CR=$do_cr DO_EOF=$do_eof DO_TRAILING=$do_trailing DO_UNICODE=$do_unicode CHECK=$check

  local cores=4 batch_size
  has nproc && cores=$(nproc)

  local total_files=${#files[@]}
  batch_size=$(( total_files / cores ))
  (( batch_size < 1 )) && batch_size=1
  (( batch_size > 500 )) && batch_size=500

  printf '%s\0' "${files[@]}" | \
    xargs -0 -P "$cores" -n "$batch_size" bash -c '_sanitize_worker "$@"' _ | \
    awk -v check="$check" -v bld="$BLD" -v red="$RED" -v def="$DEF" '
      { print }
      /✗/ { count++ }
      END {
        if (check == 1 && count > 0) {
            printf "%s%sERROR:%s Found issues in %d files.\n", bld, red, def, count > "/dev/stderr"
            exit 1
        }
      }
    '

  if [[ $check -eq 0 ]]; then
      log "Done."
  fi
}

cmd_filenames(){
  local dry=0 lowercase=1 spaces=0 trans=1
  local -a args=() files=()
  has iconv || trans=0
  while [[ $# -gt 0 ]]; do
    case $1 in
      -n|--dry-run) dry=1;;
      --allow-spaces) spaces=1;;
      --preserve-case) lowercase=0;;
      *) args+=("$1");;
    esac
    shift
  done
  resolve_paths args files
  [[ ${#files[@]} -eq 0 ]] && die "No paths provided"
  for src in "${files[@]}"; do
    [[ -e $src ]] || continue
    local dir base clean
    dir=$(dirname "$src")
    base=$(basename "$src")
    clean="$base"
    [[ $trans -eq 1 ]] && clean=$(printf '%s' "$clean" | iconv -f utf8 -t ascii//translit 2>/dev/null || printf '%s' "$clean")
    clean=${clean//[\`\$\!\*\?\<\>\|\"\'\:\;]/}
    clean=${clean//\&/and}
    clean=${clean//@/at}
    [[ $spaces -eq 0 ]] && clean=${clean//[[:space: ]]/_}
    clean=$(sed -E 's/[^A-Za-z0-9._-]+/_/g; s/^[._-]+//; s/[._-]+$//; s/_+/_/g' <<<"$clean")
    [[ $lowercase -eq 1 ]] && clean=${clean,,}
    [[ -z $clean ]] && clean="file_${RANDOM}"
    if [[ $base != "$clean" ]]; then
      local dest="$dir/$clean"
      if [[ $dry -eq 1 ]]; then
        printf '%bRENAME%b %s → %s\n' "${YLW}" "${DEF}" "$src" "$dest"
      else
        [[ -e $dest ]] && err "Conflict: $dest exists.  Skipping $src" || {
          mv -n -- "$src" "$dest" && ok "$src → $dest"
        }
      fi
    fi
  done
}
main(){
  [[ $# -eq 0 ]] && usage && exit 0
  local cmd="$1"
  shift
  case "$cmd" in
    ws|whitespace|w) cmd_whitespace "$@";;
    fn|filenames|f) cmd_filenames "$@";;
    -h|--help) usage;;
    *) die "Unknown command: $cmd";;
  esac
}

main "$@"
