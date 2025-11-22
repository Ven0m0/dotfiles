#!/bin/sh
[[ $- != *i* ]] && return

# if running bash
[ -n "$BASH_VERSION" ] && . "$HOME/.bashrc"

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

export EDITOR="${EDITOR:-micro}"
export BROWSER="${BROWSER:-firefox"

export PATH
# FZF tab completions
[ -f "/usr/lib/librl_custom_complete.so" ] && LD_PRELOAD="/usr/lib/librl_custom_complete.so"
