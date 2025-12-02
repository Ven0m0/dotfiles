#!/usr/bin/env bash
# pkg-sync.sh: Export/Import Pacman and AUR packages

# Source shared library
# shellcheck source=../lib/bash/stdlib.bash
. "${HOME}/.local/lib/bash/stdlib.bash" 2>/dev/null \
  || . "$(dirname "$(realpath "$0")")/../lib/bash/stdlib.bash" 2>/dev/null \
  || { echo "Error: stdlib.bash not found" >&2; exit 1; }

IFS=$'\n\t'

FILE_NATIVE="pkglist_native.txt"
FILE_AUR="pkglist_aur.txt"

check_deps() {
  need pacman
  need paru
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
    run_priv pacman -S --needed - < "$FILE_NATIVE" || log "Native import issues."
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
  *) die "Usage: $0 [export|import]" ;;
esac
