#!/usr/bin/env bash
LC_ALL=C LANG=C LANGUAGE=C
HOME="/home/${SUDO_USER:-$USER}"
builtin cd -P -- "$(dirname -- "${BASH_SOURCE[0]:-}")" && printf '%s\n' "$PWD" || exit 1
# Common shell utilities and functions for dotfiles scripts
# Source this file in your scripts: source "${HOME}/.local/lib/shell-common.sh"

# Locale management
set_c_locale(){ export LC_ALL=C LANG=C LANGUAGE=C; }
reset_locale(){ unset LC_ALL LANG LANGUAGE; }

# Check if a command exists
has(){ command -v -- "$1" &>/dev/null; }
# Check if a command exists, exit with error if not found
# Usage: require <command>
require(){ command -v "$1" &>/dev/null || { echo "Error: Required command '$1' not found" >&2; exit 1; }; }
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
print_color(){ local color="${1}"; shift; printf '%b%s%b\n' "${color}" "$*" "${C_RESET}"; }
# Print error message and exit
# Usage: die <message> [exit_code]
die(){ printf '%b%s%b\n' "${C_BOLD}${C_RED}ERROR: ${C_BRIGHT_WHITE}" "${1}" "${C_RESET}" >&2; exit "${2:-1}"; }
# Print warning message
# Usage: warn <message>
warn(){ printf '%b%s%b\n' "${C_BOLD}${C_YELLOW}WARNING: ${C_BRIGHT_WHITE}" "${1}" "${C_RESET}" >&2; }
# Print info message
# Usage: info <message>
info(){ printf '%b%s%b\n' "${C_BOLD}${C_BLUE}INFO: ${C_BRIGHT_WHITE}" "${1}" "${C_RESET}"; }
# Print success message
# Usage: success <message>
success(){ printf '%b%s%b\n' "${C_BOLD}${C_GREEN}SUCCESS: ${C_BRIGHT_WHITE}" "${1}" "${C_RESET}"; }

# File utilities
# Add execute rights to all shell files recursively
chxmod(){ LC_ALL=C find -O2 ./ -type f -regex ".*\.\(sh\|zsh\|bash\|fish\|dash\)" -exec chmod +x {} \; }

# Append line to file if not already present
# Usage: appendabsent <line> <file>
appendabsent(){ LC_ALL=C grep -xqF -- "$1" "$2" || echo "$1" >>"$2"; }

# List all executables on PATH
execinpath(){
  set -f; IFS=:
  for d in $PATH; do
    set +f; [[ -n $d ]] || d=.
    for f in "$d"/.[ "$d"/..?* "$d"/*; do [[ -f $f ]] && [[ -x $f ]] && printf '%s\n' "${f##*/}"; done
  done | sort -u
}

# Show RAM usage sorted by size
showram(){ ps -eo size,pid,user,command --sort -size | awk '{ hr=$1/1024 ; printf("%13.2f Mb ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }' | sort; }
