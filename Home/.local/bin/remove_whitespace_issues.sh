#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

# Script Name: remove_whitespace_issues.sh
# Description: Removes carriage returns, consecutive blank lines, diacritics, empty lines, and leading whitespace
# Usage: remove_whitespace_issues.sh [OPTIONS] <path>
# Options:
#   --check            Only check for issues, don't fix
#   --cr               Remove carriage returns only
#   --blank            Remove consecutive blank lines only
#   --diacritics       Remove diacritics only
#   --empty            Remove empty lines only
#   --leading          Remove leading whitespace only
#   --all              Apply all fixes (default)
# Example: ./remove_whitespace_issues.sh --check --cr /path/to/dir

checkonly=0
status=0
do_cr=0 do_blank=0 do_diacritics=0 do_empty=0 do_leading=0

remove_cr(){
  local file=$1
  if [[ $checkonly -eq 1 ]]; then
    if grep -q $'\r' "$file"; then
      printf 'CR: %s\n' "$file"
      return 1
    fi
  else
    sed -i 's/\r//g' "$file"
  fi
}

remove_blank(){
  local file=$1
  [[ $checkonly -eq 1 ]] && return 0
  awk 'BEGIN{RS="\n";ORS="\n";last=""}{if(NF==0&&last=="")next;else{print;last=$0}}' "$file" > "$file. tmp"
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

process_file(){
  local file=$1 ret=0
  [[ $do_cr -eq 1 ]] && { remove_cr "$file" || ret=$?; }
  [[ $do_blank -eq 1 ]] && { remove_blank "$file" || ret=$?; }
  [[ $do_diacritics -eq 1 ]] && { remove_diacritics "$file" || ret=$?; }
  [[ $do_empty -eq 1 ]] && { remove_empty "$file" || ret=$?; }
  [[ $do_leading -eq 1 ]] && { remove_leading "$file" || ret=$? ; }
  return $ret
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
    printf 'Invalid path: %s\n' "$path" >&2; exit 1
  fi
}

main(){
  local path=
  while [[ $# -gt 0 ]]; do
    case $1 in
      --check) checkonly=1;;
      --cr) do_cr=1;;
      --blank) do_blank=1;;
      --diacritics) do_diacritics=1;;
      --empty) do_empty=1;;
      --leading) do_leading=1;;
      --all) do_cr=1 do_blank=1 do_diacritics=1 do_empty=1 do_leading=1;;
      -*) printf 'Unknown option: %s\n' "$1" >&2; exit 1;;
      *) path=$1;;
    esac
    shift
  done
  [[ -z $path ]] && { printf 'Must provide a path\n' >&2; exit 1; }
  [[ $((do_cr+do_blank+do_diacritics+do_empty+do_leading)) -eq 0 ]] && do_cr=1 do_blank=1 do_diacritics=1 do_empty=1 do_leading=1
  process_path "$path"
  if [[ $checkonly -eq 1 && $status -eq 1 ]]; then
    printf 'Issues found\n'; exit 1
  fi
  printf 'Done\n'
}

main "$@"
