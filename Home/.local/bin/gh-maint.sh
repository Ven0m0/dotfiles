#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar; IFS=$'\n\t'; export LC_ALL=C LANG=C LANGUAGE=C
# Git maintenance: cleanup + update with submodule support
DRY_RUN=false
AUTO_YES="${AUTO_YES:-true}"
VERBOSE=false
MODE="${MODE:-both}"
DELETED_BRANCHES=0
DELETED_REMOTE_BRANCHES=0
die() {
	printf '%s\n' "$1" >&2
	exit 1
}
msg() { printf '\033[0;96m==> %s\033[0m\n' "$1"; }
warn() { printf '\033[0;93mWARN: %s\033[0m\n' "$1"; }
ok() { printf '\033[0;92m%s\033[0m\n' "$1"; }
err() { printf '\033[0;31mERROR: %s\033[0m\n' "$1" >&2; }
verbose() { [[ $VERBOSE == true ]] && printf '\033[0;90m%s\033[0m\n' "$1" || :; }
usage() {
	cat <<EOF
Usage: $(basename "$0") [MODE] [OPTIONS]

Git repository maintenance: cleanup merged branches and update from remote.

MODES:
  clean         Clean merged branches and optimize (default)
  update        Update from remote with submodules
  both          Run update then clean
  merge         Auto-merge a PR. Expects PR URL and optional strategy.

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
  - Check for failed GHA workflows
  - Auto-merge PRs

MODES:
  clean         Clean merged branches and optimize (default)
  update        Update from remote with submodules
  both          Run update then clean
  merge         Auto-merge a PR. Expects PR URL and optional strategy.

EOF
	exit 0
}
while [[ $# -gt 0 ]]; do
	case $1 in
	clean | update | both)
		MODE=$1
		shift
		;;
	merge)
		MODE=$1
		shift
		PR_URL=${1:-}
		MERGE_STRATEGY=${2:-theirs}
		shift 2 || shift 1 || :
		;;
	-d | --dry-run)
		DRY_RUN=true
		shift
		;;
	-y | --yes)
		AUTO_YES=true
		shift
		;;
	-v | --verbose)
		VERBOSE=true
		shift
		;;
	-h | --help) usage ;;
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
determine_trunk() {
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
update_repo() {
	msg "Updating repository..."
	local trunk=$(determine_trunk)
	verbose "Trunk: $trunk"
	if [[ $DRY_RUN == false ]]; then
		git remote prune origin &>/dev/null || :
		git -c protocol.file.allow=always fetch --prune --no-tags --filter=blob:none origin ||
			git -c protocol.file.allow=always fetch --prune --no-tags origin ||
			die "Fetch failed"
		check_gha_failures
		git checkout "$trunk" &>/dev/null
		git-submodule-update &>/dev/null
		git reset --hard "origin/$trunk" &>/dev/null
		git -c protocol.file.allow=always pull --rebase --autostash --prune origin "$trunk" ||
			{
				git rebase --abort &>/dev/null || :
				warn "Pull failed, continuing"
			}
		if git config --get-regexp '^submodule\.' &>/dev/null; then
			msg "Syncing submodules..."
			git -c protocol.file.allow=always submodule sync --recursive &>/dev/null || :
			git -c protocol.file.allow=always submodule update --init --recursive --remote --filter=blob:none --depth 1 --single-branch --jobs 8 ||
				git -c protocol.file.allow=always submodule update --init --recursive --remote --depth 1 --jobs 8 ||
				git -c protocol.file.allow=always submodule update --init --recursive --remote --jobs 8 ||
				warn "Submodule update partial/failed"
		fi
		ok "Update complete"
	else
		verbose "Would update $trunk from remote and sync submodules"
	fi
}
clean_repo() {
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
	optimize_repo
}
check_gha_failures() {
	if ! command -v gh &>/dev/null; then
		warn "gh command not found, skipping GHA failure check."
		return
	fi
	local remote_url
	remote_url=$(git remote get-url origin)
	local repo_owner
	repo_owner=$(echo "$remote_url" | sed -E 's#.*github.com[:/]([^/]+)/.*#\1#')
	local repo_name
	repo_name=$(echo "$remote_url" | sed -E 's#.*github.com[:/].*/([^/]+).*#\1#' | sed 's/\.git$//')
	local run_id
	run_id=$(gh run list -L 1 --json databaseId -R "$repo_owner/$repo_name" 2>/dev/null | jq -r '.[0].databaseId')
	if [[ -z "$run_id" ]]; then
		verbose "No workflow runs found or failed to get run list."
		return
	fi
	local conclusion
	conclusion=$(gh run view "$run_id" --json conclusion -R "$repo_owner/$repo_name" 2>/dev/null | jq -r '.conclusion')
	if [[ -z "$conclusion" ]]; then
		err "Failed to get workflow run details."
		return
	fi
	if [[ "$conclusion" == "failure" ]]; then
		err "Latest workflow run failed. Please check the logs."
		gh run view "$run_id" --log-failed -R "$repo_owner/$repo_name"
	else
		verbose "The latest workflow run was successful."
	fi
}
auto_merge_pr() {
	[[ -n "$PR_URL" ]] || die "PR URL required for merge mode."
	local strategy="$MERGE_STRATEGY"
	local owner repo pr
	if [[ $PR_URL =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
		owner=${BASH_REMATCH[1]}
		repo=${BASH_REMATCH[2]}
		pr=${BASH_REMATCH[3]}
	elif (($# >= 2)) && [[ $PR_URL =~ / ]] && [[ $MERGE_STRATEGY =~ ^[0-9]+$ ]]; then
		IFS=/ read -r owner repo <<<"$PR_URL"
		pr=$MERGE_STRATEGY
		strategy=${3:-theirs}
	else
		die "Invalid PR URL or arguments."
	fi
	local work_dir
	work_dir=$(mktemp -d)
	trap 'rm -rf "$work_dir"' EXIT
	cd "$work_dir"
	msg "Fetching PR $owner/$repo#$pr..."
	command -v gh &>/dev/null || die "gh CLI not installed"
	local pr_info head_ref base_ref is_cross
	pr_info=$(gh pr view "$pr" -R "$owner/$repo" --json headRefName,baseRefName,headRepository,isCrossRepository)
	head_ref=$(jq -r .headRefName <<<"$pr_info")
	base_ref=$(jq -r .baseRefName <<<"$pr_info")
	is_cross=$(jq -r .isCrossRepository <<<"$pr_info")
	local head_repo
	if [[ $is_cross == true ]]; then
		head_repo=$(jq -r .headRepository.nameWithOwner <<<"$pr_info")
		[[ -n $head_repo && $head_repo != null ]] || die "Cannot access fork repo"
	else
		head_repo="$owner/$repo"
	fi
	git clone -q --depth 1 "https://github.com/$head_repo.git" repo && cd repo
	git fetch -q --depth 1 origin "+$head_ref:refs/heads/$head_ref" "+$base_ref:refs/remotes/origin/$base_ref"
	git checkout -q "$head_ref"
	msg "Merging $base_ref into $head_ref (strategy: $strategy)..."
	case $strategy in
	theirs)
		git merge "origin/$base_ref" -X theirs -m "Auto-merge: accept $base_ref" || {
			git checkout --theirs .
			git add -A
			git -c core.editor=true merge --continue
		}
		;;
	ours)
		git merge "origin/$base_ref" -X ours -m "Auto-merge: keep $head_ref" || {
			git checkout --ours .
			git add -A
			git -c core.editor=true merge --continue
		}
		;;
	auto)
		if git merge "origin/$base_ref" -m "Auto-merge: smart resolution"; then
			:
		else
			while IFS= read -r file; do
				case $file in
				package-lock.json | yarn.lock | Cargo.lock | go.sum | composer.lock | Gemfile.lock | poetry.lock) git checkout --theirs "$file" ;;
				.github/workflows/* | *.ya?ml | *.json | *.toml | *.ini | *.cfg) git checkout --theirs "$file" ;;
				*) git checkout --ours "$file" ;;
				esac
			done < <(git diff --name-only --diff-filter=U)
			git add -A
			git -c core.editor=true merge --continue
		fi
		;;
	*)
		die "Invalid strategy: $strategy"
		;;
	esac
	msg "Pushing changes..."
	git push -q origin "$head_ref"
	ok "Done. Conflicts resolved and pushed."
}
optimize_repo() {
	msg "Optimizing repository..."
	if [[ $DRY_RUN == true ]]; then
		msg "Would optimize: repack, gc, reflog, worktrees, maintenance"
	else
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
	fi
}
main() {
	case $MODE in
	clean) clean_repo ;;
	update) update_repo ;;
	both)
		update_repo
		clean_repo
		;;
	merge) auto_merge_pr "$@" ;;
	esac
	if [[ $MODE == "clean" || $MODE == "both" ]]; then
		optimize_repo
		ok "Deleted $DELETED_BRANCHES local and $DELETED_REMOTE_BRANCHES remote branches."
	fi
}
main "$@"
