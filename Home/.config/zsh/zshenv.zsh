#!/usr/bin/env zsh
# ~/.zshenv - Minimal environment setup that runs for all shells

# Skip global compinit for speed
skip_global_compinit=1
setopt no_global_rcs

# Detect platform early
if [[ -d "/data/data/com.termux" ]]; then
  export TERMUX=1 ANDROID=1
else
  export TERMUX=0 ANDROID=0
fi

# Enable zsh compiler for faster startup
if [[ -f $HOME/.zshrc.zwc ]]; then
  # Use compiled .zshrc if newer than the source
  if [[ $HOME/.zshrc -nt $HOME/.zshrc.zwc ]]; then
    zcompile $HOME/.zshrc
  fi
else
  # Create compiled version if it doesn't exist
  zcompile $HOME/.zshrc
fi
# Preload common paths to speed up command resolution
path=(
  $HOME/{.local/,.}bin(N)
  $path
)
typeset -U path
