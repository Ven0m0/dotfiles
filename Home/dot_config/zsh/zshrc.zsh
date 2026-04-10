#!/usr/bin/env zsh
# shellcheck shell=bash
# ============================================================================
# Zsh Main Config - Fish-Like & Modular
# ============================================================================
[[ $- != *i* ]] && return

# ---[ Helpers ]---
has(){ command -v -- "$1" &>/dev/null; }
ifsrc(){ [[ -f $1 ]] && source "$1"; }

# ---[ P10k Instant Prompt ]---
ifsrc "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# ---[ XDG Directories ]---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export ZDOTDIR="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"

# ---[ Antidote Init ]---
ANTIDOTE_DIR="${XDG_DATA_HOME}/antidote"
if [[ ! -d $ANTIDOTE_DIR ]]; then
  git clone --depth=1 https://github.com/mattmc3/antidote.git "$ANTIDOTE_DIR"
fi
source "${ANTIDOTE_DIR}/antidote.zsh"
# Load plugins and generate static file if needed
if [[ ! "$ZDOTDIR/plugins.zsh" -nt "$ZDOTDIR/config/plugins.txt" ]]; then
  antidote bundle <"$ZDOTDIR/config/plugins.txt" >"$ZDOTDIR/plugins.zsh"
fi
source "$ZDOTDIR/plugins.zsh"

# ---[ Zsh Options ]---
setopt EXTENDED_GLOB NULL_GLOB GLOB_DOTS NO_GLOBAL_RCS
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT PUSHD_TO_HOME CD_SILENT
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS INC_APPEND_HISTORY EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS SHARE_HISTORY HIST_EXPIRE_DUPS_FIRST
setopt COMPLETE_IN_WORD ALWAYS_TO_END AUTO_LIST AUTO_MENU LIST_PACKED
setopt NO_BEEP NO_HIST_BEEP NO_CLOBBER NOTIFY INTERACTIVE_COMMENTS
unsetopt MENU_COMPLETE FLOW_CONTROL

# ---[ Environment ]---
export EDITOR=micro VISUAL=code PAGER=bat
export TERM=xterm-256color CLICOLOR=1 MICRO_TRUECOLOR=1
export KEYTIMEOUT=1 TZ=Europe/Berlin LANG=C.UTF-8 LC_ALL=C.UTF-8 GPG_TTY=$TTY
export HISTFILE="${HISTFILE:-$HOME/.zsh_history}" HISTSIZE=50000 SAVEHIST=50000

# ---[ Path ]---
typeset -gU path fpath
path=(~/.local/bin ~/.cargo/bin /usr/local/{bin,sbin} /usr/{bin,sbin})
fpath=("$ZDOTDIR/completions" "$XDG_DATA_HOME/zsh/completions" $fpath)

# ---[ Keybindings ]---
bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey '^[[Z' reverse-menu-complete
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^W' backward-kill-word
bindkey '^H' backward-delete-char
autoload -U select-word-style && select-word-style bash

# ---[ Deferred Init ]---
if has zsh-defer; then
  has zoxide && zsh-defer -c 'eval "$(zoxide init --cmd cd zsh)"'
  has mise && zsh-defer -c 'eval "$(mise activate zsh)"'
  has fzf && zsh-defer -c 'eval "$(fzf --zsh)"'
else
  has zoxide && eval "$(zoxide init --cmd cd zsh)"
  has mise && eval "$(mise activate zsh)"
  has fzf && eval "$(fzf --zsh)"
fi

# ---[ Load Modular Configs ]---
ifsrc "$ZDOTDIR/config/completions.zsh"
ifsrc "$ZDOTDIR/config/aliases.zsh"
ifsrc "$ZDOTDIR/config/functions.zsh"

# ---[ Theme ]---
ifsrc ~/.p10k.zsh

# ---[ Local Overrides ]---
ifsrc "$ZDOTDIR/local.zsh"

# vim: set ft=zsh ts=2 sw=2 et:
