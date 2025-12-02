#!/usr/bin/env bash
# fix-spaces - Remove non-standard whitespace and trailing spaces from files

# Source shared library
# shellcheck source=../lib/bash/stdlib.bash
. "${HOME}/.local/lib/bash/stdlib.bash" 2>/dev/null \
  || . "$(dirname "$(realpath "$0")")/../lib/bash/stdlib.bash" 2>/dev/null \
  || { echo "Error: stdlib.bash not found" >&2; exit 1; }

IFS=$'\n\t'

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
