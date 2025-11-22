#!/bin/sh
#
# summary: a simple posix script for fuzzy searching git commits
# repository: https://github.com/hollowillow/scripts
#
# usage: fzgit
#
# dependencies: fzf, git, wl-clipboard (wayland), xclip (x11)

if [ "$1" = "-h" ]; then
        sed "1,2d;s/^# //;s/^#$/ /;/^$/ q" "$0"; exit 0
fi

if [ "$(git rev-parse 2>/dev/null; printf '%s' $?)" -ne 0 ]; then
        printf '%s\n' "Error: not a git repo" >&2; exit 2
fi

PREVIEW="git show --color=always {1}"

if [ "$(printenv XDG_SESSION_TYPE)" = wayland ]; then
        COPY='wl-copy {1}'
elif [ "$(printenv XDG_SESSION_TYPE)" = x11 ]; then
        COPY='xclip -i -selection clipboard {1}'
else 
        COPY="printf '%s\n' {1}"
fi

git log --oneline | fzf \
        --delimiter=' ' \
        --preview="$PREVIEW" --preview-label="[commit diff]" \
        --header="$(printf '%s\n' 'enter:copy' "$FZF_DEFAULT_HEADER")" \
        --bind="enter:become:$COPY"
