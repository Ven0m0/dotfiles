#!/usr/bin/env bash
# jaq/jq wrapper: unify invocation for flags/compat
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C LANG=C

has(){ command -v -- "$1" &>/dev/null; }
# Usage: jqwrap [jq_args...]
jqwrap(){
  local jqbin
  if has jaq; then
    jqbin=jaq
    # --raw-input short: -R; --slurp: -s; --null-input: -n; all work the same in jaq, pass through
    "$jqbin" "$@"
  elif has jq; then
    jqbin=jq
    "$jqbin" "$@"
  else
    printf 'error: neither jq nor jaq found in PATH\n' >&2; return 1
  fi
}

# support direct script use
[[ ${BASH_SOURCE[0]} != "$0" ]] || jqwrap "$@"
