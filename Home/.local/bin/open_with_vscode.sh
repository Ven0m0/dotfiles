#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C LANG=C
# Open files/URIs in VS Code
# Source: https://github.com/AhmetCanArslan/linux-scripts
has() { command -v "$1" &>/dev/null; }
die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}
usage() {
  cat <<'EOF'
open_with_vscode - Open files/URIs in VS Code

USAGE:
  open_with_vscode FILE|URI [FILE|URI...]

ARGUMENTS:
  FILE|URI   File path or file:// URI to open

OPTIONS:
  -h, --help Show this help message

DESCRIPTION:
  Opens files or URIs in VS Code. Automatically decodes file:// URIs
  and URL-encoded spaces (%20).

EXAMPLES:
  open_with_vscode /path/to/file.txt
  open_with_vscode file:///path/to/file.txt
  open_with_vscode file:///path/with%20spaces/file.txt

REQUIREMENTS:
  - code (VS Code CLI command)
EOF
}
main() {
  # Check for help
  [[ ${#} -eq 0 ]] && die "Usage: ${0##*/} <file|uri...>"
  for arg in "$@"; do
    if [[ $arg == -h || $arg == --help ]]; then
      usage
      exit 0
    fi
  done
  # Check for VS Code
  has code || die "VS Code (code) is not installed"
  # Open each file/URI
  for uri in "$@"; do
    # Decode file:// URIs and URL-encoded spaces
    path="${uri#file://}"
    path="${path//%20/ }"
    if code --new-window "$path"; then
      printf 'Opened: %s\n' "$path"
    else
      printf 'Failed to open: %s\n' "$path" >&2
    fi
  done
}
main "$@"
