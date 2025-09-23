#!/usr/bin/env bash

# Install and load plugins
_bash_plugins() {
  unset -f "$0"
  local reset_nullglob="$(shopt -p nullglob)"
  shopt -s nullglob # suppress errors when for loops have no matching files
  local xdg_config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  local bash_configs="${xdg_config_home}/bash"
  local bash_plugins="${bash_configs}/plugins"
  for file in "$bash_plugins"/*.sh; do
    source "$file"
  done
  for file in "$bash_plugins"/*.bash; do
    source "$file" 
  done
  "$reset_nullglob"
}
_bash_plugins
