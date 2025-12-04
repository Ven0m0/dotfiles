#!/usr/bin/env bash
# fix-spaces - Remove non-standard whitespace and trailing spaces from files

set -euo pipefail
IFS=$'\n\t'

# ANSI colors
BLD=$'\e[1m' GRN=$'\e[32m' BLU=$'\e[34m' RED=$'\e[31m' DEF=$'\e[0m'

# Helper functions
has() { command -v "$1" &>/dev/null; }
log() { printf '%b==>\e[0m %s\n' "${BLD}${BLU}" "$*"; }
ok() { printf '%b==>\e[0m %s\n' "${BLD}${GRN}" "$*"; }
die() { printf '%b==> ERROR:\e[0m %s\n' "${BLD}${RED}" "$*" >&2; exit "${2:-1}"; }
need() { has "$1" || die "Required command not found: $1"; }

need perl

collapse=false
while [[ "${1:-}" != "" ]]; do
  case "$1" in
    -c | --collapse)
      collapse=true
      shift
      ;;
    -h | --help)
      printf '%s\n' "Usage: $0 [-c|--collapse] file..." >&2
      exit 0
      ;;
    *) break ;;
  esac
done

if [[ $# -eq 0 ]]; then
  die "No files. Pass files or globs (e.g. '**/*.sh')."
fi

for f in "$@"; do
  [[ -f "$f" ]] || {
    log "skip: $f (not a regular file)"
    continue
  }
  if "$collapse"; then
    perl -CS -0777 -pe '
      s/[\x{00A0}\x{202F}\x{200B}\x{00AD}]+/ /g;
      s/[ \t]+$//mg;
      s/ {2,}/ /g;
    ' -i.bak -- "$f"
  else
    perl -CS -0777 -pe '
      s/[\x{00A0}\x{202F}\x{200B}\x{00AD}]+/ /g;
      s/[ \t]+$//mg;
    ' -i.bak -- "$f"
  fi
  ok "fixed: $f (backup: $f.bak)"
done
