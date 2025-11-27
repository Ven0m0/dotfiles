has bat || return
# https://github.com/ethanjli/dotfiles/blob/master/dot_config/bash/integrations/20-bat.basic.sh
LESS_TERMCAP_md=$'\e[01;31m' LESS_TERMCAP_me=$'\e[0m' LESS_TERMCAP_us=$'\e[01;32m' LESS_TERMCAP_ue=$'\e[0m' LESS_TERMCAP_so=$'\e[45;93m' LESS_TERMCAP_se=$'\e[0m'
LESS='less -RFKQiqs --use-color --no-histdups --no-edit-warn -Dd+r$Du+b$'
export LESSCHARSET=utf-8 LESSHISTFILE=- LESSQUIET=1 LESS LESS_TERMCAP_md LESS_TERMCAP_me LESS_TERMCAP_us LESS_TERMCAP_ue LESS_TERMCAP_so LESS_TERMCAP_se
if command -v bat &>/dev/null; then
  export PAGER='bat -p' BAT_PAGER="$LESS" MANROFFOPT='-c'
  export BAT_STYLE="-numbers,-header-filename" BATDIFF_USE_DELTA=true BATPIPE=color
  if has batman; then
    export MANPAGER='env BATMAN_IS_BEING_MANPAGER=yes bash /usr/bin/batman'; alias man=batman
  else
    export MANPAGER="sh -c 'col -bx | bat -plman'"
  fi
  if has batpipe; then 
    export LESSOPEN="|/usr/bin/batpipe %s" BATPIPE=color; unset LESSCLOSE
  elif has lesspipe; then
    export LESSOPEN="|/usr/bin/lesspipe.sh %s"
  fi
  alias cat='bat -pp'
fi
export PAGER="${PAGER:-less}"
