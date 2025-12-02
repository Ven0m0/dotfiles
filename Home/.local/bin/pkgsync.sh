#!/usr/bin/env bash
# pkg-sync.sh: Export/Import Pacman and AUR packages

set -euo pipefail
IFS=$'\n\t'

FILE_NATIVE="pkglist_native.txt"
FILE_AUR="pkglist_aur.txt"

has() { command -v "$1" &> /dev/null; }
log() { printf -- ":: %s\n" "$*"; }
err() {
  printf -- "!! %s\n" "$*" >&2
  exit 1
}

check_deps() {
  has pacman || err "pacman not found."
  has paru || err "paru not found."
}

do_export() {
  log "Exporting native..."
  pacman -Qqne > "$FILE_NATIVE"
  log "Exporting AUR..."
  pacman -Qqme > "$FILE_AUR"
  log "Done."
}

do_import() {
  if [[ -s $FILE_NATIVE ]]; then
    log "Importing native..."
    sudo pacman -S --needed - < "$FILE_NATIVE" || log "Native import issues."
  else
    log "Skipping native (empty/missing)."
  fi

  if [[ -s $FILE_AUR ]]; then
    log "Importing AUR..."
    paru -S --needed - < "$FILE_AUR" || log "AUR import issues."
  else
    log "Skipping AUR (empty/missing)."
  fi
}

check_deps
case "${1:-}" in
  export) do_export ;;
  import) do_import ;;
  *) err "Usage: $0 [export|import]" ;;
esac
