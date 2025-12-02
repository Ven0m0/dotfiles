#!/usr/bin/env bash
# stdlib.bash - Shared shell library for common functions
# Source this at the top of scripts: . "${HOME}/.local/lib/bash/stdlib.bash"
# Version: 1.0.0

# Guard against multiple inclusion
[[ -n ${_STDLIB_LOADED:-} ]] && return 0
_STDLIB_LOADED=1

# =============================================================================
# STRICT MODE (can be overridden before sourcing)
# =============================================================================
[[ -z ${STDLIB_NO_STRICT:-} ]] && {
  set -euo pipefail
  shopt -s nullglob globstar
}

# =============================================================================
# LOCALE SETTINGS
# =============================================================================
export LC_ALL=C LANG=C

# =============================================================================
# ANSI COLOR CODES
# =============================================================================
# Basic colors
readonly _BLK=$'\e[30m' _RED=$'\e[31m' _GRN=$'\e[32m' _YLW=$'\e[33m'
readonly _BLU=$'\e[34m' _MGN=$'\e[35m' _CYN=$'\e[36m' _WHT=$'\e[37m'
# Extended colors (trans palette accents)
readonly _LBLU=$'\e[38;5;117m' _PNK=$'\e[38;5;218m' _BWHT=$'\e[97m'
# Formatting
readonly _DEF=$'\e[0m' _BLD=$'\e[1m' _UL=$'\e[4m' _DIM=$'\e[2m'

# Export aliases for scripts that use shorter names
BLK=$_BLK RED=$_RED GRN=$_GRN YLW=$_YLW BLU=$_BLU MGN=$_MGN CYN=$_CYN WHT=$_WHT
LBLU=$_LBLU PNK=$_PNK BWHT=$_BWHT DEF=$_DEF BLD=$_BLD UL=$_UL DIM=$_DIM
# Alternative names used by some scripts
X=$_DEF B=$_BLD R=$_RED G=$_GRN Y=$_YLW NC=$_DEF
RESET=$_DEF GREEN=$_GRN YELLOW=$_YLW

# =============================================================================
# CORE HELPERS
# =============================================================================

# Check if command exists
has() { command -v "$1" &>/dev/null; }

