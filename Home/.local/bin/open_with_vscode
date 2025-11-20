#!/usr/bin/env bash
# open_with_vscode - Open files/URIs in VS Code
# Source: https://github.com/AhmetCanArslan/linux-scripts
set -euo pipefail; shopt -s nullglob
LC_ALL=C LANG=C

command -v code &>/dev/null || { printf 'Error: %s\n' "VS Code (code) is not installed" >&2; exit 1; }
[[ $# -eq 0 ]] && die "Usage: ${0##*/} <file|uri...>"
for uri in "$@"; do
  # Decode file:// URIs and URL-encoded spaces
  path="${uri#file://}"
  path="${path//%20/ }"
  code --new-window "$path" || printf 'Failed to open: %s\n' "$path" >&2
done
