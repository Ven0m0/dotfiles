#!/usr/bin/env bash
set -euo pipefail

has() { command -v -- "$1" &>/dev/null; }
die() { printf '\e[31mERROR: %s\e[0m\n' "$*" >&2; exit 1; }
log() { printf '\e[34mINFO: %s\e[0m\n' "$*"; }

# Fix KDE Plasma panels/menus not loading after boot
# Run this when taskbar/panels are missing
set -euo pipefail

has() { command -v -- "$1" &>/dev/null; }
die() { printf '\e[31mERROR: %s\e[0m\n' "$*" >&2; exit 1; }
log() { printf '\e[34mINFO: %s\e[0m\n' "$*"; }

# Fix KDE Plasma panels/menus not loading after boot
# Run this when taskbar/panels are missing
set -euo pipefail

has() { command -v -- "$1" &>/dev/null; }
die() { printf '\e[31mERROR: %s\e[0m\n' "$*" >&2; exit 1; }
log() { printf '\e[34mINFO: %s\e[0m\n' "$*"; }

main() {
  [[ $# -eq 0 ]] || die "Usage: fix-plasma-panels.sh"

  has pgrep || die "Required command not found: pgrep"
  has kill || die "Required command not found: kill"
  has sleep || die "Required command not found: sleep"
  has kbuildsycoca6 || die "Required command not found: kbuildsycoca6"
  has plasmashell || die "Required command not found: plasmashell"

  local pids=""
  local running_pids=""

  log "Killing plasmashell..."
  if pids=$(pgrep plasmashell 2>/dev/null); then
    kill -9 ${pids} 2>/dev/null || true
  else
    log "plasmashell is not currently running."
  fi
  sleep 2

  log "Rebuilding KDE config cache..."
  kbuildsycoca6 2>/dev/null || true

  log "Waiting for plasmashell to respawn..."
  sleep 3

  if running_pids=$(pgrep plasmashell 2>/dev/null); then
    log "plasmashell is running (PID: ${running_pids})"
  else
    log "Starting plasmashell..."
    plasmashell --no-respawn &
    disown
    sleep 3
  fi

  log "Done. Panels should be visible now."
}

main "$@"
