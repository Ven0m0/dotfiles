#!/bin/bash
set -e; LC_ALL=C
# jaq/jq wrapper: unify invocation for flags/compat
# Usage: jqwrap [jq_args...]
jqwrap(){
  if command -v jaq; then
    # --raw-input short: -R; --slurp: -s; --null-input: -n; all work the same in jaq, pass through
    jaq "$@"
  elif command -v jq &>/dev/null; then
    jq "$@"
  else
    printf 'error: neither jq nor jaq found in PATH\n' >&2; return 1
  fi
}
# support direct script use
[[ ${BASH_SOURCE[0]} != "$0" ]] || jqwrap "$@"
