#!/usr/bin/env bash
# https://github.com/alfunx/.dotfiles/blob/master/.bin/update-pkglist

update-pkglist(){
  mkdir -p -- "$HOME/.pkglist"
  
  # Generate intermediate files once instead of inline command substitution
  local aur_list="${HOME}/.pkglist/aur"
  local manual_list="${HOME}/.pkglist/manual"
  
  paclist aur | sed 's/\s.*//' > "$aur_list"
  paclist manual | sed 's/\s.*//' > "$manual_list"
  pacman -Qeq > "$HOME/.pkglist/pacman-all"
  
  # Use grep -v -f for efficient filtering against file contents
  pacman -Qeq | grep -v -f "$aur_list" | grep -v -f "$manual_list" > "${HOME}/.pkglist/pacman"
  
  sudo pacman -Qkk 2>&1 | grep Modification | sed -e 's/^[^/]*//' -e 's/ (.*)$//' | sort > "$HOME/.pkglist/modified-files"
}

ssh-key(){
  email="${email:=${1:-ven0m0.wastaken@gmail.com}}"
  target="${2:=dietpi@192.168.178.86}"
  ssh-keygen -t ed25519 -a 100 -f ~/.ssh/pi_ed25519 -C "$email"
  ssh-copy-id -i ~/.ssh/pi_ed25519.pub "$target"
}
