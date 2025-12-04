#!/usr/bin/env bash
# summary: a simple posix script for fuzzy searching man pages
# repository: https://github.com/hollowillow/scripts
# usage: fzman
# dependencies: fzf

set -euo pipefail
shopt -s nullglob globstar
export LC_ALL=C LANG=C
IFS=$'\n\t'

# Helper functions
has(){ command -v "$1" &>/dev/null; }
die(){ printf 'ERROR: %s\n' "$*" >&2; exit "${2:-1}"; }

# Tool detection (fuzzy finder: sk → fzf)
if has sk; then FZF=sk; elif has fzf; then FZF=fzf; else FZF=''; fi

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
