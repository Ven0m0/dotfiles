#!/usr/bin/env bash
# shellcheck disable=SC2310
# onedrive_log - Colorized OneDrive sync log viewer
set -euo pipefail;shopt -s nullglob globstar;IFS=$'\n\t'
export LC_ALL=C LANG=C
has(){ command -v "$1" &>/dev/null; }
die(){ printf 'Error: %s\n' "$*" >&2; exit 1; }
# Check dependencies
if ! has journalctl; then
  die "journalctl is required"
fi
if ! has sed; then
  die "sed is required"
fi
# Optional dependencies
if ! has ag && ! has grep; then
  die "ag or grep is required"
fi
if has ccze; then
  use_ccze=1
else
  use_ccze=0
fi
if has ag; then
  filter_cmd=(ag -v 'Remaining free space')
else
  filter_cmd=(grep -vF 'Remaining free space')
fi

# Color definitions using ANSI escape codes (faster than tput)
readonly blue=$'\e[34m'
readonly magenta=$'\e[35m'
readonly yellow=$'\e[33m'
readonly normal=$'\e[0m'
unit="${1:-onedrive}"
# Stream journal output with colorization
# Use -F for fixed-string matching (faster than regex)
journalctl -o cat --user-unit "$unit" -f 2>/dev/null \
  | "${filter_cmd[@]}" \
  | sed -u "s/Uploading/${blue}Uploading${normal}/;
          s/Successfully created/${blue}Successfully created${normal}/;
          s/Downloading/${magenta}Downloading${normal}/;
          s/Moving/${magenta}Moving${normal}/;
          s/Deleting/${yellow}Deleting${normal}/;
          s/deleted/${yellow}deleted${normal}/gI;" \
  | if ((use_ccze)); then
    ccze -A -c default=white
  else
    cat
  fi
