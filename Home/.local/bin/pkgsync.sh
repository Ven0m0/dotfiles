#!/usr/bin/env bash
# pkg-sync.sh: Export/Import Pacman and AUR packages

set -euo pipefail
IFS=$'\n\t'

# ANSI colors
BLD=$'\e[1m' BLU=$'\e[34m' RED=$'\e[31m' DEF=$'\e[0m'

# Helper functions
has(){ command -v "$1" &>/dev/null; }
log(){ printf '%b==>\e[0m %s\n' "${BLD}${BLU}" "$*"; }
die(){ printf '%b==> ERROR:\e[0m %s\n' "${BLD}${RED}" "$*" >&2; exit "${2:-1}"; }
need(){ has "$1" || die "Required command not found: $1"; }

# Privilege escalation helper
_get_priv(){
  local c
  for c in sudo-rs sudo doas; do has "$c" && { printf '%s' "$c"; return 0; }; done
  [[ $EUID -eq 0 ]] || die "No privilege tool found and not root."
}
PRIV_CMD=$(_get_priv 2>/dev/null || true)
run_priv(){
  if [[ $EUID -eq 0 || -z ${PRIV_CMD:-} ]]; then "$@"; else "$PRIV_CMD" -- "$@"; fi
}

FILE_NATIVE="pkglist_native.txt"
FILE_AUR="pkglist_aur.txt"

check_deps(){
  need pacman
  need paru
}

do_export(){
  log "Exporting native..."
  pacman -Qqne > "$FILE_NATIVE"
  log "Exporting AUR..."
  pacman -Qqme > "$FILE_AUR"
  log "Done."
}

do_import(){
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
