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

killport(){
  lsof -i ":$1" | grep LISTEN | awk '{print $2}' | xargs kill -9
}
killname(){
  for pid in $(ps -e | grep "$1" | awk '{print $1}'); do
    process_name=$(ps -p "$pid" -o comm=)
    echo "Are you sure you want to kill process $pid ($process_name)? [y/N]"
    read response
    if echo "$response" | grep -q '^[yY]\([eE][sS]\)\?$'; then
      sudo kill -9 "$pid"
      echo "Killed process $pid ($process_name)"
    else
      echo "Skipped process $pid ($process_name)"
    fi
  done
}

node_admin(){
  # allows node to run on admin ports such as 80 and 443
  sudo setcap 'cap_net_bind_service=+ep' $(which node)
  echo "Changing max notify watcher from $(cat /proc/sys/fs/inotify/max_user_watches) to 524288 (max value)"
  echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
}

# System maintenance
alias journalctl-errors='journalctl -p 3 -xb'  # Show system errors
alias systemctl-list='systemctl list-units --type=service --state=running'

# Package management functions
pactree(){
  # Show dependency tree for a package
  if pacman -Qi "$1" &>/dev/null; then
    echo -e "Dependencies for $1:"
    pacman -Qi "$1" | grep -E "(Depends|Required|Optional)" | cut -d: -f2 | tr -d ' ' | tr ',' '\n' | grep -v '^$' | sort -u
  else
    echo -e "package $1 not installed"
  fi
}
pacbig(){
  # Show largest installed packages
  echo -e "Largest installed packages"
  pacman -Qi | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -h | tail -20
}
pacown(){
  # Find which package owns a file
  if [[ -z "$1" ]]; then
    echo -e "usage: pacown <file>"; return 1
  fi
  result=$(pacman -Qo "$1" 2>/dev/null)
  if [[ $? -eq 0 ]]; then
    echo -e "$result"
  else
    echo -e "file $1 not owned by any package"
  fi
}
pacfiles(){
  # List all files installed by a package
  if [[ -z "$1" ]]; then
    echo -e "usage: pacfiles <package>"; return 1
  fi
  if pacman -Ql "$1" &>/dev/null; then
      echo -e "Files installed by $1:"
      sudo pacman -Ql "$1"
  else
    echo -e "package $1 not installed"
  fi
}
# KDE restart (if using KDE) using utils.sh colors
kde_restart(){
  echo -e "restarting display manager..."
  sudo systemctl restart sddm 2>/dev/null || sudo systemctl restart lightdm 2>/dev/null || echo -e "display manager restart failed"
}
paci(){
  command -v fzf &>/dev/null || return 1
  package="$(
    pacman -Sl | awk '{print $2}' | fzf -m --prompt="Select packages to install: " \
        --preview "pacman -Si {} 2>/dev/null || paru --skipreview -Si {} 2>/dev/null" \
        --preview-window 'top:75%' | tr "\n" " ")"
    [[ $package ]] && read -n1 -p "Install ${package}? [y/N]: " install
    [[ "$install" == "y" ]] && pac_install $package
}
yayi() {
  command -v paru &>/dev/null || return 1
  command -v fzf &>/dev/null || return 1
  package="$(
    paru --skipreview -Sl | awk '{print $2}' |
      fzf -m --prompt="Select AUR packages to install: " \
        --preview "paru --skipreview -Si {} 2>/dev/null" \
        --preview-window 'top:75%' | tr "\n" " ")"
    [[ $package ]] && read -n1 -p "Install ${package}? [y/N]: " install
    [[ "$install" == "y" ]] && paru --skipreview -Si $package
}
