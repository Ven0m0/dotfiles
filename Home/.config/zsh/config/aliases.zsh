#!/usr/bin/env zsh
# shellcheck shell=bash
# ============================================================================
# Zsh Aliases - Modern Tools & Fish-Style Abbreviations
# ============================================================================

# ---[ Modern Tool Replacements ]---
if has eza; then
  alias ls='eza --git --icons -F --group-directories-first --time-style=long-iso'
  alias ll='eza --git --icons -F --group-directories-first --time-style=long-iso -alh'
  alias la='eza --git --icons -F --group-directories-first --time-style=long-iso -a'
  alias lt='eza --git --icons -F --group-directories-first --time-style=long-iso -T'
  alias l='eza --git --icons -F --group-directories-first --time-style=long-iso -1'
else
  alias ll='ls -alh' la='ls -A' l='ls -1'
fi

has bat && alias cat='bat --style=plain --paging=never'
has rg && alias grep='rg'
has fd && alias find='fd'
has dust && alias du='dust'
has sd && alias sed='sd'
has jaq && alias jq='jaq'
has choose && alias cut='choose'
has sk && alias fzf='sk'

# ---[ Git Aliases ]---
if has gix; then
  alias g=gix ga='gix add' gaa='gix add -A' gc='gix commit' gcm='gix commit -m'
  alias gca='gix commit --amend' gcan='gix commit --amend --no-edit'
  alias gp='gix push' gpf='gix push --force-with-lease' gl='gix pull'
  alias gst='gix status' gd='gix diff' gds='gix diff --staged'
  alias gco='gix checkout' gcb='gix checkout -b' gb='gix branch'
  alias gba='gix branch -a' gbd='gix branch -D'
  alias glog='gix log --oneline --graph --decorate'
  alias grb='gix rebase' grbi='gix rebase -i' grbc='gix rebase --continue' grba='gix rebase --abort'
  alias gsh='gix stash' gshp='gix stash pop' gshl='gix stash list'
  alias gcl='gix clone' gf='gix fetch' gfa='gix fetch --all'
  alias gm='gix merge' gma='gix merge --abort'
else
  alias g=git ga='git add' gaa='git add -A' gc='git commit' gcm='git commit -m'
  alias gca='git commit --amend' gcan='git commit --amend --no-edit'
  alias gp='git push' gpf='git push --force-with-lease' gl='git pull'
  alias gst='git status' gd='git diff' gds='git diff --staged'
  alias gco='git checkout' gcb='git checkout -b' gb='git branch'
  alias gba='git branch -a' gbd='git branch -D'
  alias glog='git log --oneline --graph --decorate'
  alias grb='git rebase' grbi='git rebase -i' grbc='git rebase --continue' grba='git rebase --abort'
  alias gsh='git stash' gshp='git stash pop' gshl='git stash list'
  alias gcl='git clone' gf='git fetch' gfa='git fetch --all'
  alias gm='git merge' gma='git merge --abort'
fi

# ---[ Package Manager (Arch) ]---
if has paru; then
  alias p=paru pi='paru -S' pu='paru -Syu' pr='paru -Rns'
  alias ps='paru -Ss' pq='paru -Q' pqi='paru -Qi' pql='paru -Ql' pqo='paru -Qo'
  alias pc='paru -Sc' pcc='paru -Scc'
  alias pacf=fuzzy_paru paruf=fuzzy_paru
elif has yay; then
  alias p=yay pi='yay -S' pu='yay -Syu' pr='yay -Rns'
  alias ps='yay -Ss' pq='yay -Q' pqi='yay -Qi' pql='yay -Ql' pqo='yay -Qo'
  alias pc='yay -Sc' pcc='yay -Scc'
fi

# ---[ Docker ]---
if has docker; then
  alias d=docker dc='docker compose' dps='docker ps' dpsa='docker ps -a'
  alias di='docker images' dex='docker exec -it' dlog='docker logs -f'
  alias dprune='docker system prune -af' dvolprune='docker volume prune -f'
