#!/usr/bin/env bash
#
# summary: a simple posix script for launching multiple preset programs
# repository: https://github.com/hollowillow/scripts
#
# usage: autostart [arg]
# description:
#
#       launch sets of applications using files located in "$XDG_CONFIG_HOME/autostart".
#       each file should only contain programs to be executed separated by newlines.
#       not providing an argument launches a fzf window to select one or more files.
#       providing arguments that are valid file names within the directory launches them directly.
#
# dependencies: fzf
set -euo pipefail

# create help message from comment block at the head of file
if [[ "${1:-}" == "-h" ]]; then
    sed "1,2d;s/^# //;s/^#$/ /;/^$/ q" "$0"
    exit 0
fi

# declare autostart directory
readonly AUTOSTART_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
mkdir -p "$AUTOSTART_DIR"
cd "$AUTOSTART_DIR" || { printf '%s\n' "Error: Autostart directory not found" >&2; exit 2; }

# parse arguments or launch interactive fzf menu
declare -a files
if [[ $# -gt 0 ]]; then
    files=("$@")
else
    mapfile -t files < <(
        find "$AUTOSTART_DIR" -type f -exec basename {} \; |
        fzf \
            --prompt='autostart: ' \
            --header="$(printf '%s\n' 'enter:confirm' "${FZF_DEFAULT_HEADER:-}")" \
            --preview='cat {}' \
            --multi
    )
fi

if [[ ${#files[@]} -eq 0 ]]; then
    printf '%s\n' "No files selected." >&2
    exit 1
fi

# launch programs specified within selected files
for file in "${files[@]}"; do
    if [[ -f "$AUTOSTART_DIR/$file" ]]; then
        while IFS= read -r program; do
            [[ -n "$program" ]] && nohup "$program" &>/dev/null &
        done < "$AUTOSTART_DIR/$file"
    else
        printf '%s\n' "Warning: File '$file' does not exist." >&2
    fi
done
