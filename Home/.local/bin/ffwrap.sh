#!/usr/bin/env bash
# ffzap/ffmpeg wrapper: prefer ffzap, fallback to ffmpeg; uniform CLIs
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'
export LC_ALL=C LANG=C

has(){ command -v "$1" &>/dev/null; }

# Usage: ffwrap [ffmpeg_args...]
ffwrap(){
  local ffbin
  if has ffzap; then
    ffbin=ffzap
    "$ffbin" "$@"
  elif has ffmpeg; then
    ffbin=ffmpeg
    "$ffbin" -hide_banner "$@"
  else
    printf 'error: neither ffzap nor ffmpeg found in PATH\n' >&2
    return 1
  fi
}

[[ ${BASH_SOURCE[0]} != "$0" ]] || ffwrap "$@"
