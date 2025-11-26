#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t'; export LC_ALL=C LANG=C LANGUAGE=C
# Git maintenance: cleanup + update with submodule support
DRY_RUN=false
AUTO_YES=true
VERBOSE=false
MODE=clean
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
Usage: $(basename "$0") [MODE] [OPTIONS]

Git repository maintenance: cleanup merged branches and update from remote.

MODES:
  clean         Clean merged branches and optimize (default)
  update        Update from remote with submodules
  both          Run update then clean

OPTIONS:
  -d, --dry-run     Show actions without executing
  -y, --yes         Auto-confirm deletions (non-interactive)
  -v, --verbose     Verbose output
  -h, --help        Show help

FEATURES:
  - Trunk detection (main/master)
  - Merged branch cleanup (local + PR-based via gh)
  - Stale remote pruning
  - Submodule sync and update
  - Git optimization (repack, gc, reflog, maintenance)
  - gitoxide (gix) support
EOF
  exit 0
}
while [[ $# -gt 0 ]]; do
  case $1 in
    clean|update|both) MODE=$1; shift ;;
    -d|--dry-run) DRY_RUN=true; shift ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -v|--verbose) VERBOSE=true; shift ;;
    -h|--help) usage ;;
    *) die "Unknown option: $1" ;;
  esac
done
[[ $DRY_RUN == true ]] && msg "DRY RUN MODE"
if command -v gix &>/dev/null; then
  verbose "Using gitoxide (gix)"
  GIT_CMD=gix
else
  command -v git &>/dev/null || die "git not found"
  GIT_CMD=git
  verbose "Using git"
