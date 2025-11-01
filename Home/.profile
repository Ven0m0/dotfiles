#!/bin/sh
# ~/.profile

# if running bash
if [ -n "$BASH_VERSION" ]; then
  [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
fi

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
# set PATH so it includes user's private bin if it exists
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

export PATH
# FZF tab completions
[ -f "/usr/lib/librl_custom_complete.so" ] && LD_PRELOAD="/usr/lib/librl_custom_complete.so"
