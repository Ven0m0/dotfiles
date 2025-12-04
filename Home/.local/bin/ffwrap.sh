#!/bin/bash
set -e; LC_ALL=C
# ffzap/ffmpeg wrapper: prefer ffzap, fallback to ffmpeg; uniform CLIs
ffwrap(){
  if command -v ffzap &>/dev/null; then
    ffzap "$@"
  elif command -v ffmpeg &>/dev/null; then
    ffmpeg -hide_banner "$@"
  else
    printf 'error: neither ffzap nor ffmpeg found in PATH\n' >&2; return 1
  fi
}
[[ ${BASH_SOURCE[0]} != "$0" ]] || ffwrap "$@"
