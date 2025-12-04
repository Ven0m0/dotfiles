#!/usr/bin/env zsh
[[ $- != *i* ]] && return

# --- Helpers
has() { command -v -- "$1" &>/dev/null; }
ifsource() { [[ -f $1 ]] && source "$1"; }

# --- Instant Prompt
ifsource "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# --- Fun
if has mommy; then
  export MOMMY_COLOR="" MOMMY_PREFIX="%F{005}/%F{006}" MOMMY_SUFFIX="~%f" MOMMY_COMPLIMENTS_ENABLED=0
  setopt PROMPT_SUBST
  RPS1='$(mommy -1 -s $?)'
fi

# --- Options
setopt EXTENDED_GLOB NULL_GLOB GLOB_DOTS NO_GLOBAL_RCS 
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT PUSHD_TO_HOME
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS INC_APPEND_HISTORY EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS SHARE_HISTORY HIST_EXPIRE_DUPS_FIRST
setopt NO_BEEP NO_HIST_BEEP NO_CLOBBER NOTIFY LIST_PACKED AUTO_LIST AUTO_MENU
setopt COMPLETE_IN_WORD ALWAYS_TO_END

unsetopt MENU_COMPLETE FLOW_CONTROL

# --- Environment
export EDITOR=micro VISUAL=code PAGER=bat
export TERM=xterm-256color CLICOLOR=1 MICRO_TRUECOLOR=1
export KEYTIMEOUT=1 TZ=Europe/Berlin
export LANG=C.UTF-8 LC_ALL=C.UTF-8
export HISTFILE=$HOME/.zsh_history HISTSIZE=10000 SAVEHIST=10000
export GPG_TTY=$TTY

# --- Paths
typeset -gU path fpath
path=($HOME/{.local,}/bin $HOME/.cargo/bin /usr/local/{,s}bin /usr/{,s}bin)
export PATH XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config} \
  XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache} \
  XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share} \
  ZDOTDIR=$XDG_CONFIG_HOME/zsh 
  
# --- Antidote (Plugin Manager)
antidote_dir=${XDG_DATA_HOME}/antidote
zsh_plugins=${ZDOTDIR}/config/plugins.txt
zsh_bundle=${XDG_CACHE_HOME}/zsh/antidote_plugins.zsh

if [[ ! -d $antidote_dir ]]; then
  git clone --depth=1 https://github.com/mattmc3/antidote "$antidote_dir"
fi

if [[ -f $zsh_plugins ]]; then
  source "$antidote_dir/antidote.zsh"
  antidote load "$zsh_plugins"
fi

# --- Completion
autoload -Uz compinit
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# Cache compinit for 24h
typeset -i updated_at=$(date +'%j' -r "$XDG_CACHE_HOME/.zcompdump" 2>/dev/null || echo 0)
if [ $(date +'%j') != $updated_at ]; then
  compinit -d "$XDG_CACHE_HOME/.zcompdump"
else
  compinit -C -d "$XDG_CACHE_HOME/.zcompdump"
fi

# --- Tools Init (Lazy/Cached)
has zoxide && eval "$(zoxide init zsh)" && alias cd=z
has mise && eval "$(mise activate zsh)"
has fzf && eval "$(fzf --zsh)"

# --- Aliases & Functions
has eza && alias ls='eza --git --icons -F --group-directories-first --time-style=long-iso'
has eza && alias ll='ls -alh' || alias ll='ls -alh'
mkcd(){ mkdir -p "$1" && cd "$1"; }

# --- Keybindings
bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[Z' reverse-menu-complete

# --- Theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
