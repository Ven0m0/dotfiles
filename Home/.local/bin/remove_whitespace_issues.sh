#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t'
# Script Name: remove_whitespace_issues. sh
# Description: Removes carriage returns, consecutive blank lines, diacritics, empty lines, leading/trailing whitespace, and non-standard Unicode spaces
# Usage: remove_whitespace_issues.sh [OPTIONS] <path... >
# Options:
#   --check            Only check for issues, don't fix
#   --cr               Remove carriage returns only
#   --blank            Remove consecutive blank lines only
#   --diacritics       Remove diacritics only
#   --empty            Remove empty lines only
#   --leading          Remove leading whitespace only
#   --trailing         Remove trailing whitespace only
#   --unicode          Remove non-standard Unicode spaces only
#   --collapse         Collapse multiple spaces to one (with --unicode/--all)
#   --all              Apply all fixes (default)
# Example: ./remove_whitespace_issues.sh --check --cr /path/to/dir
#          ./remove_whitespace_issues.sh --unicode --collapse file1.txt file2.sh
BLD=$'\e[1m' GRN=$'\e[32m' BLU=$'\e[34m' RED=$'\e[31m' DEF=$'\e[0m'
has(){ command -v "$1" &>/dev/null; }
log(){ printf '%b==>\e[0m %s\n' "${BLD}${BLU}" "$*"; }
ok(){ printf '%b==>\e[0m %s\n' "${BLD}${GRN}" "$*"; }
die(){ printf '%b==> ERROR:\e[0m %s\n' "${BLD}${RED}" "$*" >&2; exit "${2:-1}"; }
checkonly=0 status=0 collapse=0
do_cr=0 do_blank=0 do_diacritics=0 do_empty=0 do_leading=0 do_trailing=0 do_unicode=0

remove_cr(){
  local file=$1
  if [[ $checkonly -eq 1 ]]; then
    if grep -q $'\r' "$file"; then
      printf 'CR: %s\n' "$file"; return 1
    fi
  else
    sed -i 's/\r//g' "$file"
  fi
}

remove_blank(){
  local file=$1
  [[ $checkonly -eq 1 ]] && return 0
  awk 'BEGIN{RS="\n";ORS="\n";last=""}{if(NF==0&&last=="")next;else{print;last=$0}}' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
}

remove_diacritics(){
  local file=$1
  [[ $checkonly -eq 1 ]] && return 0
  sed -i 'y/ąāáǎàćēéěèęīíǐìłńōóǒòóśūúǔùǖǘǚǜżźĄĀÁǍÀĆĒĘÉĚÈĪÍǏÌŁŃŌÓǑÒÓŚŪÚǓÙǕǗǙǛŻŹ/aaaaaceeeeeiiiilnooooosuuuuuuuuzzAAAAACEEEEEIIIILNOOOOOSUUUUUUUUZZ/' "$file"
}

remove_empty(){
  local file=$1
  [[ $checkonly -eq 1 ]] && return 0
  awk 'NF' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
}

remove_leading(){
  local file=$1
  [[ $checkonly -eq 1 ]] && return 0
  sed -i 's/^[ \t]*//' "$file"
}

remove_trailing(){
  local file=$1
  [[ $checkonly -eq 1 ]] && return 0
  sed -i 's/[ \t]\+$//' "$file"
}

remove_unicode(){
  local file=$1
  [[ $checkonly -eq 1 ]] && return 0
  has perl || die "perl required for --unicode"
  if [[ $collapse -eq 1 ]]; then
    perl -CS -0777 -pe 's/[\x{00A0}\x{202F}\x{200B}\x{00AD}]+/ /g;s/[ \t]+$//mg;s/ {2,}/ /g;' -i "$file"
  else
    perl -CS -0777 -pe 's/[\x{00A0}\x{202F}\x{200B}\x{00AD}]+/ /g;s/[ \t]+$//mg;' -i "$file"
  fi
}

process_file(){
  local file=$1 ret=0
  [[ $do_cr -eq 1 ]] && { remove_cr "$file" || ret=$? ; }
  [[ $do_unicode -eq 1 ]] && { remove_unicode "$file" || ret=$?; }
  [[ $do_trailing -eq 1 ]] && { remove_trailing "$file" || ret=$?; }
  [[ $do_blank -eq 1 ]] && { remove_blank "$file" || ret=$?; }
  [[ $do_diacritics -eq 1 ]] && { remove_diacritics "$file" || ret=$?; }
  [[ $do_empty -eq 1 ]] && { remove_empty "$file" || ret=$?; }
  [[ $do_leading -eq 1 ]] && { remove_leading "$file" || ret=$? ; }
  return "$ret"
}

process_path(){
  local path=$1
  if [[ -f $path ]]; then
    process_file "$path" || status=$?
  elif [[ -d $path ]]; then
    while IFS= read -r -d '' file; do
      process_file "$file" || status=$? 
    done < <(find "$path" -type f -print0)
  else
    log "skip: $path (not a file/directory)"
  fi
}

main(){
  local -a paths=()
  while [[ $# -gt 0 ]]; do
    case $1 in
      --check) checkonly=1;;
      --cr) do_cr=1;;
      --blank) do_blank=1;;
      --diacritics) do_diacritics=1;;
      --empty) do_empty=1;;
      --leading) do_leading=1;;
      --trailing) do_trailing=1;;
      --unicode) do_unicode=1;;
      --collapse) collapse=1;;
      --all) do_cr=1 do_blank=1 do_diacritics=1 do_empty=1 do_leading=1 do_trailing=1 do_unicode=1;;
      -h|--help)
        printf 'Usage: %s [OPTIONS] <path...>\n' "$0" >&2
        printf 'See script header for options\n' >&2
        exit 0;;
      -*) die "Unknown option: $1";;
      *) paths+=("$1");;
    esac
    shift
  done
  [[ ${#paths[@]} -eq 0 ]] && die "Must provide at least one path"
  [[ $((do_cr+do_blank+do_diacritics+do_empty+do_leading+do_trailing+do_unicode)) -eq 0 ]] && do_cr=1 do_blank=1 do_diacritics=1 do_empty=1 do_leading=1 do_trailing=1 do_unicode=1
  for p in "${paths[@]}"; do
    process_path "$p"
  done
  if [[ $checkonly -eq 1 && $status -eq 1 ]]; then
    printf 'Issues found\n'; exit 1
  fi
  ok 'Done'
}

main "$@"
