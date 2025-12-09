#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'
command -v neofetch &>/dev/null || exit 1
PATCH_PATH="$HOME/.config/neofetch/neowofetch.patch"
URL="https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Linux-Settings/Home/.config/neofetch/neowofetch.patch"
[[ -f $PATCH_PATH ]] || {
  mkdir -p "${PATCH_PATH%/*}"
  curl -fsSL "$URL" -o "$PATCH_PATH" || {
    echo "Failed to download patch"
    exit 1
  }
}
NEOFETCH_PATH="$(command -v neofetch)"
patch -Np1 "$NEOFETCH_PATH" <"$PATCH_PATH"
