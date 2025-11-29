#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
IFS=$'\n\t'
export LC_ALL=C LANG=C

usage() {
	printf 'Usage: %s <PR_URL|REPO PR_NUM> [strategy]\n' "${0##*/}"
	printf 'Strategies: theirs (default), ours, auto\n'
	printf '  theirs: accept base branch changes\n'
	printf '  ours:   keep PR branch changes\n'
	printf '  auto:   theirs for deps/lock files, ours for code\n'
	exit 1
}

(($# >= 1)) || usage
strategy=${2:-theirs}
if [[ $1 =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
	owner=${BASH_REMATCH[1]}
	repo=${BASH_REMATCH[2]}
	pr=${BASH_REMATCH[3]}
elif (($# >= 2)) && [[ $1 =~ / ]] && [[ $2 =~ ^[0-9]+$ ]]; then
	IFS=/ read -r owner repo <<<"$1"
	pr=$2
	strategy=${3:-theirs}
else
	usage
fi
work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

cd "$work_dir"
printf 'Fetching PR %s/%s#%s...\n' "$owner" "$repo" "$pr"
command -v gh &>/dev/null || {
	printf 'Error: gh CLI not installed\n'
	exit 1
}

pr_info=$(gh pr view "$pr" -R "$owner/$repo" --json headRefName,baseRefName,headRepository,isCrossRepository)
head_ref=$(jq -r .headRefName <<<"$pr_info")
base_ref=$(jq -r .baseRefName <<<"$pr_info")
is_cross=$(jq -r .isCrossRepository <<<"$pr_info")

if [[ $is_cross == true ]]; then
	head_repo=$(jq -r .headRepository.nameWithOwner <<<"$pr_info")
	[[ -n $head_repo && $head_repo != null ]] || {
		printf 'Error: Cannot access fork repo\n' >&2
		exit 1
	}
else
	head_repo="$owner/$repo"
fi

git clone -q --depth 1 "https://github.com/$head_repo.git" repo && cd repo
git fetch -q --depth 1 origin "+$head_ref:refs/heads/$head_ref" "+$base_ref:refs/remotes/origin/$base_ref"
git checkout -q "$head_ref"
printf 'Merging %s into %s (strategy: %s)...\n' "$base_ref" "$head_ref" "$strategy"

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
		: # no conflicts
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
	printf 'Invalid strategy: %s\n' "$strategy" >&2
	exit 1
	;;
esac

printf 'Pushing changes...\n'
git push -q origin "$head_ref"
printf 'Done. Conflicts resolved and pushed.\n'
