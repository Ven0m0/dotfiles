#!/usr/bin/env bash
export LC_ALL=C LANG=C

gitctl() {
  [ $# -eq 0 ]  && { echo "Usage: gitctl <git-repo-url> [directory]" >&2; return 1; }
  local dir url="$1" 
  # Use provided directory name or derive from URL
  if [ -n "$2" ]; then
    dir="$2"
  else
    # Strip trailing slashes and optional .git
    dir="$(basename "${url%%/}")"
    dir="${dir%.git}"
  fi
  # If the directory exists, just cd into it
  [[ -d "$dir" ]] && { cd -- "$dir" || return; return 0; } 
  if command -v gix &>/dev/null; then
    LC_ALL=C LANG=C gix clone "$url" "$dir" || return 1
  else
    # Clone the repo
    LC_ALL=C LANG=C git clone --depth 1 --single-branch --filter='blob:none' "$url" "$dir" || return 1
  fi
  # cd into the cloned repo
  cd -- "$dir" || return
  if [ -d "$dir" ]; then
    cd -- "$dir" || return
  return 0
  fi
}
