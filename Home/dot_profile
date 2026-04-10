#!/bin/sh
case "$-" in *i*) ;; *) return ;; esac
[ -n "$BASH_VERSION" ] && . "$HOME/.bashrc"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "/usr/local/bin" ] && PATH="/usr/local/bin:$PATH"
export PATH

LD_PRELOAD="${LD_PRELOAD:+$LD_PRELOAD:}$([ -f /usr/lib/librl_custom_complete.so ] && echo /usr/lib/librl_custom_complete.so)"
export EDITOR="${EDITOR:-micro}" BROWSER="${BROWSER:-firefox}" PATH LD_PRELOAD

if [ -n "$ZSH_NAME" ]; then
    CURRENT_SHELL="zsh"
elif [ -n "$BASH_VERSION" ]; then
    CURRENT_SHELL="bash"
else
    CURRENT_SHELL=$(ps -p $$ -o comm=)
fi

LANG="en_US.UTF-8"
if [ -n "$BASH_VERSION" ]; then
  export HISTCONTROL=ignoreboth:erasedups
  shopt -s histappend cmdhist checkwinsize
elif [ -n "$ZSH_NAME" ]; then
  setopt INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS EXTENDED_HISTORY
fi

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

