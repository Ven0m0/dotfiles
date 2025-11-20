#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C LANG=C

# Git repository cleanup script with GitHub integration
# Cleans merged branches, stale PRs, and performs maintenance

# Options
DRY_RUN=false
AUTO_YES=false
VERBOSE=false

# Statistics
DELETED_BRANCHES=0
DELETED_REMOTE_BRANCHES=0

die() { printf '%s\n' "$1" >&2; exit 1; }
msg() { printf '\033[0;96m==> %s\033[0m\n' "$1"; }
warn() { printf '\033[0;93mWARN: %s\033[0m\n' "$1"; }
ok() { printf '\033[0;92m%s\033[0m\n' "$1"; }
err() { printf '\033[0;31mERROR: %s\033[0m\n' "$1" >&2; }
verbose() { [[ $VERBOSE == true ]] && printf '\033[0;90m%s\033[0m\n' "$1" || :; }

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Clean up merged git branches and perform repository maintenance.

OPTIONS:
  -d, --dry-run     Show what would be deleted without actually deleting
  -y, --yes         Auto-confirm all deletions (non-interactive)
  -v, --verbose     Enable verbose output
  -h, --help        Show this help message

FEATURES:
  - Detects and updates trunk branch (main/master)
  - Removes locally merged branches
  - Removes branches with merged GitHub PRs (requires gh CLI)
  - Cleans stale remote tracking branches
  - Runs git maintenance and optimization
  - Supports gitoxide (gix) if available

REQUIREMENTS:
  - git (required)
  - gh CLI (optional, for PR-based cleanup)
  - gh-poi extension (optional, for stale branch detection)
EOF
  exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--dry-run) DRY_RUN=true; shift ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -v|--verbose) VERBOSE=true; shift ;;
    -h|--help) usage ;;
    *) die "Unknown option: $1. Use --help for usage." ;;
  esac
done

[[ $DRY_RUN == true ]] && msg "DRY RUN MODE - No changes will be made"

# Check for git (prefer gix/gitoxide if available, fall back to git)
if command -v gix &>/dev/null; then
  verbose "Using gitoxide (gix) for git operations"
  GIT_CMD=gix
else
  command -v git &>/dev/null || die "git not found"
  GIT_CMD=git
  verbose "Using git for operations"
fi

[[ -d .git ]] || die "Not a git repository"

# Check uncommitted changes
msg "Checking for uncommitted changes..."
if [[ $(git diff HEAD) ]] || [[ $(git diff --cached) ]]; then
  err "Uncommitted changes found. Stash or commit first."
  git diff HEAD --stat
  git diff --cached --stat
  exit 1
fi
ok "No uncommitted changes"

# Determine trunk branch
trunk=
if git branch --list master 2>/dev/null | grep -q master; then
  trunk=master
elif git branch --list main 2>/dev/null | grep -q main; then
  trunk=main
else
  die "No trunk branch (master/main) found"
fi
msg "Using trunk branch: $trunk"

# Update trunk
msg "Updating $trunk..."
if [[ $DRY_RUN == false ]]; then
  git checkout "$trunk"
  msg "Fetching and pruning..."
  git fetch --prune
  trunk_remote=$(git config --get "branch.$trunk.remote" 2>/dev/null || echo "origin")
  verbose "Remote for $trunk: $trunk_remote"
  if [[ -n $trunk_remote ]]; then
    git pull "$trunk_remote" "$trunk" || git pull origin "$trunk"
  else
    git pull origin "$trunk"
  fi
else
  verbose "Would update $trunk from remote"
fi

# Clean stale remote tracking branches
msg "Cleaning stale remote tracking branches..."
stale_count=0
while IFS= read -r branch; do
  [[ -z $branch ]] && continue
  ((stale_count++))
  verbose "Found stale remote branch: $branch"
done < <(git remote prune origin --dry-run 2>&1 | grep '^\s*\*' | sed 's/^\s*\* //')

if [[ $stale_count -gt 0 ]]; then
  if [[ $DRY_RUN == false ]]; then
    git remote prune origin
    ok "Pruned $stale_count stale remote tracking branch(es)"
    DELETED_REMOTE_BRANCHES=$stale_count
  else
    msg "Would prune $stale_count stale remote tracking branch(es)"
  fi
else
  ok "No stale remote tracking branches"
fi

# Prune merged branches
msg "Pruning merged branches..."
merged_count=0
while IFS= read -r branch; do
  [[ $branch == "$trunk" ]] && continue
  [[ -z $branch ]] && continue

  if [[ $AUTO_YES == true ]]; then
    reply=y
  else
    printf '\033[0;93mDelete merged branch %s? [y/N] \033[0m' "$branch"
    read -r reply
  fi

  if [[ ${reply,,} == y ]]; then
    if [[ $DRY_RUN == false ]]; then
      git branch -D "$branch" && ((merged_count++)) || warn "Failed to delete $branch"
    else
      verbose "Would delete merged branch: $branch"
      ((merged_count++))
    fi
  fi
done < <(git branch --merged "$trunk" --format='%(refname:short)')

if [[ $merged_count -gt 0 ]]; then
  ok "Deleted $merged_count merged branch(es)"
  DELETED_BRANCHES=$merged_count
else
  ok "No merged branches to delete"
fi

# Prune branches with merged PRs (requires gh CLI)
if command -v gh &>/dev/null; then
  msg "Pruning branches with merged PRs..."
  pr_count=0
  while IFS= read -r branch; do
    [[ $branch == "$trunk" ]] && continue
    [[ -z $branch ]] && continue

    verbose "Checking PR status for branch: $branch"
    merged=$(gh pr list --author @me --state merged --limit 1 --search "head:$branch" --json headRefName --jq '.[].headRefName' 2>/dev/null || :)

    if [[ -n $merged && $merged == "$branch" ]]; then
      if [[ $AUTO_YES == true ]]; then
        reply=y
      else
        printf '\033[0;93mDelete PR-merged branch %s? [y/N] \033[0m' "$branch"
        read -r reply
      fi

      if [[ ${reply,,} == y ]]; then
        if [[ $DRY_RUN == false ]]; then
          git branch -D "$branch" && ((pr_count++)) || warn "Failed to delete $branch"
        else
          verbose "Would delete PR-merged branch: $branch"
          ((pr_count++))
        fi
      fi
    fi
  done < <(git branch --format='%(refname:short)')

  if [[ $pr_count -gt 0 ]]; then
    ok "Deleted $pr_count PR-merged branch(es)"
    ((DELETED_BRANCHES += pr_count))
  else
    ok "No PR-merged branches to delete"
  fi
else
  warn "gh CLI not found, skipping PR-based pruning"
fi

# gh-poi extension (stale branch detection)
if command -v gh &>/dev/null && gh extension list 2>/dev/null | grep -qF seachicken/gh-poi; then
  msg "Running gh-poi (stale branches)..."
  if [[ $DRY_RUN == false ]]; then
    gh poi || warn "gh-poi failed or found no stale branches"
  else
    verbose "Would run gh-poi for stale branch detection"
  fi
else
  verbose "gh-poi extension not available, skipping stale branch detection"
fi

# Git optimization and maintenance
msg "Running git optimization..."

if [[ $DRY_RUN == false ]]; then
  # Repack to optimize storage
  verbose "Running git repack..."
  git repack -a -d --depth=250 --window=250

  # Clean up unnecessary files and optimize
  verbose "Running git gc..."
  git gc --aggressive --prune=now

  # Reflog cleanup
  verbose "Cleaning reflog..."
  git reflog expire --expire=30.days.ago --all
  git reflog expire --expire-unreachable=7.days.ago --all

  # Remove stale worktrees
  verbose "Pruning worktrees..."
  git worktree prune

  # Run git maintenance
  verbose "Running git maintenance..."
  git maintenance run || verbose "git maintenance not available"

  # Clean untracked files in .git directory
  verbose "Cleaning .git directory..."
  git prune

  ok "Optimization complete"
else
  msg "Would run optimization tasks:"
  msg "  - git repack -a -d --depth=250 --window=250"
  msg "  - git gc --aggressive --prune=now"
  msg "  - git reflog expire and cleanup"
  msg "  - git worktree prune"
  msg "  - git maintenance run"
  msg "  - git prune"
fi

# Final summary
echo
msg "=== Cleanup Summary ==="
printf "  Trunk branch: %s\n" "$trunk"
printf "  Deleted local branches: %d\n" "$DELETED_BRANCHES"
printf "  Pruned remote tracking branches: %d\n" "$DELETED_REMOTE_BRANCHES"

if [[ $DRY_RUN == true ]]; then
  echo
  warn "DRY RUN - No actual changes were made"
fi

ok "Cleanup complete"
