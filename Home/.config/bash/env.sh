#!/usr/bin/env bash
#–– Colors
# Pre-gen common colors
declare -rA _c=([def]=0 [bld]=1 [dim]=2 [und]=4 [inv]=7 [hid]=8 \
  [blk]=30 [red]=31 [grn]=32 [ylw]=33 [blu]=34 [mgn]=35 [cyn]=36 [wht]=37)
for c in "${!_c[@]}"; do
  printf -v ${c^^} '\e[%sm' ${_c[$c]}
  printf -v B_${c^^} '\e[%sm' $((60+_c[$c]))
  printf -v BG_${c^^} '\e[%sm' $((40+_c[$c]))
done
# Function for 256-colors only
C(){ printf '\e[%d;5;%sm' $([[ $1 == bg_* ]] && echo 48 || echo 38) ${1#*_}; }
