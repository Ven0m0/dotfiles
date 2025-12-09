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
has dust && alias du='dust'
has procs && alias ps='procs'

killport(){ lsof -i ":$1" | grep LISTEN | awk '{print $2}' | xargs kill -9; }
killname(){
  for pid in $(ps -e | grep "$1" | awk '{print $1}'); do
    local process_name=$(ps -p "$pid" -o comm=)
    echo "Are you sure you want to kill process $pid ($process_name)? [y/N]"
    read response
    if echo "$response" | grep -q '^[yY]\([eE][sS]\)\?$'; then
      sudo kill -9 "$pid" && echo "Killed process $pid ($process_name)"
    else echo "Skipped process $pid ($process_name)"; fi
  done
}
node_admin(){
  sudo setcap 'cap_net_bind_service=+ep' $(which node)
  echo "Changing max notify watcher from $(cat /proc/sys/fs/inotify/max_user_watches) to 524288 (max value)"
  echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
}

# System maintenance
alias journalctl-errors='journalctl -p 3 -xb'
alias systemctl-list='systemctl list-units --type=service --state=running'

# Package management
pactree(){
  if pacman -Qi "$1" &>/dev/null; then
    echo -e "Dependencies for $1:"
    pacman -Qi "$1" | grep -E "(Depends|Required|Optional)" | cut -d: -f2 | tr -d ' ' | tr ',' '\n' | grep -v '^$' | sort -u
  else echo -e "package $1 not installed"; fi
}
pacbig(){
  echo -e "Largest installed packages"
  pacman -Qi | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -h | tail -20
}
pacown(){
  [[ -z $1 ]] && { echo -e "usage: pacown <file>"; return 1; }
  local result=$(pacman -Qo "$1" 2>/dev/null)
  [[ $? -eq 0 ]] && echo -e "$result" || echo -e "file $1 not owned by any package"
}
pacfiles(){
  [[ -z $1 ]] && { echo -e "usage: pacfiles <package>"; return 1; }
  if pacman -Ql "$1" &>/dev/null; then
    echo -e "Files installed by $1:"
    sudo pacman -Ql "$1"
  else echo -e "package $1 not installed"; fi
}
kde_restart(){
  echo -e "restarting display manager..."
  sudo systemctl restart sddm 2>/dev/null || sudo systemctl restart lightdm 2>/dev/null || echo -e "display manager restart failed"
}
paci(){
  has fzf || return 1
  local package=$(pacman -Sl | awk '{print $2}' | fzf -m --prompt="Select packages to install: " --preview "pacman -Si {} 2>/dev/null || paru --skipreview -Si {} 2>/dev/null" --preview-window 'top:75%' | tr "\n" " ")
  [[ $package ]] && read -n1 -p "Install ${package}? [y/N]: " install
  [[ $install == "y" ]] && pac_install $package
}
yayi(){
  has paru && has fzf || return 1
  local package=$(paru --skipreview -Sl | awk '{print $2}' | fzf -m --prompt="Select AUR packages to install: " --preview "paru --skipreview -Si {} 2>/dev/null" --preview-window 'top:75%' | tr "\n" " ")
  [[ $package ]] && read -n1 -p "Install ${package}? [y/N]: " install
  [[ $install == "y" ]] && paru --skipreview -Si $package
}
