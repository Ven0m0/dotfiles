#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'
LC_ALL=C
LANG=C.UTF-8
TIME_STYLE='+%d-%m %H:%M'
HOME="/home/${SUDO_USER:-$USER}"
builtin cd -- "$(command dirname -- "${BASH_SOURCE[0]:-$0}")" || exit 1
#–– Colors
# A single function to generate any ANSI code on demand
C(){
  local -rA static=(
    [def]=0  [bld]=1  [dim]=2  [und]=4  [inv]=7  [hid]=8
    [blk]=30 [red]=31 [grn]=32 [ylw]=33 [blu]=34 [mgn]=35 [cyn]=36 [wht]=37
  )
  [[ -v "static[$1]" ]] && { printf '\e[%sm' "${static[$1]}"; return; ] # Handle static names (e.g., "red", "bld")
  case "$1" in # Handle dynamic names by pattern (e.g. "b_red", "bg_c_205")
    b_*) [[ -v "static[${1#b_}]" ]] && printf '\e[%sm' "$((60 + static[${1#b_}]))" ;;
    bg_*) [[ -v "static[${1#bg_}]" ]] && printf '\e[%sm' "$((10 + static[${1#bg_}]))" ;;
    b_bg_*) [[ -v "static[${1#b_bg_}]" ]] && printf '\e[%sm' "$((70 + static[${1#b_bg_}]))" ;;
    c_*) printf '\e[38;5;%sm' "${1#c_}" ;;
    bg_c_*) printf '\e[48;5;%sm' "${1#bg_c_}" ;;
  esac
}
#––
command -v dbus-launch &>/dev/null && export "$(dbus-launch)"



jobs="$(command nproc --all 2>/dev/null || echo 4)"
#–– Helpers
