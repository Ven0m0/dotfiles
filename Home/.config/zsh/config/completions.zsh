#!/usr/bin/env zsh
# ============================================================================
# Zsh Completions - Enhanced Tab Completion
# ============================================================================

# =============================================================================
# COMPLETION SYSTEM INITIALIZATION
# =============================================================================

# Load compinit (only once per day for performance)
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# =============================================================================
# COMPLETION STYLES
# =============================================================================

# Use cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# Case-insensitive, partial-word, and substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Menu selection
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Group matches
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{cyan}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'

# Fuzzy matching
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Sort and order
zstyle ':completion:*' sort true
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# =============================================================================
# COMMAND-SPECIFIC COMPLETIONS
# =============================================================================

# cd: only directories
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# kill/killall: process completion
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:killall:*' force-list always

# ssh/scp/rsync: hosts completion
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0. <->' '255.255.255. 255' '::1' 'fe80::*'

# man: section order
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# =============================================================================
# FZF-TAB INTEGRATION
# =============================================================================

if has fzf; then
  # Use fzf for completion if available
  zstyle ':fzf-tab:*' fzf-command sk
  zstyle ':fzf-tab:*' use-fzf-default-opts yes
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
  zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza -1 --color=always $realpath'
  zstyle ':fzf-tab:complete:cat:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 $realpath'
fi

# =============================================================================
# CUSTOM COMPLETIONS
# =============================================================================

# Docker compose
if has docker; then
  _docker_compose_services(){
    local -a services
    services=(${(f)"$(docker compose config --services 2>/dev/null)"})
    _describe 'service' services
  }
  compdef _docker_compose_services docker-compose
fi

# Git branch completion for custom aliases
if has git; then
  _git_branches(){
    local -a branches
    branches=(${(f)"$(git branch --format='%(refname:short)' 2>/dev/null)"})
    _describe 'branch' branches
  }
  compdef _git_branches gco
  compdef _git_branches gb
  compdef _git_branches gbd
fi

# Fuzzy function completions
if has fzf || has sk; then
  compdef _gnu_generic fz
  compdef _gnu_generic fkill
  compdef _gnu_generic fman
fi

# =============================================================================
# PERFORMANCE OPTIMIZATIONS
# =============================================================================

# Don't complete backup files as commands
zstyle ':completion:*:complete:-command-:*:*' ignored-patterns '(aptitude-*|*\~)'

# Ignore completion functions for commands we don't have
zstyle ':completion:*:functions' ignored-patterns '_*'

# Don't complete directory we are already in
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# =============================================================================
# ADDITIONAL COMPLETION SOURCES
# =============================================================================

# Add custom completion directories
fpath=(
  "${ZDOTDIR}/completions"
  "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/completions"
  $fpath
)

# Load tool-specific completions
has rustup && rustup completions zsh > "${ZDOTDIR}/completions/_rustup"
has cargo && rustup completions zsh cargo > "${ZDOTDIR}/completions/_cargo"

# =============================================================================
# COMPLETION WIDGETS
# =============================================================================

# Use Shift-Tab for reverse menu completion
bindkey '^[[Z' reverse-menu-complete

# Accept completion and execute
bindkey -M menuselect '^M' . accept-line

# =============================================================================
# AUTOLOAD COMPLETIONS
# =============================================================================

# Autoload all completion functions
autoload -Uz ${ZDOTDIR}/completions/*(:t)

# vim: set ft=zsh ts=2 sw=2 et:
