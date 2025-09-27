#!/usr/bin/bash
SHELL=/usr/bin/bash

has() { command -v -- "$1" &>/dev/null; }
ifsource(){ [[ -r "${1/#\~\//${HOME}/}" ]] && . "${1/#\~\//${HOME}/}" &>/dev/null; }

# name: function name (_cargo, _git, _gh…)
# cmd:  command to check (cargo, git, gh…)
# kind: eval|source
# src:  string to eval or file to source
load_completion(){
  local name=$1 cmd=$2 kind=$3 src=$4
  has "$cmd" || return
  declare -F "$name" >/dev/null 2>&1 && return
  case $kind in
    eval) eval "$src" ;;
    source) ifsource "$src" ;;
  esac
}

# Git
load_completion _git git source /usr/share/bash-completion/completions/git
# GitHub CLI
load_completion _gh gh eval "$(gh completion -s bash)"
  
# Rustup + Cargo
load_completion _rustup rustup eval "$(rustup completions bash rustup)"
load_completion _cargo  cargo  eval "$(rustup completions bash cargo)"

curl -sf https://github.com/endeavouros-team/PKGBUILDS/blob/master/reflector-bash-completion/reflector-bash-completion -o "${HOME}/.config/bash/completions/reflector.bash"

cd "$HOME"
curl -sf -O https://raw.githubusercontent.com/trapd00r/LS_COLORS/refs/heads/master/lscolors.sh
