#!/usr/bin/env bash
set -euo pipefail;shopt -s nullglob globstar;IFS=$'\n\t'
export LC_ALL=C LANG=C
[[ ${1:-} == -h ]] && { sed "1,2d;s/^# //;s/^#$/ /;/^$/q" "$0";exit 0;}
readonly AUTOSTART_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
mkdir -p "$AUTOSTART_DIR"
cd "$AUTOSTART_DIR"||{ printf '%s\n' "Error: Autostart directory not found" >&2;exit 2;}
declare -a files
if [[ $# -gt 0 ]];then files=("$@")
else mapfile -t files < <(command -v fd &>/dev/null && fd -t f --base-path "$AUTOSTART_DIR" || find "$AUTOSTART_DIR" -type f -exec basename {} \;|fzf --prompt='autostart: ' --preview='cat {}' -m --header="$(printf '%s\n' 'enter:confirm' "${FZF_DEFAULT_HEADER:-}")")
fi
[[ ${#files[@]} -eq 0 ]] && { printf '%s\n' "No files selected." >&2;exit 1;}
for file in "${files[@]}";do [[ -f "$AUTOSTART_DIR/$file" ]] && while IFS= read -r program;do [[ -n $program ]] && nohup "$program" &>/dev/null &;done <"$AUTOSTART_DIR/$file"||printf '%s\n' "Warning: File '$file' does not exist." >&2;done
