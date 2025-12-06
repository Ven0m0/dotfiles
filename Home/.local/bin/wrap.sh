#!/bin/bash
set -euo pipefail; shopt -s nullglob globstar extglob; IFS=$'\n\t' LC_ALL=C LANG=C
# ffzap/ffmpeg wrapper: prefer ffzap, fallback to ffmpeg; uniform CLIs
ffwrap(){
  if command -v ffzap &>/dev/null; then
    ffzap "$@"
  elif command -v ffmpeg &>/dev/null; then
    ffmpeg -hide_banner "$@"
  else
    printf 'error: neither ffzap nor ffmpeg found in PATH\n' >&2
    return 1
  fi
}
jqwrap(){
  if command -v jaq &>/dev/null; then
    # --raw-input short: -R; --slurp: -s; --null-input: -n; all work the same in jaq, pass through
    jaq "$@"
  elif command -v jq &>/dev/null; then
    jq "$@"
  else
    printf 'error: neither jq nor jaq found in PATH\n' >&2
    return 1
  fi
}
