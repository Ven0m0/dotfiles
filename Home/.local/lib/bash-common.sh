#!/usr/bin/env bash
# bash-common.sh - Shared bash utilities for dotfiles scripts
# shellcheck shell=bash

# Prevent multiple sourcing
[[ -n ${_BASH_COMMON_LOADED:-} ]] && return 0
readonly _BASH_COMMON_LOADED=1

# Color codes (ANSI escape sequences)
readonly C_RED=$'\e[1;31m'
readonly C_GREEN=$'\e[1;32m'
readonly C_YELLOW=$'\e[1;33m'
readonly C_BLUE=$'\e[1;34m'
readonly C_MAGENTA=$'\e[1;35m'
readonly C_CYAN=$'\e[1;36m'
readonly C_BOLD=$'\e[1m'
readonly C_DIM=$'\e[2m'
readonly C_RESET=$'\e[0m'

# Shorter aliases
readonly R=$'\e[31m'
readonly G=$'\e[32m'
readonly Y=$'\e[33m'
readonly B=$'\e[34m'
readonly M=$'\e[35m'
readonly C=$'\e[36m'
readonly BD=$'\e[1m'
readonly D=$'\e[0m'
readonly X=$'\e[0m'

# Command availability check
# Returns 0 if command exists, 1 otherwise
has() {
  command -v -- "$1" &>/dev/null
}

# Logging functions with consistent formatting
log() {
  printf '%b[INFO]%b %s\n' "$C_BLUE" "$C_RESET" "$*"
}

info() {
  printf '%b==>%b %s\n' "$C_BLUE" "$C_RESET" "$*"
}

ok() {
  printf '%b==>%b %s\n' "$C_GREEN" "$C_RESET" "$*"
}

warn() {
  printf '%b[WARN]%b %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2
}

die() {
  printf '%b[ERROR]%b %s\n' "$C_RED" "$C_RESET" "$*" >&2
  exit "${2:-1}"
}

# Require command or die
req() {
  has "$1" || die "Required: $1"
}

need() {
  has "$1" || die "Required: $1"
}

# Common script initialization
# Sets strict mode and common environment variables
init_strict() {
  set -euo pipefail
  shopt -s nullglob globstar
  export LC_ALL=C
  IFS=$'\n\t'
}

# Get script directory (works with symlinks)
script_dir() {
  local s="${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}"
  [[ $s != /* ]] && s="$PWD/$s"
  cd -P -- "${s%/*}" && pwd
}

# Cache directory helper
cache_dir() {
  local dir="${XDG_CACHE_HOME:-$HOME/.cache}/${1:-common}"
  mkdir -p "$dir" 2>/dev/null || :
  printf '%s' "$dir"
}

# Config directory helper
config_dir() {
  local dir="${XDG_CONFIG_HOME:-$HOME/.config}/${1:-}"
  mkdir -p "$dir" 2>/dev/null || :
  printf '%s' "$dir"
}

# Cleanup trap helper
setup_cleanup() {
  local var_name="${1:-TMP_DIR}"
  eval "
    cleanup() {
      [[ -n \${${var_name}:-} && -d \$${var_name} ]] && rm -rf \"\$${var_name}\"
    }
    trap cleanup EXIT
  "
}
