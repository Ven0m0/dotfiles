#!/usr/bin/env bash
# ~/.config/bash/plugins/03-aliases.bash
#================================= [Aliases] ==================================
# Keep aliases enabled after sudo
alias sudo='sudo ' sudo-rs='sudo-rs ' doas='doas '
# Editor shortcuts
alias e="$EDITOR" se="sudo $EDITOR"
# Quick navigation
alias c='clear' q='exit'
alias ..='cd ..' ...='cd ../..' ....='cd ../../..'
alias bd='cd "$OLDPWD"'
# File operations with safety
alias cp='cp -iv --strip-trailing-slashes'
alias mv='mv -iv --strip-trailing-slashes'
alias rm='rm -Iv --preserve-root'
alias grep='grep --color=auto'
# SSH with proper terminal settings
alias ssh='TERM=xterm-256color LC_ALL=C.UTF-8 command ssh'
# Modern tool replacements
has wget2 && alias wget='wget2'
has btm && alias top='btm'
has duf && alias df='duf'
has dua && alias du='dua'
has procs && alias ps='procs'
killport(){ lsof -sTCP:LISTEN -i ":$1" -t | xargs -r kill -9; }
killname(){
  local -a pids=()
  mapfile -t pids < <(pgrep "$1")
  [[ ${#pids[@]} -eq 0 ]] && { printf "No processes found matching '%s'\n" "$1"; return 1; }
  for pid in "${pids[@]}"; do
    local process_name=$(ps -p "$pid" -o comm=)
    printf "Are you sure you want to kill process %s (%s)? [y/N]\n" "$pid" "$process_name"
    read -r response
    if printf "%s" "$response" | grep -q '^[yY]\([eE][sS]\)\?$'; then
      sudo kill -9 "$pid" && printf "Killed process %s (%s)\n" "$pid" "$process_name"
    else printf "Skipped process %s (%s)\n" "$pid" "$process_name"; fi
  done
}
node_admin(){
  sudo setcap 'cap_net_bind_service=+ep' $(which node)
  printf "Changing max notify watcher from %s to 524288 (max value)\n" "$(cat /proc/sys/fs/inotify/max_user_watches)"
  printf "fs.inotify.max_user_watches=524288\n" | sudo tee -a /etc/sysctl.conf
}
# System maintenance
alias journalctl-errors='journalctl -p 3 -xb'
alias systemctl-list='systemctl list-units --type=service --state=running'

# Package management
pactree(){
  if pacman -Qi "$1" &>/dev/null; then
    printf "Dependencies for %s:\n" "$1"
    pacman -Qi "$1" | awk '/^(Depends|Required|Optional)/{print}' | cut -d: -f2 | tr -d ' ' | tr ',' '\n' | grep -v '^$' | sort -u
  else printf "package %s not installed\n" "$1"; fi
}
pacbig(){
  printf "Largest installed packages\n"
  pacman -Qi | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -h | tail -20
}
pacown(){
  [[ -z $1 ]] && { printf "usage: pacown <file>\n"; return 1; }
  local result=$(pacman -Qo "$1" &>/dev/null)
  [[ $? -eq 0 ]] && printf "%s\n" "$result" || printf "file %s not owned by any package\n" "$1"
}
pacfiles(){
  [[ -z $1 ]] && { printf "usage: pacfiles <package>\n"; return 1; }
  if pacman -Ql "$1" &>/dev/null; then
    printf "Files installed by %s:\n" "$1"
    sudo pacman -Ql "$1"
  else printf "package %s not installed\n" "$1"; fi
}
kde_restart(){
  printf "restarting display manager...\n"
  sudo systemctl restart sddm &>/dev/null || sudo systemctl restart lightdm &>/dev/null || printf "display manager restart failed\n"
}
paci(){
  has fzf || return 1
  local package=$(pacman -Sl | awk '{print $2}' | fzf -m --prompt="Select packages to install: " --preview "pacman -Si {} &>/dev/null || paru --skipreview -Si {} &>/dev/null" --preview-window 'top:75%' | tr "\n" " ")
  [[ $package ]] && read -rn1 -p "Install ${package}? [y/N]: " install
  [[ $install == "y" ]] && pac_install $package
}
paci(){
  has paru && has fzf || return 1
  local package=$(paru --skipreview -Sl | awk '{print $2}' | fzf -m --prompt="Select AUR packages to install: " --preview "paru --skipreview -Si {} &>/dev/null" --preview-window 'top:75%' | tr "\n" " ")
  [[ $package ]] && read -rn1 -p "Install ${package}? [y/N]: " install
  [[ $install == "y" ]] && paru --skipreview -Si $package
}

alias g='git'
alias gss='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
gcc(){ git add -A && git commit -m "${1:-misc}" && git push; }
alias gp='git push'
alias gl='git pull'
alias gb='git branch'
alias gundo='git reset --soft HEAD~1'
alias gsize='git count-objects -vH'
alias gfp='git push --force-with-lease'  # Safe force push

alias ping='ping -c 10'
alias ipa='ip -c a'
alias ip6='ip -6 addr show'
alias compress='tar -czf'
alias decompress='tar -xzf'
alias backup='rsync -avh --progress'
alias cleanup='sudo pacman -Rns $(pacman -Qdtq)'

alias xfscheck='sudo xfs_repair -n'
alias xfsrepair='sudo xfs_repair'
alias xfsforce='sudo xfs_repair -L'