fi
[[ -d .git ]] || die "Not a git repository"
determine_trunk(){
  local trunk=
  if git branch --list master 2>/dev/null | grep -q master; then
    trunk=master
  elif git branch --list main 2>/dev/null | grep -q main; then
    trunk=main
  else
    die "No trunk branch (master/main) found"
  fi
  printf '%s' "$trunk"
}
update_repo(){
  msg "Updating repository..."
  local trunk=$(determine_trunk)
  verbose "Trunk: $trunk"
  if [[ $DRY_RUN == false ]]; then
    git remote prune origin &>/dev/null || :
    git -c protocol.file.allow=always fetch --prune --no-tags --filter=blob:none origin \
      || git -c protocol.file.allow=always fetch --prune --no-tags origin \
      || die "Fetch failed"
    git checkout "$trunk" || die "Checkout $trunk failed"
    git -c protocol.file.allow=always pull --rebase --autostash --prune origin "$trunk" \
      || { git rebase --abort &>/dev/null || :; warn "Pull failed, continuing"; }
    if git config --get-regexp '^submodule\.' &>/dev/null; then
      msg "Syncing submodules..."
      git -c protocol.file.allow=always submodule sync --recursive &>/dev/null || :
      git -c protocol.file.allow=always submodule update --init --recursive --remote --filter=blob:none --depth 1 --single-branch --jobs 8 \
        || git -c protocol.file.allow=always submodule update --init --recursive --remote --depth 1 --jobs 8 \
        || git -c protocol.file.allow=always submodule update --init --recursive --remote --jobs 8 \
        || warn "Submodule update partial/failed"
    fi
    ok "Update complete"
  else
    verbose "Would update $trunk from remote and sync submodules"
  fi
}
clean_repo(){
  msg "Cleaning repository..."
  local trunk
  trunk=$(determine_trunk)
  if [[ $DRY_RUN == false ]]; then
    git checkout "$trunk" &>/dev/null || die "Checkout $trunk failed"
    msg "Checking uncommitted changes..."
    if [[ -n $(git diff HEAD) ]] || [[ -n $(git diff --cached) ]]; then
      err "Uncommitted changes found. Stash or commit first."
      git diff HEAD --stat
      git diff --cached --stat
      exit 1
    fi
    ok "No uncommitted changes"
    msg "Fetching and pruning..."
    git -c protocol.file.allow=always fetch --prune || die "Fetch failed"
    trunk_remote=$(git config --get "branch.$trunk.remote" 2>/dev/null || echo "origin")
    git pull "$trunk_remote" "$trunk" || git pull origin "$trunk" || warn "Pull failed"
  else
    verbose "Would fetch and update $trunk"
  fi
  msg "Pruning stale remote tracking branches..."
  local stale_count=0
  while IFS= read -r branch; do
    [[ -z $branch ]] && continue
    ((stale_count++))
    verbose "Stale: $branch"
  done < <(git remote prune origin --dry-run 2>&1 | grep '^\s*\*' | sed 's/^\s*\* //')
  if [[ $stale_count -gt 0 ]]; then
    if [[ $DRY_RUN == false ]]; then
      git remote prune origin &>/dev/null
      ok "Pruned $stale_count remote branch(es)"
      DELETED_REMOTE_BRANCHES=$stale_count
    else
      msg "Would prune $stale_count remote branch(es)"
    fi
  else
    ok "No stale remote branches"
  fi
  msg "Deleting merged branches..."
  local merged_count=0
  while IFS= read -r branch; do
    [[ $branch == "$trunk" ]] && continue
    [[ -z $branch ]] && continue
    if [[ $AUTO_YES == true ]]; then
      reply=y
    else
      printf '\033[0;93mDelete merged %s? [y/N] \033[0m' "$branch"
      read -r reply
    fi
    if [[ ${reply,,} == y ]]; then
      if [[ $DRY_RUN == false ]]; then
        git branch -D "$branch" &>/dev/null && ((merged_count++)) || warn "Failed: $branch"
      else
        verbose "Would delete: $branch"
        ((merged_count++))
      fi
    fi
  done < <(git branch --merged "$trunk" --format='%(refname:short)')
  [[ $merged_count -gt 0 ]] && ok "Deleted $merged_count merged branch(es)" || ok "No merged branches"
  DELETED_BRANCHES=$merged_count
  if command -v gh &>/dev/null; then
    msg "Checking PR-merged branches..."
    local pr_count=0
    while IFS= read -r branch; do
      [[ $branch == "$trunk" ]] && continue
      [[ -z $branch ]] && continue
      verbose "Checking PR: $branch"
      merged=$(gh pr list --author @me --state merged --limit 1 --search "head:$branch" --json headRefName --jq '.[].headRefName' 2>/dev/null || :)
      if [[ -n $merged && $merged == "$branch" ]]; then
        if [[ $AUTO_YES == true ]]; then
          reply=y
        else
          printf '\033[0;93mDelete PR-merged %s? [y/N] \033[0m' "$branch"
          read -r reply
        fi
        if [[ ${reply,,} == y ]]; then
          if [[ $DRY_RUN == false ]]; then
            git branch -D "$branch" &>/dev/null && ((pr_count++)) || warn "Failed: $branch"
          else
            verbose "Would delete: $branch"
            ((pr_count++))
          fi
        fi
      fi
    done < <(git branch --format='%(refname:short)')
    if [[ $pr_count -gt 0 ]]; then
      ok "Deleted $pr_count PR-merged branch(es)"
      ((DELETED_BRANCHES += pr_count))
    else
      ok "No PR-merged branches"
    fi
    if gh extension list 2>/dev/null | grep -qF seachicken/gh-poi; then
      msg "Running gh-poi..."
      [[ $DRY_RUN == false ]] && { gh poi || warn "gh-poi failed"; } || verbose "Would run gh-poi"
    fi
  else
    verbose "gh CLI not found, skipping PR checks"
  fi
  msg "Optimizing repository..."
  if [[ $DRY_RUN == false ]]; then
    verbose "Repack..."
    git repack -adbq --depth=250 --window=250 &>/dev/null || :
    verbose "GC..."
    git gc --aggressive --prune=now --quiet &>/dev/null || :
    verbose "Reflog..."
    git reflog expire --expire=30.days.ago --all &>/dev/null || :
    git reflog expire --expire-unreachable=7.days.ago --all &>/dev/null || :
    verbose "Worktrees..."
    git worktree prune &>/dev/null || :
    verbose "Maintenance..."
    git maintenance run &>/dev/null || :
    git prune &>/dev/null || :
    if git config --get-regexp '^submodule\.' &>/dev/null; then
      verbose "Optimizing submodules..."
      git submodule foreach --recursive '
        git repack -adbq --depth=100 --window=100 >/dev/null 2>&1 || :
        git reflog expire --expire=now --all >/dev/null 2>&1 || :
        git gc --auto --prune=now --quiet >/dev/null 2>&1 || :
        git clean -fdXq >/dev/null 2>&1 || :
      ' &>/dev/null || :
    fi
    ok "Optimization complete"
  else
    msg "Would optimize: repack, gc, reflog, worktrees, maintenance"
  fi
}
case $MODE in
  update) update_repo ;;
  clean) clean_repo ;;
  both) update_repo; clean_repo ;;
esac
echo
msg "=== Summary ==="
printf "  Mode: %s\n" "$MODE"
[[ $MODE == clean || $MODE == both ]] && {
  printf "  Deleted local: %d\n" "$DELETED_BRANCHES"
  printf "  Pruned remote: %d\n" "$DELETED_REMOTE_BRANCHES"
}
[[ $DRY_RUN == true ]] && warn "DRY RUN - No changes made"
ok "Complete"
