#!/usr/bin/env zsh
# shellcheck shell=bash
# ============================================================================
# Zsh Completions - Enhanced Tab Completion
# ============================================================================

# ---[ Completion System Init ]---
# Load compinit (only once per day for performance)
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# ---[ Completion Styles ]---
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{cyan}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'

# Fuzzy matching
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# General settings
zstyle ':completion:*' insert-tab false
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' special-dirs ..
zstyle ':completion:*' sort true

# ---[ Command-Specific Completions ]---
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
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# man: section order
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# git: disable sort for checkout
zstyle ':completion:*:git-checkout:*' sort false

# ---[ FZF-Tab Integration ]---
if has fzf; then
  zstyle ':fzf-tab:*' use-fzf-default-opts yes
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 $realpath'
  zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 $realpath'
  zstyle ':fzf-tab:complete:cat:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null'
fi

# ---[ Performance Optimizations ]---
# Don't complete backup files as commands
zstyle ':completion:*:complete:-command-:*:*' ignored-patterns '(aptitude-*|*~)'

# Ignore completion functions for commands we don't have
zstyle ':completion:*:functions' ignored-patterns '_*'

# Don't complete directory we are already in
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# ---[ Custom Completions ]---
# Docker compose services
if has docker; then
  _docker_compose_services(){
    local -a services
    services=(${(f)"$(docker compose config --services 2>/dev/null)"})
    _describe service services
  }
  compdef _docker_compose_services docker-compose
fi

# Git branch completion for custom aliases
if has git; then
  _git_branches(){
    local -a branches
    branches=(${(f)"$(git branch --format='%(refname:short)' 2>/dev/null)"})
    _describe branch branches
  }
  compdef _git_branches gco gb gbd
fi

# Fuzzy function completions
if has fzf || has sk; then
  compdef _gnu_generic fz fkill fman
fi

# ---[ Tool-Specific Completions ]---
# Generate completions for Rust tools
if has rustup; then
  mkdir -p "$ZDOTDIR/completions"
  rustup completions zsh >"$ZDOTDIR/completions/_rustup" 2>/dev/null
  rustup completions zsh cargo >"$ZDOTDIR/completions/_cargo" 2>/dev/null
fi

# Autoload all completion functions
autoload -Uz ${ZDOTDIR}/completions/*(:t) 2>/dev/null

# ---[ Menu Selection Bindings ]---
# Accept completion and execute
bindkey -M menuselect '^M' .accept-line

# vim: set ft=zsh ts=2 sw=2 et:
