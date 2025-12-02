#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C

if ! command -v perl &> /dev/null; then
  printf '%s\n' "perl required, aborting" >&2
  exit 2
fi
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
  printf '%s\n' "No files. Pass files or globs (e.g. '**/*.sh')." >&2
  exit 2
fi

for f in "$@"; do
  [[ -f "$f" ]] || {
    printf '%s\n' "skip: $f (not a regular file)"
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
  printf '%s\n' "fixed: $f (backup: $f.bak)"
done
