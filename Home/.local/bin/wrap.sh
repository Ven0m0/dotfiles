#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar extglob; IFS=$'\n\t' LC_ALL=C LANG=C
die(){ printf 'error: %s\n' "$*" >&2; return 1; }
ffwrap(){
  if command -v ffzap &>/dev/null; then
    ffzap "$@"
  elif command -v ffmpeg &>/dev/null; then
    ffmpeg -hide_banner "$@"
  else
    die "neither ffzap nor ffmpeg found in PATH"
  fi
}
jqwrap(){
  if command -v jaq &>/dev/null; then
    jaq "$@"
  elif command -v jq &>/dev/null; then
    jq "$@"
  else
    die "neither jq nor jaq found in PATH"
  fi
}
