#!/usr/bin/env zsh
# ~/.zshenv - Minimal environment setup that runs for all shells

# Skip global compinit for speed
skip_global_compinit=1
setopt no_global_rcs

# ──────────── XDG Base Directory Specification ────────────
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}"

# ──────────── ZSH Configuration ────────────
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"
export ZSH_COMPDUMP="${ZSH_CACHE_DIR}/.zcompdump"

# Create cache directory if it doesn't exist
[[ ! -d "$ZSH_CACHE_DIR" ]] && mkdir -p "$ZSH_CACHE_DIR"

# ──────────── History ────────────
export HISTFILE="${XDG_STATE_HOME}/zsh/history"
export HISTSIZE=50000
export SAVEHIST=50000

# Create history directory if it doesn't exist
[[ ! -d "${HISTFILE:h}" ]] && mkdir -p "${HISTFILE:h}"

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

# ──────────── Path Configuration ────────────
# Preload common paths
path=(
   $HOME/{.local/,.}bin(N)
  "$HOME/.cargo/bin"
  "$HOME/.npm-global/bin"
  /usr/local/bin
  /usr/bin
  /bin
  /usr/local/sbin
  /usr/sbin
  /sbin
  $path
)
export PATH
typeset -U path

