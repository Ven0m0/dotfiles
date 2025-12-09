#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
set -euo pipefail; shopt -s nullglob globstar
export LC_ALL=C; IFS=$'\n\t'
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
has(){ command -v -- "$1" &>/dev/null; }
readonly AUTOSTART_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
[[ ${1:-} == -h ]] && { sed "1,2d;s/^# //;s/^#$/ /;/^$/q" "$0"; exit 0; }
mkdir -p "$AUTOSTART_DIR"
cd "$AUTOSTART_DIR" || { printf 'Error: Autostart directory not found\n' >&2; exit 2; }
declare -a files
if [[ $# -gt 0 ]]; then
  files=("$@")
else
  if has fd; then
    mapfile -t files < <(fd -t f --base-path "$AUTOSTART_DIR"|fzf --prompt='autostart: ' --preview='cat {}' -m --header='enter:confirm')
  else
    mapfile -t files < <(find "$AUTOSTART_DIR" -type f -exec basename {} \;|fzf --prompt='autostart: ' --preview='cat {}' -m --header='enter:confirm')
  fi
fi
[[ ${#files[@]} -eq 0 ]] && { printf 'No files selected.\n' >&2; exit 1; }
for file in "${files[@]}"; do
  if [[ -f "$AUTOSTART_DIR/$file" ]]; then
    while IFS= read -r program; do
      [[ -n $program ]] && nohup "$program" &>/dev/null &
    done <"$AUTOSTART_DIR/$file"
  else
    printf "Warning: File '%s' does not exist.\n" "$file" >&2
  fi
done
