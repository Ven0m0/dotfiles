#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
export LC_ALL=C LANG=C IFS=$'\n\t'

# Completely remove Git submodules
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>

# Colors
readonly RED=$'\e[0;31m' GREEN=$'\e[0;32m' YELLOW=$'\e[0;33m' RESET=$'\e[0m'

# Helper functions
die() {
  printf '%bError: %s%b\n' "$RED" "$*" "$RESET" >&2
  exit 1
}
log() { printf '%s\n' "$*"; }
ok() { printf '%b[ OK ]%b\n' "$GREEN" "$RESET"; }
fail() { printf '%b[FAIL]%b\n' "$RED" "$RESET"; }

# Log file for operations
readonly LOG_FILE=$(mktemp)
trap 'rm -f "$LOG_FILE"' EXIT

usage() {
  cat <<'EOF'
git-rm-submodule - Completely remove Git submodules

USAGE:
  git-rm-submodule MODULE [MODULE...]

ARGUMENTS:
  MODULE    Path to submodule(s) to remove

OPTIONS:
  -h, --help  Show this help message

DESCRIPTION:
  Completely removes Git submodule(s) from the repository. This includes:
  - Deinitializing the submodule
  - Removing from working directory
  - Cleaning up .git/modules/

  This command must be run from the root of your Git repository.

EXAMPLES:
  git-rm-submodule libs/vendor
  git-rm-submodule sub1 sub2 sub3

REQUIREMENTS:
  - git (with submodule support)
  - Must be run from Git repository root

NOTE:
  After removal, you'll need to commit the changes:
    git commit -m "Remove submodule: MODULE"
EOF
}

check_args() {
  [[ ${#} -ge 1 ]] || die "Expected at least 1 argument, got ${#}"
  [[ -d ${PWD}/.git ]] || die "Not a Git repository. Run from repository root."
}

remove_git_submodule() {
  local submodule="$1"

  printf '  Deinitializing submodule                  '
  if git submodule deinit "$submodule" >>"$LOG_FILE" 2>&1; then
    ok
  else
    fail
    cat "$LOG_FILE"
    return 1
  fi

  printf '  Removing from working directory            '
  if git rm "$submodule" >>"$LOG_FILE" 2>&1; then
    ok
  else
    fail
    cat "$LOG_FILE"
    return 1
  fi

  printf '  Removing from .git/modules/                '
  if rm -rf ".git/modules/${submodule}" >>"$LOG_FILE" 2>&1; then
    ok
  else
    fail
    cat "$LOG_FILE"
    return 1
  fi
}

remove_git_submodules() {
  for module in "$@"; do
    printf '%b--- Removing module: %s ---%b\n' "$YELLOW" "$module" "$RESET"
    remove_git_submodule "$module"
  done
}

main() { # Check for help
  for arg in "$@"; do
    if [[ $arg == -h || $arg == --help ]]; then
      usage
      exit 0
    fi
  done

  check_args "$@"
  remove_git_submodules "$@"

  log ""
  printf '%b✓ All submodules removed successfully%b\n' "$GREEN" "$RESET"
  log "Don't forget to commit the changes:"
  log "  git commit -m 'Remove submodules'"
}

main "$@"