fi

# ---[ System Operations ]---
alias c=clear h=history j=jobs
alias v='${EDITOR:-nano}' vi='${EDITOR:-nano}' vim='${EDITOR:-nano}'
alias reload='exec zsh'
alias zshrc='${EDITOR:-nano} "$ZDOTDIR/.zshrc" && reload'
alias aliases='${EDITOR:-nano} "$ZDOTDIR/config/aliases.zsh" && reload'
alias functions='${EDITOR:-nano} "$ZDOTDIR/config/functions.zsh" && reload'
alias completions='${EDITOR:-nano} "$ZDOTDIR/config/completions.zsh" && reload'

# System info
alias ports='netstat -tulanp'
alias psmem='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3 | head -10'

# Media
alias ffmpeg='ffmpeg -hide_banner'
alias ffprobe='ffprobe -hide_banner'

# Safety & convenience
alias cp='cp -i' mv='mv -i' rm='rm -i' mkdir='mkdir -pv'
alias diff='diff --color=auto' ip='ip -color=auto'
alias df='df -h' free='free -h'

# Systemd
has systemctl && alias sc=systemctl scu='systemctl --user' jc=journalctl jcu='journalctl --user'

# ---[ Navigation Shortcuts ]---
alias -g ...='../..' ....='../../..' .....='../../../..' ......='../../../../..'
alias -- -='cd -' 1='cd -1' 2='cd -2' 3='cd -3' 4='cd -4' 5='cd -5'

# ---[ Global Aliases (Zsh-Specific) ]---
alias -g H='| head' T='| tail' G='| grep' L='| less' M='| more'
alias -g N='&>/dev/null' NE='2>/dev/null' P='| ${PAGER:-less}'

# ---[ Suffix Aliases (Zsh-Specific) ]---
alias -s {md,txt,json,yaml,yml,toml,conf,config}='${EDITOR:-nano}'
alias -s {jpg,jpeg,png,gif,bmp}=feh
alias -s {mp4,mkv,avi,mov}=mpv
alias -s {mp3,flac,wav,ogg}='mpv --no-video'
alias -s {zip,tar,gz,bz2,xz,7z}=extract

# ---[ Directory Hashes ]---
hash -d downloads=~/Downloads documents=~/Documents projects=~/Projects
hash -d config=~/.config local=~/.local

# ---[ Fish-Style Abbreviations ]---
# Expand on space (use Ctrl+Space for literal space)
typeset -gA abbrevs=(
  # Git shortcuts
  gs    'git status'
  gds   'git diff --staged'
  gcm   'git commit -m'
  gaa   'git add -A'
  gcan  'git commit --amend --no-edit'
  gp    'git push'
  gl    'git pull'
  gco   'git checkout'
  gcb   'git checkout -b'
  glog  'git log --oneline --graph --decorate'
  # Directory navigation
  ..    'cd ..'
  ...   'cd ../..'
  ....  'cd ../../..'
  # Listing
  ll    'ls -lah'
  la    'ls -A'
  lt    'ls --tree'
  # Process management
  psg   'ps aux | grep -v grep | grep -i -e VSZ -e'
  # Docker
  dps   'docker ps'
  dpsa  'docker ps -a'
  dex   'docker exec -it'
  # Package management
  pup   'paru -Syu'
  pins  'paru -S'
  prem  'paru -Rns'
  psea  'paru -Ss'
)

# Abbreviation expansion widget
magic-abbrev-expand(){
  local left="${LBUFFER%% *}"
  local expanded="${abbrevs[$left]}"
  if [[ -n $expanded ]]; then
    LBUFFER="$expanded${LBUFFER#$left}"
  fi
  zle self-insert
}

# Bind expansion to space
zle -N magic-abbrev-expand
bindkey ' ' magic-abbrev-expand
bindkey '^ ' self-insert  # Ctrl+Space for literal space

# vim: set ft=zsh ts=2 sw=2 et:
