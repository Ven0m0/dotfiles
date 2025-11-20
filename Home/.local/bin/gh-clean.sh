#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C LANG=C

die() { printf '%s\n' "$1" >&2; exit 1; }
# validate environment
command -v gh &>/dev/null || die "gh CLI not found. Install: https://cli.github.com"
command -v git &>/dev/null || die "git not found"

[[ -d .git ]] || die "Not a git repository"

# check/install extensions
check_ext() {
  gh extension list 2>/dev/null | grep -qF "$1" && return 0
  printf 'Extension %s not found. Install? [y/N] ' "$1"
  read -r reply
  [[ ${reply,,} == y ]] && gh extension install "$2" || return 1
}

check_ext HaywardMorihara/gh-tidy HaywardMorihara/gh-tidy || die "gh-tidy required"
check_ext seachicken/gh-poi seachicken/gh-poi || die "gh-poi required"

# cleanup operations
printf '==> Removing merged branches (gh-tidy)...\n'
gh tidy || :

printf '==> Removing stale branches (gh-poi)...\n'
gh poi || :

printf '==> Running git gc --aggressive --prune=now...\n'
git gc --aggressive --prune=now

printf '==> Running git maintenance run...\n'
git maintenance run

printf '==> Cleanup complete\n'
