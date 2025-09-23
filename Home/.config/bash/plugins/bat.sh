# https://github.com/ethanjli/dotfiles/blob/master/dot_config/bash/integrations/20-bat.basic.sh
if command -v bat &>/dev/null; then
  export MANROFFOPT="-c"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export PAGER='bat -p -s --squeeze-limit 0' BAT_PAGER='less -RFQs --use-color --no-histdups --mouse --wheel-lines=2'
  alias cat='\bat -pp -s --squeeze-limit 0'
  unalias bat
  BAT_STYLE=auto LESSQUIET=1 BATDIFF_USE_DELTA=true BATPIPE=color
  export LESSCHARSET='utf-8' LESSHISTFILE=-
  export LESS_TERMCAP_md=$'\e[01;31m' LESS_TERMCAP_me=$'\e[0m' LESS_TERMCAP_us=$'\e[01;32m' LESS_TERMCAP_ue=$'\e[0m' LESS_TERMCAP_so=$'\e[45;93m' LESS_TERMCAP_se=$'\e[0m'
  if command -v batman &>/dev/null; then
    eval "$(batman --export-env)"
    alias man=batman
  else
    export MANPAGER="sh -c 'col -bx | bat -lman -p -s --squeeze-limit 0'"
  fi
  command -v batpipe &>/dev/null && eval "$(SHELL=bash batpipe)"
else
  alias cat='cat -sn'
  export LESS_TERMCAP_md=$'\e[01;31m' LESS_TERMCAP_me=$'\e[0m' LESS_TERMCAP_us=$'\e[01;32m' LESS_TERMCAP_ue=$'\e[0m' LESS_TERMCAP_so=$'\e[45;93m' LESS_TERMCAP_se=$'\e[0m'
  export LESSHISTFILE=- LESSCHARSET=utf-8 PAGER="${PAGER:-less}" LESS='less -RFQs --use-color --no-histdups --mouse --wheel-lines=2'
fi
