#!/usr/bin/env bash
set -uo pipefail; shopt -s nullglob globstar
IFS=$'\n\t'; export LC_ALL=C LANG=C LANGUAGE=C

# Git repository cleanup script with GitHub integration
# Cleans merged branches, stale PRs, and performs maintenance

# Options
DRY_RUN=false
AUTO_YES=false
VERBOSE=false

# Statistics
DELETED_BRANCHES=0
DELETED_REMOTE_BRANCHES=0

die(){ printf '%s\n' "$1" >&2; exit 1; }
msg(){ printf '\033[0;96m==> %s\033[0m\n' "$1"; }
warn(){ printf '\033[0;93mWARN: %s\033[0m\n' "$1"; }
ok(){ printf '\033[0;92m%s\033[0m\n' "$1"; }
err(){ printf '\033[0;31mERROR: %s\033[0m\n' "$1" >&2; }
verbose(){ [[ $VERBOSE == true ]] && printf '\033[0;90m%s\033[0m\n' "$1" || :; }
usage(){
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
#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t'; export LC_ALL=C LANG=C DEBIAN_FRONTEND=noninteractive HOME="${HOME:-/home/${SUDO_USER:-$USER}}"

# GIT CLEAN/UPDATE TOOL:
# - Prunes and deletes merged/local/PR branches
# - Updates trunk and submodules, deep cleans all git metadata
# - Optional GitHub PR/poi, dry-run/auto-confirm support, detailed summary output

# Options
DRY_RUN=false
AUTO_YES=false
VERBOSE=false

DELETED_BRANCHES=0
DELETED_REMOTE_BRANCHES=0

die(){ printf '%s\n' "$1" >&2; exit 1; }
msg(){ printf '\033[0;96m==> %s\033[0m\n' "$1"; }
warn(){ printf '\033[0;93mWARN: %s\033[0m\n' "$1"; }
ok(){ printf '\033[0;92m%s\033[0m\n' "$1"; }
err(){ printf '\033[0;31mERROR: %s\033[0m\n' "$1" >&2; }
verbose(){ [[ $VERBOSE == true ]] && printf '\033[0;90m%s\033[0m\n' "$1" || :; }
usage(){
cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Clean, update, and optimize a git repo (branches, remotes, submodules, metadata).

OPTIONS:
  -d, --dry-run     Show what would be deleted, no actual changes
  -y, --yes         Auto-confirm all deletions
  -v, --verbose     Extra diagnostic output
  -h, --help        Show this help
FEATURES
  - Updates trunk branch (main/master), submodules (deep sync + clean)
  - Removes locally merged branches, merged PR branches (with gh CLI)
  - Cleans stale remotes, deep cleans refs, runs aggressive optimization
  - Supports gitoxide (gix), GitHub CLI/poi extension when available
EOF
exit 0
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--dry-run) DRY_RUN=true; shift ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -v|--verbose) VERBOSE=true; shift ;;
    -h|--help) usage ;;
    *) die "Unknown option: $1. Use --help for usage." ;;
  esac
done

[[ $DRY_RUN == true ]] && msg "DRY RUN MODE - No actual changes performed"

if command -v gix &>/dev/null; then
  verbose "Using gitoxide (gix)"
  GIT_CMD=gix
else
  command -v git &>/dev/null || die "git not found"
  GIT_CMD=git
  verbose "Using git cli"
fi

[[ -d .git ]] || die "Not a git repository: $PWD"

msg "Checking for uncommitted changes..."
if [[ $($GIT_CMD diff HEAD) ]] || [[ $($GIT_CMD diff --cached) ]]; then
  err "Uncommitted changes found. Please stash or commit first."
  $GIT_CMD diff HEAD --stat || :
  $GIT_CMD diff --cached --stat || :
  exit 1
fi
ok "No uncommitted changes"

# Detect trunk branch
trunk=
if $GIT_CMD branch --list master 2>/dev/null | grep -q master; then
  trunk=master
elif $GIT_CMD branch --list main 2>/dev/null | grep -q main; then
  trunk=main
else
  die "No trunk branch (main/master) found"
fi
msg "Using trunk branch: $trunk"

msg "Updating $trunk..."
if [[ $DRY_RUN == false ]]; then
  $GIT_CMD checkout "$trunk"
  msg "Fetching and pruning..."
  $GIT_CMD fetch --prune || :
  trunk_remote=$($GIT_CMD config --get "branch.$trunk.remote" 2>/dev/null || echo "origin")
  verbose "Remote for $trunk: ${trunk_remote:-origin}"
  if [[ -n $trunk_remote ]]; then
    $GIT_CMD pull "$trunk_remote" "$trunk" || $GIT_CMD pull origin "$trunk" || :
  else
    $GIT_CMD pull origin "$trunk" || :
  fi
