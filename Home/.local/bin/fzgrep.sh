#!/usr/bin/env bash
#
# script: fzgrep
# description: a simple, extensible, POSIX compliant fuzzy grep searching shell script
# dependencies: fzf, bat(can be changed to cat but looses syntax highlighting), ripgrep, vim/nvim(make sure you have $EDITOR set)
# github: https://github.com/hollowillow/scripts
#
# DEFAULT KEYMAPS
# enter: open $EDITOR on line and column of query
# ctrl-o: open $EDITOR on line and column of query, keeps fzf open in background
# tab: select
# ctrl-a: select all
# ctrl-d: unselect all
# ctrl-t: toggle preview window
set -euo pipefail

if [[ "${*:-}" == "-h" ]]; then
    cat <<'EOF'
fzgrep is a simple, extensible, POSIX compliant fuzzy grep searching shell script
Github: https://github.com/hollowillow/scripts

Usage: fzgrep [options] [arguments]

OPTIONS
    -h    Display this help message

EXAMPLES
    fzgrep              Opens up fzf and let's you grep search through any files in current directory
    fzgrep string       Uses the 'string' argument as the initial fzf query
EOF
    exit 0
fi

# fzf variables: {1} = filename, {2} = line, {3} = column, {4} = line contents
readonly PREVIEW='bat --style=full --color=always --theme=ansi --highlight-line {2} {1}'
readonly RELOAD='reload:rg --vimgrep --color=always --smart-case {q} || :'
readonly OPEN='if [ "$FZF_SELECT_COUNT" -eq 0 ]; then "${EDITOR:-vim}" "+call cursor({2},{3})" {1}; else "${EDITOR:-vim}" +cw -q {+f}; fi'

fzf \
    --disabled -m --delimiter=":" \
    --ansi --color=16 \
    --bind "start:$RELOAD" --bind "change:$RELOAD" \
    --bind "enter:become:$OPEN" --bind "ctrl-o:execute:$OPEN" \
    --bind 'ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-preview' \
    --preview="$PREVIEW" --preview-label="[file preview]" \
    --with-nth="1,4" \
    --query="$*"
