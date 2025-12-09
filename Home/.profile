#!/bin/sh
case "$-" in *i*) ;; *) return ;; esac
[ -n "$BASH_VERSION" ] && . "$HOME/.bashrc"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

LD_PRELOAD="${LD_PRELOAD:+$LD_PRELOAD:}$([ -f /usr/lib/librl_custom_complete.so ] && echo /usr/lib/librl_custom_complete.so)"
export EDITOR="${EDITOR:-micro}" BROWSER="${BROWSER:-firefox}" PATH LD_PRELOAD
