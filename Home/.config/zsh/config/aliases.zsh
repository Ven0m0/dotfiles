#!/usr/bin/env zsh
# ============================================================================
# Zsh Aliases - Complete Feature Parity with Bash
# ============================================================================

# =============================================================================
# MODERN TOOL REPLACEMENTS
# =============================================================================

# File listing (prefer eza)
if has eza; then
  alias ls='eza --git --icons -F --group-directories-first --time-style=long-iso'
  alias ll='eza --git --icons -F --group-directories-first --time-style=long-iso -alh'
  alias la='eza --git --icons -F --group-directories-first --time-style=long-iso -a'
  alias lt='eza --git --icons -F --group-directories-first --time-style=long-iso -T'
  alias l='eza --git --icons -F --group-directories-first --time-style=long-iso -1'
else
  alias ll='ls -alh'
  alias la='ls -A'
  alias l='ls -1'
fi

# Core utilities
has bat && alias cat='bat --style=plain --paging=never'
has rg && alias grep='rg'
has fd && alias find='fd'
has dust && alias du='dust'
has sd && alias sed='sd'
has jaq && alias jq='jaq'
has choose && alias cut='choose'
has sk && alias fzf='sk'

# =============================================================================
# NAVIGATION SHORTCUTS
# =============================================================================

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias -- -='cd -'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'

# =============================================================================
# FILE OPERATIONS
# =============================================================================

alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -pv'
alias rmdir='rmdir -v'

# Safe operations
alias cpi='cp -i'
alias mvi='mv -i'
alias rmi='rm -i'

# =============================================================================
# GIT ALIASES
# =============================================================================

# Use gix if available, fallback to git
if has gix; then
  alias g='gix'
  alias ga='gix add'
  alias gaa='gix add -A'
  alias gc='gix commit'
  alias gcm='gix commit -m'
  alias gca='gix commit --amend'
  alias gcan='gix commit --amend --no-edit'
  alias gp='gix push'
  alias gpf='gix push --force-with-lease'
  alias gl='gix pull'
  alias gst='gix status'
  alias gd='gix diff'
  alias gds='gix diff --staged'
  alias gco='gix checkout'
  alias gcb='gix checkout -b'
  alias gb='gix branch'
  alias gba='gix branch -a'
  alias gbd='gix branch -D'
  alias glog='gix log --oneline --graph --decorate'
  alias grb='gix rebase'
  alias grbi='gix rebase -i'
  alias grbc='gix rebase --continue'
  alias grba='gix rebase --abort'
  alias gsh='gix stash'
  alias gshp='gix stash pop'
  alias gshl='gix stash list'
  alias gcl='gix clone'
  alias gf='gix fetch'
  alias gfa='gix fetch --all'
  alias gm='gix merge'
  alias gma='gix merge --abort'
else
  alias g='git'
  alias ga='git add'
  alias gaa='git add -A'
  alias gc='git commit'
  alias gcm='git commit -m'
  alias gca='git commit --amend'
  alias gcan='git commit --amend --no-edit'
  alias gp='git push'
  alias gpf='git push --force-with-lease'
  alias gl='git pull'
  alias gst='git status'
  alias gd='git diff'
  alias gds='git diff --staged'
  alias gco='git checkout'
  alias gcb='git checkout -b'
  alias gb='git branch'
  alias gba='git branch -a'
  alias gbd='git branch -D'
  alias glog='git log --oneline --graph --decorate'
  alias grb='git rebase'
  alias grbi='git rebase -i'
  alias grbc='git rebase --continue'
  alias grba='git rebase --abort'
  alias gsh='git stash'
  alias gshp='git stash pop'
  alias gshl='git stash list'
  alias gcl='git clone'
  alias gf='git fetch'
  alias gfa='git fetch --all'
  alias gm='git merge'
  alias gma='git merge --abort'
fi

# =============================================================================
# PACKAGE MANAGEMENT (ARCH)
# =============================================================================

if has paru; then
  alias p='paru'
  alias pi='paru -S'
  alias pu='paru -Syu'
  alias pr='paru -Rns'
  alias ps='paru -Ss'
  alias pq='paru -Q'
  alias pqi='paru -Qi'
  alias pql='paru -Ql'
  alias pqo='paru -Qo'
  alias pc='paru -Sc'
  alias pcc='paru -Scc'
  alias pacf='fuzzy_paru'
  alias paruf='fuzzy_paru'
elif has yay; then
  alias p='yay'
  alias pi='yay -S'
  alias pu='yay -Syu'
  alias pr='yay -Rns'
  alias ps='yay -Ss'
  alias pq='yay -Q'
  alias pqi='yay -Qi'
  alias pql='yay -Ql'
  alias pqo='yay -Qo'
  alias pc='yay -Sc'
  alias pcc='yay -Scc'
fi

# =============================================================================
# DOCKER ALIASES
# =============================================================================

if has docker; then
  alias d='docker'
  alias dc='docker compose'
  alias dps='docker ps'
  alias dpsa='docker ps -a'
  alias di='docker images'
  alias dex='docker exec -it'
  alias dlog='docker logs -f'
  alias dprune='docker system prune -af'
  alias dvolprune='docker volume prune -f'
fi

# =============================================================================
# SYSTEM OPERATIONS
# =============================================================================

alias c='clear'
alias h='history'
alias j='jobs'
alias v='${EDITOR:-nano}'
alias vi='${EDITOR:-nano}'
alias vim='${EDITOR:-nano}'

# Reloads
alias reload='source "${ZDOTDIR:-$HOME}/. zshrc"'
alias zshrc='${EDITOR:-nano} "${ZDOTDIR:-$HOME}/.zshrc" && reload'

# Quick edits
alias aliases='${EDITOR:-nano} "${ZDOTDIR}/config/aliases.zsh" && reload'
alias functions='${EDITOR:-nano} "${ZDOTDIR}/config/functions.zsh" && reload'

# System info
alias ports='netstat -tulanp'
alias psmem='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3 | head -10'

# =============================================================================
# SAFETY & CONVENIENCE
# =============================================================================

# Confirm before overwriting
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Colorize output
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'

# Human-readable sizes
alias df='df -h'
alias free='free -h'

# =============================================================================
# GLOBAL ALIASES (ZSH-SPECIFIC)
# =============================================================================

alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g L='| less'
alias -g M='| more'
alias -g N='&>/dev/null'
alias -g NE='2>/dev/null'
alias -g NUL='>/dev/null 2>&1'
alias -g P='| ${PAGER:-less}'

# =============================================================================
# SUFFIX ALIASES (ZSH-SPECIFIC)
# =============================================================================

alias -s {md,txt,json,yaml,yml,toml,conf,config}='${EDITOR:-nano}'
alias -s {jpg,jpeg,png,gif,bmp}='feh'
alias -s {mp4,mkv,avi,mov}='mpv'
alias -s {mp3,flac,wav,ogg}='mpv --no-video'
alias -s {zip,tar,gz,bz2,xz,7z}='extract'

# =============================================================================
# MISC ALIASES
# =============================================================================

# Directory hashes (quick navigation)
hash -d downloads=~/Downloads
hash -d documents=~/Documents
hash -d projects=~/Projects
hash -d config=~/.config
hash -d local=~/.local

# Quick service management
if has systemctl; then
  alias sc='systemctl'
  alias scu='systemctl --user'
  alias jc='journalctl'
  alias jcu='journalctl --user'
fi

# vim: set ft=zsh ts=2 sw=2 et:
