#!/bin/sh
#
# summary: a simple posix script for fuzzy searching man pages
# repository: https://github.com/hollowillow/scripts
#
# usage: fzman
#
# dependencies: fzf

if [ "$1" = "-h" ]; then
        sed "1,2d;s/^# //;s/^#$/ /;/^$/ q" "$0"; exit 0
fi

PREVIEW='man {1}'

man -k . | fzf \
        --prompt='manual: ' \
        --header="$(printf '%s\n' 'enter:open' "$FZF_DEFAULT_HEADER")" \
        --delimiter=' ' \
        --with-nth='1,2' \
        --preview="$PREVIEW" \
        --bind="enter:become:$PREVIEW" \
