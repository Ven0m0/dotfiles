#!/usr/bin/env bash
#
# pkg-sync.sh: Export/Import Pacman and AUR packages
# Usage: ./pkg-sync.sh [export|import]

set -euo pipefail
IFS=$'\n\t'

# Configuration
FILE_NATIVE="pkglist_native.txt"
FILE_AUR="pkglist_aur.txt"

# Helpers
log() { printf -- ":: %s\n" "$*"; }
err() {
  printf -- "!! %s\n" "$*" >&2
  exit 1
}

check_deps() {
  command -v pacman &>/dev/null || err "pacman not found."
  command -v paru &>/dev/null || err "paru not found."
}

# Core Functions
do_export() {
  log "Exporting native packages (explicit) to ${FILE_NATIVE}..."
  # -Q: Query, -q: quiet (names only), -n: native, -e: explicit
  pacman -Qqne >"$FILE_NATIVE"

  log "Exporting AUR packages (explicit) to ${FILE_AUR}..."
  # -m: foreign (AUR)
  pacman -Qqme >"$FILE_AUR"

  log "Export complete."
}

do_import() {
  # Native Import
  if [[ -f "$FILE_NATIVE" ]]; then
    log "Installing missing native packages from ${FILE_NATIVE}..."
    # --needed: skips up-to-date packages
    # sudo is required for pacman operations
    sudo pacman -S --needed - <"$FILE_NATIVE" || log "Native import had warnings/errors."
  else
    log "Skipping native: ${FILE_NATIVE} not found."
  fi

  # AUR Import
  if [[ -f "$FILE_AUR" ]]; then
    log "Installing missing AUR packages from ${FILE_AUR}..."
    # paru handles sudo internally, usually shouldn't run paru as root directly
    paru -S --needed - <"$FILE_AUR" || log "AUR import had warnings/errors."
  else
    log "Skipping AUR: ${FILE_AUR} not found."
  fi

  log "Import cycle complete."
}

# Main Execution
check_deps

case "${1:-}" in
  export) do_export ;;
  import) do_import ;;
  *) err "Usage: $0 [export|import]" ;;
esac
