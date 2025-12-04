#!/usr/bin/env zsh
[[ $- != *i* ]] && return

# --- Helpers
has(){ command -v -- "$1" &>/dev/null; }
ifsource(){ [[ -f $1 ]] && source "$1"; }

# --- Environment (early)
export EDITOR=micro VISUAL=code PAGER=bat
export TERM=xterm-256color CLICOLOR=1 MICRO_TRUECOLOR=1
export KEYTIMEOUT=1 TZ=Europe/Berlin
export LANG=C.UTF-8 LC_ALL=C.UTF-8
export HISTFILE=$HOME/.zsh_history HISTSIZE=10000 SAVEHIST=10000
export GPG_TTY=$TTY

# --- Paths
typeset -gU path fpath
path=($HOME/{. local,}/bin $HOME/. cargo/bin /usr/local/{,s}bin /usr/{,s}bin)
export PATH XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config} \
  XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/. cache} \
  XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/. local/share} \
  ZDOTDIR=$XDG_CONFIG_HOME/zsh

# --- Instant Prompt (p10k)
ifsource "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"

# --- Zim Framework
export ZIM_HOME=${XDG_DATA_HOME}/zim
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  mkdir -p ${ZIM_HOME} && command curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
    https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init. zsh

# --- Options
setopt EXTENDED_GLOB NULL_GLOB GLOB_DOTS NO_GLOBAL_RCS
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT PUSHD_TO_HOME
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS INC_APPEND_HISTORY EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS SHARE_HISTORY HIST_EXPIRE_DUPS_FIRST
setopt NO_BEEP NO_HIST_BEEP NO_CLOBBER NOTIFY LIST_PACKED AUTO_LIST AUTO_MENU
setopt COMPLETE_IN_WORD ALWAYS_TO_END

unsetopt MENU_COMPLETE FLOW_CONTROL

# --- Completion (post-zim)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':fzf-tab:complete:*' fzf-preview 'bat -n --color=always $realpath 2>/dev/null || eza -1 --color=always $realpath'

# --- Tools Init (lazy)
has zoxide && eval "$(zoxide init zsh)" && alias cd=z
has mise && eval "$(mise activate zsh)"
has fzf && eval "$(fzf --zsh)"

# --- Aliases & Functions
has eza && alias ls='eza --git --icons -F --group-directories-first --time-style=long-iso'
has eza && alias ll='ls -alh' || alias ll='ls -alh'
mkcd(){ mkdir -p "$1" && cd "$1"; }

# --- Keybindings (post-plugins)
bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[Z' reverse-menu-complete

# --- Fun (RPS1)
if has mommy; then
  export MOMMY_COLOR="" MOMMY_PREFIX="%F{005}/%F{006}" MOMMY_SUFFIX="~%f" MOMMY_COMPLIMENTS_ENABLED=0
  setopt PROMPT_SUBST
  RPS1='$(mommy -1 -s $? )'
fi

# --- Theme (p10k last)
[[ -f ~/. p10k.zsh ]] && source ~/.p10k.zsh
