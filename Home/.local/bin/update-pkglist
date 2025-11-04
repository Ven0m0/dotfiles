#!/usr/bin/env bash
# https://github.com/alfunx/.dotfiles/blob/master/.bin/update-pkglist

update-pkglist(){
  mkdir -p -- "$HOME/.pkglist"
  pacman -Qeq | grep -v "$(paclist aur | sed 's/\s.*//')" \
    | grep -v "$(paclist manual | sed 's/\s.*//')" \
    > "${HOME}/.pkglist/pacman"
  pacman -Qeq > "$HOME/.pkglist/pacman-all"
  paclist aur | sed 's/\s.*//' > "$HOME/.pkglist/aur"
  paclist manual | sed 's/\s.*//' > "$HOME/.pkglist/manual"
  sudo pacman -Qkk |& grep Modification | sed -e 's/^[^/]*//' -e 's/ (.*)$//' | sort > "$HOME/.pkglist/modified-files"
}

ssh-key(){
  email="${email:=${1:-ven0m0.wastaken@gmail.com}}"
  target="${2:=dietpi@192.168.178.86}"
  ssh-keygen -t ed25519 -a 100 -f ~/.ssh/pi_ed25519 -C "$email"
  ssh-copy-id -i ~/.ssh/pi_ed25519.pub "$target"
}
