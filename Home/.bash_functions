#!/usr/bin/env bash
#~/.bash_functions

dotupdate(){
  if [[ -d ${HOME}/.dotfiles ]]; then
    LC_ALL=C git -C "${HOME}/.dotfiles" pull --rebase --autostash
    printf '%s\n' "Updated dotfiles"
  else
    printf '%s\n' "Failed to update dotfiles"
}

# Arch specific
pacsize(){
  PAGER="${PAGER:-less}"
  if command -v pacinfo &>/dev/null; then
    pacman -Qqt | pacinfo --removable-size | awk '/^Name:/ { name = $2 } /^Installed Size:/ { size = $3$4 } /^$/ { print size" "name } ' | sort -uk2 | sort -rh | "$PAGER"
  else
    pacman -Qi | awk '/^Name/ {name=$3} /^Installed Size/ {print name, $4 substr($5,1,1)}' | column -t | sort -rhk2 | cat -n | tac
  fi
}

pacf(){
  local sel SHELL=bash; sel=$(comm -23 <(command pacman -Slq | sort) <(command pacman -Qq | sort) |
    cat - <(command pacman -Qq | awk '{printf "%-30s \033[32m[installed]\033[0m\n", $1}') |
    fzf --ansi -m --style=full --cycle --border --height=~100% --inline-info -0 --layout=reverse-list \
      --preview '
        command pacman -Si $(awk "{print \$1}" <<< {}) 2>/dev/null | \
        command bat -p --language=ini --color=always | \
        sed -r "s/(Installed Size|Name|Version|Depends On|Optional Deps|Maintainer|Repository|Licenses|URL)/\x1b[96;1m\1\x1b[0m/g"
      ' --preview-window=right:60%:wrap | awk '{print $1}' | paste -sd " " -)
  [[ -n $sel ]] && { printf '%b\n' "\e[32mInstalling packages:\e[0m $sel"; \
    sudo pacman -S ${sel// / } --noconfirm --needed; } || printf '%s\n' "No packages selected."
}

pacsk(){ 
  local sel SHELL=bash; sel=$(comm -23 <(command pacman -Slq | sort) <(command pacman -Qq | sort) |
    cat - <(command pacman -Qq | awk '{printf "%-30s \033[32m[installed]\033[0m\n", $1}') |
    sk --ansi -m --cycle --border --inline-info --height=~100% -0 --layout=reverse-list \
      --preview '
        command pacman -Si $(awk "{print \$1}" <<< {}) 2>/dev/null | \
        command bat -p --language=ini --color=always | \
        sed -r "s/(Installed Size|Name|Version|Depends On|Optional Deps|Maintainer|Repository|Licenses|URL)/\x1b[96;1m\1\x1b[0m/g"
      ' --preview-window=right:60%:wrap | awk '{print $1}' | paste -sd " " -)
  [[ -n $sel ]] && { printf '%b\n' "\e[32mInstalling packages:\e[0m $sel"; \
    sudo pacman -S ${sel// / } --noconfirm --needed; } || printf '%s\n' "No packages selected."
}



