#!/usr/bin/env bash
shopt -s nullglob globstar
SHELL=/usr/bin/bash 
# Install and load plugins
_bash_plugins(){
  unset -f "$0"
  local XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
  local bash_configs="${XDG_CONFIG_HOME}/bash"; local bash_plugins="${bash_configs}/plugins"
  for file in "$bash_plugins"/*.sh; do . "$file"; done; unset $file
  for file in "$bash_plugins"/*.bash; do . "$file"; done; unset $file
}
_bash_plugins &>/dev/null
