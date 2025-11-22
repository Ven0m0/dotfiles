#!/usr/bin/env bash
#
# summary: a simple posix script for fuzzy searching and launching programs
# repository: https://github.com/hollowillow/scripts
#
# usage: fmenu [arg]
# description:
#
#       Search through all programs within $PATH using fzf and launch them using enter.
#       If an argument is provided, it treats it as the initial query.
#
# dependencies: fzf
set -euo pipefail

# create help message from comment block at the head of file
if [[ "${1:-}" == "-h" ]]; then
    sed "1,2d;s/^# //;s/^#$/ /;/^$/ q" "$0"
    exit 0
fi

# print all files within path
{
    IFS=:
    for dir in $PATH; do
        [[ -d "$dir" ]] && command ls "$dir" 2>/dev/null || :
    done
} | sort -u |
fzf \
    --prompt='run: ' \
    --header="$(printf '%s\n' 'enter:run' "${FZF_DEFAULT_HEADER:-}")" \
    -m \
    --query="$*" |
while IFS= read -r cmd; do
    nohup "$cmd" &>/dev/null &
done
