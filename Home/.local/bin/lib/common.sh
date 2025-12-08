#!/usr/bin/env bash
# common.sh - Shared utilities for all scripts
# Source: source ~/.local/bin/lib/common.sh
# Guard: Prevents double-sourcing
[[ -n ${_COMMON_SH_LOADED:-} ]] && return 0
readonly _COMMON_SH_LOADED=1

# Strict mode defaults (can be overridden before sourcing)
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

#──────────── ANSI Colors ────────────
readonly RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' BLU=$'\e[34m'
readonly BLD=$'\e[1m' DEF=$'\e[0m'

#──────────── Core Utilities ────────────
# Check if command exists
has() { command -v "$1" &>/dev/null; }

# Fatal error with exit
die() {
  printf '%b[ERROR]%b %s\n' "${BLD}${RED}" "$DEF" "$*" >&2
  exit "${2:-1}"
}

# Informational log
log() { printf '%b[INFO]%b %s\n' "${BLD}${BLU}" "$DEF" "$*"; }

# Success message
ok() { printf '%b[OK]%b %s\n' "${BLD}${GRN}" "$DEF" "$*"; }

# Warning message
warn() { printf '%b[WARN]%b %s\n' "${BLD}${YLW}" "$DEF" "$*"; }

# Error (non-fatal)
err() { printf '%b[ERROR]%b %s\n' "${BLD}${RED}" "$DEF" "$*" >&2; }

#──────────── Tool Detection ────────────
# Cached tool detection - call once at script start
declare -gA _TOOL_CACHE=()

has_cached() {
  local tool="$1"
  if [[ -z ${_TOOL_CACHE[$tool]+x} ]]; then
    if command -v "$tool" &>/dev/null; then
      _TOOL_CACHE[$tool]=1
    else
      _TOOL_CACHE[$tool]=0
    fi
  fi
  [[ ${_TOOL_CACHE[$tool]} -eq 1 ]]
}

# Require tools or die
require() {
  local missing=()
  for tool in "$@"; do
    has "$tool" || missing+=("$tool")
  done
  [[ ${#missing[@]} -gt 0 ]] && die "Missing required tools: ${missing[*]}"
}

#──────────── File Operations ────────────
# Safe temp file with cleanup trap
mktempfile() {
  local tmp
  tmp=$(mktemp)
  # shellcheck disable=SC2064
  trap "rm -f '$tmp'" EXIT
  printf '%s' "$tmp"
}

# Atomic file write (write to temp, then move)
atomic_write() {
  local dest="$1" content="$2"
  local tmp
  tmp=$(mktemp "${dest}.XXXXXX")
  printf '%s' "$content" >"$tmp"
  mv -f "$tmp" "$dest"
}

#──────────── Validation ────────────
# Check if running as root
is_root() { [[ $EUID -eq 0 ]]; }

# Require non-root
require_nonroot() { is_root && die "Do not run as root"; }

# Require root
require_root() { is_root || die "Must run as root"; }

#──────────── Array Helpers ────────────
# Join array elements with delimiter
join_by() {
  local d="${1-}" f="${2-}"
  shift 2 || shift $(($#))
  printf '%s' "$f" "${@/#/$d}"
}

# Check if element exists in array
in_array() {
  local needle="$1"
  shift
  for item in "$@"; do
    [[ $item == "$needle" ]] && return 0
  done
  return 1
}
