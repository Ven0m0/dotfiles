#!/usr/bin/env bash
# open_with_vscode - Open files/URIs in VS Code
# Source: https://github.com/AhmetCanArslan/linux-scripts
set -euo pipefail
export LC_ALL=C LANG=C

has(){ command -v "$1" &>/dev/null; }
die(){ printf 'Error: %s\n' "$*" >&2; exit 1; }

has code || die "VS Code (code) is not installed"

[[ $# -eq 0 ]] && die "Usage: ${0##*/} <file|uri...>"

for uri in "$@"; do
  # Decode file:// URIs and URL-encoded spaces
  path="${uri#file://}"
  path="${path//%20/ }"

  code --new-window "$path" || printf 'Failed to open: %s\n' "$path" >&2
done