# Source file if readable
ifsource() { [[ -r ${1/#\~\//${HOME}/} ]] && . "${1/#\~\//${HOME}/}"; }

# Export variable if path exists
exportif() { [[ -e $2 ]] && export "$1=$2"; }

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================

# Standard logging with colors
log() { printf '%b==>\e[0m %s\n' "${_BLD}${_BLU}" "$*"; }
msg() { printf '%b==>\e[0m %s\n' "${_BLD}${_BLU}" "$*"; }
info() { printf '%b==>\e[0m %s\n' "${_BLD}${_CYN}" "$*"; }
ok() { printf '%b==>\e[0m %s\n' "${_BLD}${_GRN}" "$*"; }
warn() { printf '%b==> WARNING:\e[0m %s\n' "${_BLD}${_YLW}" "$*"; }
err() { printf '%b==> ERROR:\e[0m %s\n' "${_BLD}${_RED}" "$*" >&2; }

# Debug logging (only when DEBUG=1)
dbg() { [[ ${DEBUG:-0} -eq 1 ]] && printf '%b[DBG]\e[0m %s\n' "${_DIM}" "$*" || :; }

# Verbose logging (only when VERBOSE=1)
verbose() { [[ ${VERBOSE:-0} -eq 1 ]] && printf '%s\n' "$*" || :; }

# =============================================================================
# ERROR HANDLING
# =============================================================================

# Print error and exit
die() {
  err "$@"
  exit "${2:-1}"
}

# Require a command to exist
need() {
  has "$1" || die "Required command not found: $1"
}

# =============================================================================
# PRIVILEGE ESCALATION
# =============================================================================

# Detect privilege escalation command (sudo-rs → sudo → doas)
_get_priv_cmd() {
  local c
  for c in sudo-rs sudo doas; do
    has "$c" && { printf '%s' "$c"; return 0; }
  done
  [[ $EUID -eq 0 ]] || die "No privilege tool found and not root."
}

# Cache privilege command
PRIV_CMD=${PRIV_CMD:-$(_get_priv_cmd 2>/dev/null || true)}

# Run command with privilege escalation if needed
run_priv() {
  if [[ $EUID -eq 0 || -z ${PRIV_CMD:-} ]]; then
    "$@"
  else
    "$PRIV_CMD" -- "$@"
  fi
}

# =============================================================================
# PACKAGE MANAGER DETECTION
# =============================================================================

# Detect package manager (Arch: paru→yay→pacman, Debian: apt)
_detect_pm() {
  if has paru; then printf 'paru'
  elif has yay; then printf 'yay'
  elif has pacman; then printf 'pacman'
  elif has apt; then printf 'apt'
  else printf ''
  fi
}

PKG_MGR=${PKG_MGR:-$(_detect_pm)}

# =============================================================================
# TOOL DETECTION WITH FALLBACKS
# =============================================================================

# Fuzzy finder (sk → fzf)
_detect_fuzzy() {
  if has sk; then printf 'sk'
  elif has fzf; then printf 'fzf'
  else printf ''
  fi
}
FZF=${FZF:-$(_detect_fuzzy)}

# fd (fdf → fd → fdfind → find)
_detect_fd() {
  if has fdf; then printf 'fdf'
  elif has fd; then printf 'fd'
  elif has fdfind; then printf 'fdfind'
  else printf 'find'
  fi
}
FD=${FD:-$(_detect_fd)}

# ripgrep (rg → grep)
_detect_rg() {
  if has rg; then printf 'rg'
  else printf 'grep'
  fi
}
RG=${RG:-$(_detect_rg)}

# bat (bat → batcat → cat)
_detect_bat() {
  if has bat; then printf 'bat'
  elif has batcat; then printf 'batcat'
  else printf 'cat'
  fi
}
BAT=${BAT:-$(_detect_bat)}

# jq (jaq → jq)
_detect_jq() {
  if has jaq; then printf 'jaq'
  elif has jq; then printf 'jq'
  else printf ''
  fi
}
JQ=${JQ:-$(_detect_jq)}

# git (gix → git)
_detect_git() {
  if has gix; then printf 'gix'
  elif has git; then printf 'git'
  else printf ''
  fi
}
GIT=${GIT:-$(_detect_git)}

# =============================================================================
# ENVIRONMENT DETECTION
# =============================================================================

# Check if running on Wayland
is_wayland() {
  [[ ${XDG_SESSION_TYPE:-} == wayland || -n ${WAYLAND_DISPLAY:-} ]]
}

# Check if running on Arch Linux
is_arch() { has pacman; }

# Check if running on Debian/Raspbian
is_debian() { has apt && [[ -f /etc/debian_version ]]; }

# Check if running in Termux
is_termux() { [[ -n ${TERMUX_VERSION:-} ]]; }

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Create temp directory with cleanup trap
mktmpdir() {
  local tmpdir
  if tmpdir=$(mktemp -d); then
    trap 'rm -rf "$tmpdir"' EXIT
    printf '%s' "$tmpdir"
  else
    die "Failed to create temp directory"
  fi
}

# Safe file stat (cross-platform)
file_size() {
  if stat --version &>/dev/null; then
    stat -c%s "$1"
  else
    stat -f%z "$1"
  fi
}

# Check if file is newer than another
is_newer() {
  [[ $1 -nt $2 ]]
}

# =============================================================================
# CLEANUP
# =============================================================================

# Unset internal detection functions to avoid polluting namespace
unset -f _get_priv_cmd _detect_pm _detect_fuzzy _detect_fd _detect_rg _detect_bat _detect_jq _detect_git

# vim: set ft=bash ts=2 sw=2 et:
