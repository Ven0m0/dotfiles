#!/usr/bin/env bash
# Common shell utilities and functions for dotfiles scripts
# Source this file in your scripts: source "${HOME}/.local/lib/shell-common.sh"

# Check if a command exists
# Usage: has <command>
# Returns: 0 if command exists, 1 otherwise
has() {
  command -v "$1" &>/dev/null
}

# Check if a command exists, exit with error if not found
# Usage: require <command>
require() {
  command -v "$1" &>/dev/null || {
    echo "Error: Required command '$1' not found" >&2
    exit 1
  }
}

# Set locale to C for consistent sorting and parsing
# Call this at the beginning of scripts that need consistent locale
set_c_locale() {
  export LC_ALL=C LANG=C
}

# Reset locale
# Call this at the end of scripts that changed locale
reset_locale() {
  unset LC_ALL LANG
}

# ANSI color codes
readonly C_RESET=$'\e[0m'
readonly C_BOLD=$'\e[1m'
readonly C_BLACK=$'\e[30m'
readonly C_RED=$'\e[31m'
readonly C_GREEN=$'\e[32m'
readonly C_YELLOW=$'\e[33m'
readonly C_BLUE=$'\e[34m'
readonly C_MAGENTA=$'\e[35m'
readonly C_CYAN=$'\e[36m'
readonly C_WHITE=$'\e[37m'
readonly C_LIGHT_BLUE=$'\e[38;5;117m'
readonly C_PINK=$'\e[38;5;218m'
readonly C_BRIGHT_WHITE=$'\e[97m'

# Print colored output
# Usage: print_color <color> <message>
print_color() {
  local color="${1}"
  shift
  printf '%b%s%b\n' "${color}" "$*" "${C_RESET}"
}

# Print error message and exit
# Usage: die <message> [exit_code]
die() {
  printf '%b%s%b\n' "${C_BOLD}${C_RED}ERROR: ${C_BRIGHT_WHITE}" "${1}" "${C_RESET}" >&2
  exit "${2:-1}"
}

# Print warning message
# Usage: warn <message>
warn() {
  printf '%b%s%b\n' "${C_BOLD}${C_YELLOW}WARNING: ${C_BRIGHT_WHITE}" "${1}" "${C_RESET}" >&2
}

# Print info message
# Usage: info <message>
info() {
  printf '%b%s%b\n' "${C_BOLD}${C_BLUE}INFO: ${C_BRIGHT_WHITE}" "${1}" "${C_RESET}"
}

# Print success message
# Usage: success <message>
success() {
  printf '%b%s%b\n' "${C_BOLD}${C_GREEN}SUCCESS: ${C_BRIGHT_WHITE}" "${1}" "${C_RESET}"
}
