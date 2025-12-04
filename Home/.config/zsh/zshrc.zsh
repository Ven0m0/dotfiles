#!/usr/bin/env zsh
# ============================================================================
# Zsh Configuration - Optimized with Zimfw
# ============================================================================

# Exit if non-interactive
[[ $- != *i* ]] && return

# ---[ Helper Functions ]---
has() { command -v -- "$1" &>/dev/null; }
ifsource() { [[ -f $1 ]] && source "$1"; }

# ---[ Instant Prompt (P10k) ]---
ifsource "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# ---[ XDG Base Directories ]---
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export ZDOTDIR=${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}

# ---[ Zimfw Initialization ]---
ZIM_HOME=${XDG_DATA_HOME}/zim

# Download zimfw if missing
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  mkdir -p "${ZIM_HOME}" && command git clone --depth=1 https://github.com/zimfw/zimfw.git "${ZIM_HOME}"
fi

# Install plugins if missing
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source "${ZIM_HOME}/zimfw.zsh" init -q
fi

# Initialize modules
source "${ZIM_HOME}/init.zsh"

# ---[ Zsh Options ]---
# Globbing
setopt EXTENDED_GLOB NULL_GLOB GLOB_DOTS NO_GLOBAL_RCS

# Directory Navigation
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT PUSHD_TO_HOME

# History
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS INC_APPEND_HISTORY
setopt EXTENDED_HISTORY HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY HIST_EXPIRE_DUPS_FIRST

# Completion
setopt COMPLETE_IN_WORD ALWAYS_TO_END AUTO_LIST AUTO_MENU LIST_PACKED

# Other
setopt NO_BEEP NO_HIST_BEEP NO_CLOBBER NOTIFY

# Unset problematic options
unsetopt MENU_COMPLETE FLOW_CONTROL

# ---[ Environment Variables ]---
export EDITOR=micro VISUAL=code PAGER=bat
export TERM=xterm-256color CLICOLOR=1 MICRO_TRUECOLOR=1
export KEYTIMEOUT=1 TZ=Europe/Berlin
export LANG=C.UTF-8 LC_ALL=C.UTF-8
export GPG_TTY=$TTY

# History settings
export HISTFILE=${HISTFILE:-$HOME/.zsh_history}
export HISTSIZE=50000 SAVEHIST=50000

# ---[ Path Configuration ]---
typeset -gU path fpath
path=(
  $HOME/.local/bin
  $HOME/bin
  $HOME/.cargo/bin
  /usr/local/bin
  /usr/local/sbin
  /usr/bin
  /usr/sbin
)

# ---[ Completion Styles ]---
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME}/zsh/zcompcache"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'

# FZF completion style
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# History substring search configuration
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# ---[ Tool Initialization ]---
# Zoxide (smart cd)
if has zoxide; then
  eval "$(zoxide init zsh)"
  alias cd=z
fi

# Mise (version manager)
has mise && eval "$(mise activate zsh)"

# FZF (fuzzy finder)
has fzf && eval "$(fzf --zsh)"

# ---[ Aliases ]---
# Modern replacements
if has eza; then
  alias ls='eza --git --icons -F --group-directories-first --time-style=long-iso'
  alias ll='eza --git --icons -F --group-directories-first --time-style=long-iso -alh'
  alias la='eza --git --icons -F --group-directories-first --time-style=long-iso -a'
  alias lt='eza --git --icons -F --group-directories-first --time-style=long-iso -T'
else
  alias ll='ls -alh'
  alias la='ls -A'
fi

has bat && alias cat='bat --style=plain --paging=never'
has rg && alias grep='rg'
has fd && alias find='fd'

# Common shortcuts
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'

# ---[ Functions ]---
# Make directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Quick edit zsh config
zshrc() {
  ${EDITOR:-nano} "${ZDOTDIR:-$HOME}/.zshrc" && source "${ZDOTDIR:-$HOME}/.zshrc"
}

# Reload zsh configuration
reload() {
  source "${ZDOTDIR:-$HOME}/.zshrc"
}

# ---[ Keybindings ]---
bindkey -e  # Emacs mode
bindkey '^[[Z' reverse-menu-complete  # Shift+Tab

# ---[ Mommy (optional fun) ]---
if has mommy; then
  export MOMMY_COLOR="" MOMMY_PREFIX="%F{005}/%F{006}" MOMMY_SUFFIX="~%f"
  export MOMMY_COMPLIMENTS_ENABLED=0
  setopt PROMPT_SUBST
  RPS1='$(mommy -1 -s $?)'
fi

# ---[ Theme (Powerlevel10k) ]---
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ---[ Local Overrides ]---
ifsource "${ZDOTDIR}/local.zsh"
