#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
# shellcheck source=../lib/bash-common.sh
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s
source "${s%/bin/*}/lib/bash-common.sh"
init_strict
shopt -s dotglob
cd -P -- "${s%/*}"
readonly BLD=$C_BOLD GRN=$C_GREEN RED=$C_RED YLW=$C_YELLOW DEF=$C_RESET
err(){ printf '%b✗%b %s\n' "$RED" "$DEF" "$*"; }
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
  for p in "${_in[@]}";do
    case "$p" in
      --git) use_git=1;;
      --staged) use_staged=1;;
      *) if [[ -d $p ]];then has fd && mapfile -t -O "${#_out[@]}" _out < <(fd --type f --hidden --exclude .git . "$p")||mapfile -t -O "${#_out[@]}" _out < <(find "$p" -type f -not -path '*/.git/*');elif [[ -f $p ]];then _out+=("$p");fi;;
    esac
  done
  [[ $use_staged -eq 1 ]] && mapfile -t -O "${#_out[@]}" _out < <(git diff --name-only --cached --diff-filter=ACMR)
  [[ $use_git -eq 1 ]] && mapfile -t -O "${#_out[@]}" _out < <(git diff --name-only --diff-filter=ACMR HEAD)
  mapfile -t _out < <(printf '%s\n' "${_out[@]}"|sort -u)
}
cmd_whitespace(){
  local check=0 do_cr=0 do_eof=0 do_trailing=0 do_unicode=0 issues=0 -a args=() files=()
  while [[ $# -gt 0 ]];do
    case $1 in
      --check) check=1;;--cr) do_cr=1;;--eof) do_eof=1;;--trailing) do_trailing=1;;--unicode) do_unicode=1;;--all) do_cr=1 do_eof=1 do_trailing=1 do_unicode=1;;-h|--help) usage;return 0;;*) args+=("$1");;
    esac;shift
  done
  [[ $((do_cr+do_eof+do_trailing+do_unicode)) -eq 0 ]] && do_cr=1 do_eof=1 do_trailing=1 do_unicode=1
  resolve_paths args files
  [[ ${#files[@]} -eq 0 ]] && die "No files found. Pass path or --git."
  log "Processing ${#files[@]} files..."
  for f in "${files[@]}";do
    [[ -f $f ]]||continue
    grep -qP -m1 '\x00' <(head -c 8000 "$f") && continue
    local dirty=0 -a file_issues=() sed_script=""
    [[ $do_trailing -eq 1 ]] && grep -q '[[:space:]]$' "$f" && { file_issues+=("trailing-ws");sed_script+='s/[[:space:]]\+$//;';}
    [[ $do_cr -eq 1 ]] && grep -q $'\r' "$f" && { file_issues+=("crlf");sed_script+='s/\r//g;';}
    [[ $check -eq 0 && -n $sed_script ]] && { sed -i "$sed_script" "$f";dirty=1;}
    if [[ $do_unicode -eq 1 ]] && has perl;then
      if perl -ne 'exit 1 if /[\x{00A0}\x{202F}\x{200B}\x{00AD}]/' "$f";then
        :
      else
        file_issues+=("unicode")
        [[ $check -eq 0 ]] && { perl -CS -0777 -i -pe 's/[\x{00A0}\x{202F}\x{200B}\x{00AD}]+/ /g' "$f"; dirty=1; }
      fi
    fi
    [[ $do_eof -eq 1 && -s $f ]] && [[ -n "$(tail -c 1 "$f")" ]] && { file_issues+=("no-eof-newline");[[ $check -eq 0 ]] && { echo >>"$f";dirty=1;};}
    [[ ${#file_issues[@]} -gt 0 ]] && { issues=$((issues+1));[[ $check -eq 1 ]] && err "$f: ${file_issues[*]}"||ok "$f (fixed: ${file_issues[*]})";}
  done
  [[ $check -eq 1 && $issues -gt 0 ]] && die "Found issues in $issues files."
  [[ $check -eq 0 ]] && log "Done."
}
cmd_filenames(){
  local dry=0 lowercase=1 spaces=0 -a args=() files=() trans=1
  has iconv||trans=0
  while [[ $# -gt 0 ]];do case $1 in -n|--dry-run) dry=1;;--allow-spaces) spaces=1;;--preserve-case) lowercase=0;;*) args+=("$1");;esac;shift;done
  resolve_paths args files
  [[ ${#files[@]} -eq 0 ]] && die "No paths provided"
  for src in "${files[@]}";do
    [[ -e $src ]]||continue
    local dir base clean
    dir=$(dirname "$src");base=$(basename "$src");clean="$base"
    [[ $trans -eq 1 ]] && clean=$(printf '%s' "$clean"|iconv -f utf8 -t ascii//translit 2>/dev/null||printf '%s' "$clean")
    clean=${clean//[\`\$\!\*\?\<\>\|\"\'\:\;]/};clean=${clean//\&/and};clean=${clean//@/at}
    [[ $spaces -eq 0 ]] && clean=${clean//[[:space:]]/_}
    clean=$(sed -E 's/[^A-Za-z0-9._-]+/_/g; s/^[._-]+//; s/[._-]+$//; s/_+/_/g' <<<"$clean")
    [[ $lowercase -eq 1 ]] && clean=${clean,,}
    [[ -z $clean ]] && clean="file_${RANDOM}"
    if [[ $base != "$clean" ]];then
      local dest="$dir/$clean"
      if [[ $dry -eq 1 ]];then printf '%bRENAME%b %s → %s\n' "${YLW}" "${DEF}" "$src" "$dest";else [[ -e $dest ]] && err "Conflict: $dest exists. Skipping $src"||{ mv -n -- "$src" "$dest" && ok "$src → $clean";}; fi
    fi
  done
}
main(){
  [[ $# -eq 0 ]] && usage && exit 0
  local cmd="$1";shift
  case "$cmd" in ws|whitespace|w) cmd_whitespace "$@";;fn|filenames|f) cmd_filenames "$@";;-h|--help) usage;;*) die "Unknown command: $cmd";;esac
}
main "$@"
