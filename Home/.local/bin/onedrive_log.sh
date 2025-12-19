#!/usr/bin/env bash
# shellcheck disable=SC2310
# shellcheck source=../lib/bash-common.sh
# onedrive_log - Colorized OneDrive sync log viewer
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s
source "${s%/bin/*}/lib/bash-common.sh"
init_strict
# Check dependencies
req journalctl
req sed
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

# Color definitions - use ANSI directly (faster than tput)
readonly blue=$C_BLUE
readonly magenta=$C_MAGENTA
readonly yellow=$C_YELLOW
readonly normal=$C_RESET
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