else
  verbose "Would update $trunk from remote"
fi

msg "Cleaning stale remote tracking branches..."
stale_count=0
while IFS= read -r branch; do
  [[ -z $branch ]] && continue
  ((stale_count++))
  verbose "Found stale remote branch: $branch"
done < <($GIT_CMD remote prune origin --dry-run 2>&1 | grep '^\s*\*' | sd '^\s*\* ' '')

if [[ $stale_count -gt 0 ]]; then
  if [[ $DRY_RUN == false ]]; then
    $GIT_CMD remote prune origin
    ok "Pruned $stale_count stale remote tracking branch(es)"
    DELETED_REMOTE_BRANCHES=$stale_count
  else
    msg "Would prune $stale_count stale remote tracking branch(es)"
  fi
else
  ok "No stale remote tracking branches"
fi

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
      $GIT_CMD branch -D "$branch" && ((merged_count++)) || warn "Failed to delete $branch"
    else
      verbose "Would delete merged branch: $branch"
      ((merged_count++))
    fi
  fi
done < <($GIT_CMD branch --merged "$trunk" --format='%(refname:short)')

if [[ $merged_count -gt 0 ]]; then
  ok "Deleted $merged_count merged branch(es)"
  DELETED_BRANCHES=$merged_count
else
  ok "No merged branches to delete"
fi

# Prune branches with merged PRs (gh CLI)
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
          $GIT_CMD branch -D "$branch" && ((pr_count++)) || warn "Failed to delete $branch"
        else
          verbose "Would delete PR-merged branch: $branch"
          ((pr_count++))
        fi
      fi
    fi
  done < <($GIT_CMD branch --format='%(refname:short)')
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
    gh poi || warn "gh-poi failed or none found"
  else
    verbose "Would run gh-poi"
  fi
else
  verbose "gh-poi extension not available, skipping"
fi

msg "Updating submodules (sync/reset/clean)..."
if [[ $DRY_RUN == false ]]; then
  $GIT_CMD submodule sync --recursive
  # fallback 1/2/3-depth for shallow submodules, fallback as needed
  $GIT_CMD submodule update --init --recursive --remote --filter=blob:none --depth 1 --single-branch --jobs 8 \
    || $GIT_CMD submodule update --init --recursive --remote --depth 1 --jobs 8 \
    || $GIT_CMD submodule update --init --recursive --remote --jobs 8 || :
  $GIT_CMD submodule foreach --recursive '
    echo "  Submodule: $name ($sm_path)"
    git fetch --prune --no-tags origin --depth=1 || git fetch --prune --no-tags origin || :
    git reset --hard origin/HEAD || :
    git repack -adq --depth=100 --window=100 || :
    git reflog expire --expire=now --all || :
    git gc --auto --prune=now || :
    git clean -fdXq || :
  '
  ok "Submodules updated/cleaned"
else
  msg "Would update/init/reset/clean all submodules"
fi

msg "Running git optimization..."

if [[ $DRY_RUN == false ]]; then
  verbose "Running git repack..."
  $GIT_CMD repack -a -d --depth=250 --window=250
  verbose "Running git gc..."
  $GIT_CMD gc --aggressive --prune=now
  verbose "Cleaning reflog..."
  $GIT_CMD reflog expire --expire=30.days.ago --all
  $GIT_CMD reflog expire --expire-unreachable=7.days.ago --all
  verbose "Pruning worktrees..."
  $GIT_CMD worktree prune
  verbose "Running git maintenance..."
  $GIT_CMD maintenance run || verbose "git maintenance not available"
  verbose "Cleaning .git directory..."
  $GIT_CMD prune
  ok "Optimization complete"
else
  msg "Would run optimization: repack/gc/expire/worktree/maintenance/prune"
fi

echo
msg "=== Cleanup Summary ==="
printf "  Trunk branch: %s\n" "$trunk"
printf "  Deleted local branches: %d\n" "$DELETED_BRANCHES"
printf "  Pruned remote tracking branches: %d\n" "$DELETED_REMOTE_BRANCHES"
if [[ $DRY_RUN == true ]]; then
  echo
  warn "DRY RUN - No actual changes made"
fi

ok "Repo cleanup/maintenance complete"leanup"
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
