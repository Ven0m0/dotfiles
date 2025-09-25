#!/usr/bin/bash
SHELL=/usr/bin/bash 

load_completion() {
  local name=$1 cmd=$2 kind=$3 src=$4
  # name: function name (_cargo, _git, _gh…)
  # cmd:  command to check (cargo, git, gh…)
  # kind: eval|source
  # src:  string to eval or file to source
  command -v "$cmd" &>/dev/null || return
  declare -F "$name" &>/dev/null && return
  case $kind in
    eval) eval "$src" ;;
    source) . "$src" ;;
  esac
}

# Git
load_completion _git git source /usr/share/bash-completion/completions/git

# GitHub CLI
load_completion _gh gh eval  "$(gh completion -s bash)"
  
# Rustup + Cargo
load_completion _rustup rustup eval "$(rustup completions bash rustup)"
load_completion _cargo  cargo  eval "$(rustup completions bash cargo)"
