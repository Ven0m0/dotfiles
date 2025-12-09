#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
# Common library functions for ~/.local/bin scripts
# Source: source "${BASH_SOURCE%/*}/.lib.sh" 2>/dev/null || source ~/.local/bin/.lib.sh
set -euo pipefail; shopt -s nullglob globstar
export LC_ALL=C; IFS=$'\n\t'
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
has(){ command -v -- "$1" &>/dev/null; }
date(){ local x="${1:-%d/%m/%y-%R}"; printf "%($x)T\n" '-1'; }
fcat(){ printf '%s\n' "$(<${1})"; }
sleepy(){ read -rt "${1:-1}" -- <> <(:) &>/dev/null || :; }
die(){
  local code="${2:-1}"
  printf '%b[ERROR]%b %s\n' '\e[1;31m' '\e[0m' "$1" >&2
  exit "$code"
}
warn(){ printf '%b[WARN]%b %s\n' '\e[1;33m' '\e[0m' "$*" >&2; }
info(){ printf '%b[INFO]%b %s\n' '\e[1;34m' '\e[0m' "$*"; }
success(){ printf '%b[OK]%b %s\n' '\e[1;32m' '\e[0m' "$*"; }
if [[ -t 1 ]]; then
  RED='\e[1;31m' GREEN='\e[1;32m' YELLOW='\e[1;33m' BLUE='\e[1;34m'
  MAGENTA='\e[1;35m' CYAN='\e[1;36m' WHITE='\e[1;37m'
  BOLD='\e[1m' DIM='\e[2m' RESET='\e[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' WHITE=''
  BOLD='' DIM='' RESET=''
fi
FD=$(has fd && printf fd || printf find)
RG=$(has rg && printf rg || printf grep)
BAT=$(has bat && printf bat || printf cat)
SD=$(has sd && printf sd || printf sed)
JQ=$(has jaq && printf jaq || has jq && printf jq || printf cat)
ARIA2=$(has aria2c && printf aria2c || printf curl)
export FD RG BAT SD JQ ARIA2 RED GREEN YELLOW BLUE MAGENTA CYAN WHITE BOLD DIM RESET
