#!/usr/bin/env bash
# Common library functions for ~/.local/bin scripts
# Source this file: source "${BASH_SOURCE%/*}/.lib.sh" 2>/dev/null || source ~/.local/bin/.lib.sh
# Command availability check
has(){ command -v -- "$1" &>/dev/null; }
# Error handling
die(){
  local exit_code="${2:-1}"
  printf '%b[ERROR]%b %s\n' '\e[1;31m' '\e[0m' "$1" >&2
  exit "$exit_code"
}
# Warning messages
warn(){ printf '%b[WARN]%b %s\n' '\e[1;33m' '\e[0m' "$*" >&2; }
# Info messages
info(){ printf '%b[INFO]%b %s\n' '\e[1;34m' '\e[0m' "$*"; }
# Success messages
success(){ printf '%b[OK]%b %s\n' '\e[1;32m' '\e[0m' "$*"; }
# Color definitions
if [[ -t 1 ]]; then
  RED='\e[1;31m' GREEN='\e[1;32m' YELLOW='\e[1;33m' BLUE='\e[1;34m'
  MAGENTA='\e[1;35m' CYAN='\e[1;36m' WHITE='\e[1;37m'
  BOLD='\e[1m' DIM='\e[2m' RESET='\e[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' WHITE=''
  BOLD='' DIM='' RESET=''
fi
# Preferred modern tool alternatives (fallback to traditional)
FD=$(has fd && printf fd || printf find)
RG=$(has rg && printf rg || printf grep)
BAT=$(has bat && printf bat || printf cat)
SD=$(has sd && printf sd || printf sed)
JQ=$(has jaq && printf jaq || has jq && printf jq || printf cat)
ARIA2=$(has aria2c && printf aria2c || printf curl)
# Export for use in subshells
export FD RG BAT SD JQ ARIA2
export RED GREEN YELLOW BLUE MAGENTA CYAN WHITE BOLD DIM RESET
