#!/usr/bin/env zsh
# shellcheck shell=bash
# ============================================================================
# Fish-Like Zsh Config - Optimized & Consolidated
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

# ---[ Zimfw Init ]---
ZIM_HOME="${XDG_DATA_HOME}/zim"
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  mkdir -p "$ZIM_HOME"
  git clone --depth=1 --filter=blob:none https://github.com/zimfw/zimfw.git "$ZIM_HOME"
fi
[[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR}/.zimrc ]] && source "${ZIM_HOME}/zimfw.zsh" init -q
source "${ZIM_HOME}/init.zsh"

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

# ---[ Completion Styles ]---
zstyle ':completion:*' use-cache on cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select list-colors ${(s.:.)LS_COLORS} group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*' insert-tab false squeeze-slashes true special-dirs ..
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 $realpath'

# ---[ Keybindings (Fish-Like) ]---
bindkey -e  # Emacs base
bindkey '^[[A' history-substring-search-up      # Up arrow
bindkey '^[[B' history-substring-search-down    # Down arrow
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey '^[[Z' reverse-menu-complete            # Shift+Tab
bindkey '^[[1;5C' forward-word                  # Ctrl+Right
bindkey '^[[1;5D' backward-word                 # Ctrl+Left
bindkey '^W' backward-kill-word                 # Ctrl+W
bindkey '^H' backward-delete-char               # Ctrl+Backspace
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

# ---[ Aliases - Modern Tools ]---
if has eza; then
  alias ls='eza --git --icons -F --group-directories-first --time-style=long-iso'
  alias ll='eza --git --icons -F --group-directories-first --time-style=long-iso -alh'
  alias la='eza --git --icons -F --group-directories-first --time-style=long-iso -a'
  alias lt='eza --git --icons -F --group-directories-first --time-style=long-iso -T'
  alias l='eza --git --icons -F --group-directories-first --time-style=long-iso -1'
fi
has bat && alias cat='bat --style=plain --paging=never' bathelp='bat -plhelp'
has rg && alias grep='rg'
has fd && alias find='fd'
has dust && alias du='dust'
has sd && alias sed='sd'
has jaq && alias jq='jaq'
has sk && alias fzf='sk'

# Navigation
alias -g ...='../..' ....='../../..' .....='../../../..'
alias -- -='cd -'

# Git (prefer gix)
if has gix; then
  alias g=gix ga='gix add' gaa='gix add -A' gc='gix commit' gcm='gix commit -m'
  alias gca='gix commit --amend' gcan='gix commit --amend --no-edit'
  alias gp='gix push' gpf='gix push --force-with-lease' gl='gix pull'
  alias gst='gix status' gd='gix diff' gds='gix diff --staged'
  alias gco='gix checkout' gcb='gix checkout -b' gb='gix branch'
  alias glog='gix log --oneline --graph --decorate'
  alias grb='gix rebase' grbi='gix rebase -i' gsh='gix stash'
else
  alias g=git ga='git add' gaa='git add -A' gc='git commit' gcm='git commit -m'
  alias gca='git commit --amend' gcan='git commit --amend --no-edit'
  alias gp='git push' gpf='git push --force-with-lease' gl='git pull'
  alias gst='git status' gd='git diff' gds='git diff --staged'
  alias gco='git checkout' gcb='git checkout -b' gb='git branch'
  alias glog='git log --oneline --graph --decorate'
  alias grb='git rebase' grbi='git rebase -i' gsh='git stash'
fi

# Arch package manager
if has paru; then
  alias p=paru pi='paru -S' pu='paru -Syu' pr='paru -Rns'
  alias ps='paru -Ss' pq='paru -Q' pc='paru -Sc'
elif has yay; then
  alias p=yay pi='yay -S' pu='yay -Syu' pr='yay -Rns'
  alias ps='yay -Ss' pq='yay -Q' pc='yay -Sc'
fi

# Docker
if has docker; then
  alias d=docker dc='docker compose' dps='docker ps' di='docker images'
  alias dex='docker exec -it' dlog='docker logs -f'
fi

# System
alias c=clear h=history v='${EDITOR:-nano}' reload='exec zsh'
alias zshrc='${EDITOR:-nano} "$ZDOTDIR/.zshrc" && reload'
alias ffmpeg='ffmpeg -hide_banner' ffprobe='ffprobe -hide_banner'

# Global aliases (zsh-specific)
alias -g H='| head' T='| tail' G='| grep' L='| less' N='&>/dev/null'

# ---[ Fish-Style Abbreviations ]---
# These expand on space, unlike aliases
typeset -gA abbrevs=(
  gs  'git status'
  gd  'git diff'
  gc  'git commit'
  gp  'git push'
  gl  'git pull'
  gco 'git checkout'
  gaa 'git add -A'
  gcm 'git commit -m'
  ll  'ls -lah'
  la  'ls -A'
  ..  'cd ..'
  ... 'cd ../..'
  psg 'ps aux | grep -v grep | grep -i -e VSZ -e'
  h   'history'
)

# Abbreviation expansion on space
magic-abbrev-expand(){
  local left="${LBUFFER%% *}"
  local expanded="${abbrevs[$left]}"
  if [[ -n $expanded ]]; then
    LBUFFER="$expanded${LBUFFER#$left}"
  fi
  zle self-insert
}
zle -N magic-abbrev-expand
bindkey ' ' magic-abbrev-expand
bindkey '^ ' self-insert  # Ctrl+Space for literal space

# ---[ Core Functions ]---
mkcd(){ mkdir -p "$1" && cd "$1"; }
up(){ local d="" i; for ((i=1; i<=${1:-1}; i++)); d+=/.. ; cd "${d#/}"; }
extract(){
  [[ $# -eq 0 || ! -f $1 ]] && { echo "Usage: extract <file>"; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.xz) tar xJf "$1" ;;
    *.tar.zst) tar --zstd -xf "$1" ;;
    *.tar) tar xf "$1" ;;
    *.zip) unzip "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "Unsupported: $1"; return 1 ;;
  esac
}

# Fuzzy file/dir navigation
fz(){
  local fuzzy=$(has sk && echo sk || echo fzf)
  local mode=dir
  [[ $1 == -f ]] && { mode=file; shift; }
  local path="${1:-.}"
  if [[ $mode == file ]]; then
    local file=$(fd -t f . "$path" 2>/dev/null | $fuzzy --preview 'bat --color=always {}')
    [[ -n $file ]] && ${EDITOR:-nano} "$file"
  else
    local dir=$(fd -t d . "$path" 2>/dev/null | $fuzzy --preview 'ls -lah {}')
    [[ -n $dir ]] && cd "$dir"
  fi
}
alias fe='fz -f'

# Git helpers
gdbr(){
  git fetch --prune
  git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -D
}

# Package search (Arch)
pacfzf(){
  local fuzzy=$(has sk && echo sk || echo fzf)
  local sel=$(paru -Ssq | $fuzzy --preview 'paru -Si {} | bat -plini --color=always')
  [[ -n $sel ]] && paru -S "$sel"
}

# Process killer
fkill(){
  local fuzzy=$(has sk && echo sk || echo fzf)
  local pid=$(ps -ef | tail -n +2 | $fuzzy -m | awk '{print $2}')
  [[ -n $pid ]] && kill -"${1:-9}" $pid
}

# ---[ Theme ]---
ifsrc ~/.p10k.zsh

# ---[ Local Overrides ]---
ifsrc "$ZDOTDIR/local.zsh"

# vim: set ft=zsh ts=2 sw=2 et:
