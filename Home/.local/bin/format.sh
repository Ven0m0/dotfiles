#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C
has(){ command -v -- "$1" &>/dev/null; }
die(){ printf '%s\n' "$1" >&2; exit "${2:-1}"; }

indent="${1:-2}"
[[ ! $indent =~ ^[0-9]+$ ]] && die "Error: indent must be numeric"
spaces=$(printf "%${indent}s" ""); empty_seen=0
while IFS= read -r line || [[ -n $line ]]; do
  line="${line//$'\t'/$spaces}"
  if [[ -z $line ]]; then
    empty_seen=1
  else
    ((empty_seen)) && printf '\n'
    printf '%s\n' "$line"
    empty_seen=0
  fi
done

# vim:set sw=2 ts=2 et:
