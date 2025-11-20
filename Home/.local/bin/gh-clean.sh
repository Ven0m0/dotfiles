#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C LANG=C

die() { printf '%s\n' "$1" >&2; exit 1; }
msg() { printf '\033[0;96m==> %s\033[0m\n' "$1"; }
warn() { printf '\033[0;93mWARN: %s\033[0m\n' "$1"; }
ok() { printf '\033[0;92m%s\033[0m\n' "$1"; }
err() { printf '\033[0;31mERROR: %s\033[0m\n' "$1" >&2; }

command -v git &>/dev/null || die "git not found"
[[ -d .git ]] || die "Not a git repository"

# check uncommitted changes
msg "Checking for uncommitted changes..."
if [[ $(git diff HEAD) ]]; then
  err "Uncommitted changes found. Stash or commit first."
  git diff HEAD --stat
  exit 1
fi
ok "No uncommitted changes"

# determine trunk branch
trunk=
if git branch --list master &>/dev/null | grep -q master; then
  trunk=master
elif git branch --list main &>/dev/null | grep -q main; then
  trunk=main
else
  die "No trunk branch (master/main) found"
fi
msg "Using trunk branch: $trunk"

# update trunk
msg "Updating $trunk..."
git checkout "$trunk"
msg "Fetching and pruning..."
git fetch --prune
trunk_remote=$(git config --get "branch.$trunk.remote" 2>/dev/null || echo "")
if [[ -z $trunk_remote ]]; then
  git pull origin "$trunk"
else
  git pull
fi

# prune merged branches
msg "Pruning merged branches..."
while IFS= read -r branch; do
  [[ $branch == "$trunk" ]] && continue
  [[ -z $branch ]] && continue
  printf '\033[0;93mDelete merged branch %s? [y/N] \033[0m' "$branch"
  read -r reply
  [[ ${reply,,} == y ]] && git branch -D "$branch" || :
done < <(git branch --merged "$trunk" --format='%(refname:short)')
ok "Merged branch pruning complete"

# prune branches with merged PRs (requires gh CLI)
if command -v gh &>/dev/null; then
  msg "Pruning branches with merged PRs..."
  while IFS= read -r branch; do
    [[ $branch == "$trunk" ]] && continue
    [[ -z $branch ]] && continue
    merged=$(gh pr list --author @me --state merged --limit 1 --search "head:$branch" --json headRefName --jq '.[].headRefName' 2>/dev/null || :)
    if [[ -n $merged && $merged == "$branch" ]]; then
      printf '\033[0;93mDelete PR-merged branch %s? [y/N] \033[0m' "$branch"
      read -r reply
      [[ ${reply,,} == y ]] && git branch -D "$branch" || :
    fi
  done < <(git branch --format='%(refname:short)')
  ok "PR branch pruning complete"
else
  warn "gh CLI not found, skipping PR-based pruning"
fi

# gh-poi extension (if available)
if command -v gh &>/dev/null && gh extension list 2>/dev/null | grep -qF seachicken/gh-poi; then
  msg "Running gh-poi (stale branches)..."
  gh poi || :
fi

# git maintenance
msg "Running git gc --aggressive --prune=now..."
git gc --aggressive --prune=now
msg "Running git maintenance..."
git maintenance run

ok "Cleanup complete"
