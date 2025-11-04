#!/usr/bin/env bash
# SSH key generation and deployment script

ssh-key(){
  email="${email:=${1:-ven0m0.wastaken@gmail.com}}"
  target="${2:=dietpi@192.168.178.86}"
  ssh-keygen -t ed25519 -a 100 -f ~/.ssh/pi_ed25519 -C "$email"
  ssh-copy-id -i ~/.ssh/pi_ed25519.pub "$target"
}
