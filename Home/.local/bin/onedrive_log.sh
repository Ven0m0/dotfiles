#!/usr/bin/env bash
# onedrive_log - Colorized OneDrive sync log viewer
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'
export LC_ALL=C LANG=C
has(){ command -v "$1" &>/dev/null; }
die(){
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

# Check dependencies
has journalctl || die "journalctl is required"
has sed || die "sed is required"
# Optional dependencies
has ag || has grep || die "ag or grep is required"
has ccze && use_ccze=1 || use_ccze=0

# Color definitions using tput for portability
readonly blue=$(tput setaf 4 2>/dev/null || echo '')
readonly magenta=$(tput setaf 5 2>/dev/null || echo '')
readonly yellow=$(tput setaf 3 2>/dev/null || echo '')
readonly normal=$(tput sgr0 2>/dev/null || echo '')

unit="${1:-onedrive}"
# Stream journal output with colorization
# Use -F for fixed-string matching (faster than regex)
journalctl -o cat --user-unit "$unit" -f 2>/dev/null |
  (has ag && ag -v 'Remaining free space' || grep -vF 'Remaining free space') |
  sed -u "s/Uploading/${blue}Uploading${normal}/;
          s/Successfully created/${blue}Successfully created${normal}/;
          s/Downloading/${magenta}Downloading${normal}/;
          s/Moving/${magenta}Moving${normal}/;
          s/Deleting/${yellow}Deleting${normal}/;
          s/deleted/${yellow}deleted${normal}/gI;" |
  if ((use_ccze)); then
    ccze -A -c default=white
  else
    cat
  fi
