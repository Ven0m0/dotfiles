#!/usr/bin/env zsh
# ============================================================================
# Zsh Configuration - Optimized with Zimfw
# ============================================================================
# Exit if non-interactive
[[ $- != *i* ]] && return

# ---[ Helper Functions ]---
has(){ command -v -- "$1" &>/dev/null; }
ifsource(){ [[ -f $1 ]] && source "$1"; }

# ---[ Instant Prompt (P10k) ]---
ifsource "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# ---[ XDG Base Directories ]---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export ZDOTDIR="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"

# ---[ Zimfw Initialization ]---
ZIM_HOME="${XDG_DATA_HOME}/zim"

# Download zimfw if missing
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  mkdir -p "${ZIM_HOME}" && LC_ALL=C git clone --depth=1 --filter=blob:none https://github.com/zimfw/zimfw.git "${ZIM_HOME}"
fi

# Install plugins if missing
[[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]] && source "${ZIM_HOME}/zimfw.zsh" init -q
# Initialize modules
source "${ZIM_HOME}/init.zsh"

# ---[ Zsh Options ]---
# Globbing
setopt EXTENDED_GLOB NULL_GLOB GLOB_DOTS NO_GLOBAL_RCS
# Directory Navigation
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT PUSHD_TO_HOME CD_SILENT
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
  ${HOME}/.local/bin
  ${HOME}/.cargo/bin
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
zstyle ':fzf-tab:complete:cd:*' popup-pad 20 0

# History substring search configuration
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# Misc
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*' insert-tab false
zstyle ':completion:*' insert-unambiguous false
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' original true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' verbose true
zstyle ':completion:*' special-dirs ..

# ---[ Tool Initialization - Optimized ]---
# Check for zsh-defer availability
if has zsh-defer; then
  # Defer expensive initializations for faster startup
  # Zoxide (smart cd) - deferred
  has zoxide && zsh-defer -c 'eval "$(zoxide init --cmd cd zsh)"'
  # Mise (version manager) - deferred
  has mise && zsh-defer -c 'eval "$(mise activate zsh)"'
  # FZF (fuzzy finder) - deferred
  has fzf && zsh-defer -c 'eval "$(fzf --zsh)"'
  # Mommy prompt - deferred (optional fun)
  if has mommy; then
    zsh-defer -c '
      export MOMMY_COLOR="" MOMMY_PREFIX="%F{005}/%F{006}" MOMMY_SUFFIX="~%f" MOMMY_COMPLIMENTS_ENABLED=0
      setopt PROMPT_SUBST
      RPS1='\''$(mommy -1 -s $?)'\''
    '
  fi
else
  # Fallback without zsh-defer
  if has zoxide; then
    eval "$(zoxide init --cmd cd zsh)"
  fi
  has mise && eval "$(mise activate zsh)"
  has fzf && eval "$(fzf --zsh)"
  if has mommy; then
    export MOMMY_COLOR="" MOMMY_PREFIX="%F{005}/%F{006}" MOMMY_SUFFIX="~%f"
    export MOMMY_COMPLIMENTS_ENABLED=0
    setopt PROMPT_SUBST
    RPS1='$(mommy -1 -s $?)'
  fi
fi

# ---[ Lazy-loaded Commands ]---
# Use lazyload for rarely-used or expensive commands
if has lazyload; then
  # Example: lazy-load docker commands
  has docker && lazyload docker -- 'source <(docker completion zsh)'
  has docker-compose && lazyload docker-compose -- 'source <(docker-compose completion zsh)'
fi

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

alias ffmpeg="ffmpeg -hide_banner"
alias ffprobe="ffprobe -hide_banner"

# Common shortcuts
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'

# ---[ Functions ]---
# Make directory and cd into it
mkcd(){ mkdir -p "$1" && cd "$1"; }

# Quick edit zsh config
zshrc(){ ${EDITOR:-nano} "${ZDOTDIR:-$HOME}/.zshrc" && source "${ZDOTDIR:-$HOME}/.zshrc"; }

# Reload zsh configuration
reload(){ source "${ZDOTDIR:-$HOME}/.zshrc"; }

# Update zimfw and plugins
zimupdate(){ zimfw update && zimfw upgrade; }

# ---[ Keybindings ]---
bindkey -e  # Emacs mode
bindkey '^[[Z' reverse-menu-complete  # Shift+Tab

# Bash-like shortcuts
bindkey '^[[1;5C' forward-word  # Ctrl + Right
bindkey '^[[1;5D' backward-word # Ctrl + Left
# ^w for delete backward until a space
# ^backspace for delete backward until a word delimiter
autoload -U select-word-style
select-word-style bash
bindkey '^W' backward-delete-word
bindkey '^H' backward-kill-word

# ---[ Theme (Powerlevel10k) ]---
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ---[ Local Overrides ]---
ifsource "${ZDOTDIR}/local.zsh"
