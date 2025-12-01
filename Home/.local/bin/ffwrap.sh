#!/usr/bin/env bash
# ffzap/ffmpeg wrapper: prefer ffzap, fallback to ffmpeg; uniform CLIs
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'
export LC_ALL=C LANG=C

# Usage: ffwrap [ffmpeg_args...]
ffwrap() {
  local ffbin
  if command -v ffzap &>/dev/null; then
    ffbin=ffzap
    "$ffbin" "$@"
  elif command -v ffmpeg &>/dev/null; then
    ffbin=ffmpeg
    "$ffbin" -hide_banner "$@"
  else
    printf 'error: neither ffzap nor ffmpeg found in PATH\n' >&2
    return 1
  fi
}

[[ "${BASH_SOURCE[0]}" != "$0" ]] || ffwrap "$@"
