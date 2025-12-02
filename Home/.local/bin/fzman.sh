#!/usr/bin/env bash
# summary: a simple posix script for fuzzy searching man pages
# repository: https://github.com/hollowillow/scripts
# usage: fzman
# dependencies: fzf

# Source shared library (with fallback for standalone operation)
# shellcheck source=../lib/bash/stdlib.bash
if [[ -r "${HOME}/.local/lib/bash/stdlib.bash" ]]; then
  . "${HOME}/.local/lib/bash/stdlib.bash"
elif [[ -r "$(dirname "$(realpath "$0")")/../lib/bash/stdlib.bash" ]]; then
  . "$(dirname "$(realpath "$0")")/../lib/bash/stdlib.bash"
else
  set -euo pipefail
  shopt -s nullglob globstar
  export LC_ALL=C LANG=C
fi

IFS=$'\n\t'

if [[ ${1:-} == "-h" ]]; then
  sed "1,2d;s/^# //;s/^#$/ /;/^$/ q" "$0"
  exit 0
fi

readonly PREVIEW='man {1}'

[[ -n ${FZF:-} ]] || die "No fuzzy finder (fzf/sk) found"

man -k . | "$FZF" \
  --prompt='manual: ' \
  --header="$(printf '%s\n' 'enter:open' "${FZF_DEFAULT_HEADER:-}")" \
  --delimiter=' ' \
  --with-nth='1,2' \
  --preview="$PREVIEW" \
  --bind="enter:become:$PREVIEW"
