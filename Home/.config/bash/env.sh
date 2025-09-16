#!/usr/bin/env bash
shopt -s nullglob globstar
IFS=$'\n\t'
LC_ALL=C; LANG=C.UTF-8
HOME="/home/${SUDO_USER:-$USER}"
builtin cd -- "$(command dirname -- "${BASH_SOURCE[0]:-$0}")" || exit 1
jobs="$(command nproc --all 2>/dev/null || echo 4)"
#–– Colors
# A single function to generate any ANSI code on demand
C(){
  local -rA s=([def]=0 [bld]=1 [dim]=2 [und]=4 [inv]=7 [hid]=8 \
    [blk]=30 [red]=31 [grn]=32 [ylw]=33 [blu]=34 [mgn]=35 [cyn]=36 [wht]=37)
  local n
  case "$1" in
    b_*) n=${1#b_}; [[ -v s[$n] ]] && printf '\e[%sm' $((60+s[$n])) ;;
    bg_*) n=${1#bg_}; [[ -v s[$n] ]] && printf '\e[%sm' $((10+s[$n])) ;;
    b_bg_*) n=${1#b_bg_}; [[ -v s[$n] ]] && printf '\e[%sm' $((70+s[$n])) ;;
    c_*) printf '\e[38;5;%sm' "${1#c_}" ;;
    bg_c_*) printf '\e[48;5;%sm' "${1#bg_c_}" ;;
    *) [[ -v s[$1] ]] && printf '\e[%sm' "${s[$1]}" ;;
  esac
}
