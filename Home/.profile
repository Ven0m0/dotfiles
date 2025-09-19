#!/bin/sh
# ~/.profile

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi
# Add cargo binaries to path if it exits
if [ -e "$HOME/.cargo/env" ]; then
	. "$HOME/.cargo/env"
fi

# FZF tab completions
if [ -f "/usr/lib/librl_custom_complete.so" ]; then
  export LD_PRELOAD="/usr/lib/librl_custom_complete.so"
fi
