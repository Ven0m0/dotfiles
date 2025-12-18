#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar
export LC_ALL=C; IFS=$'\n\t'
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"

pr_sha(){
  local pr_number="$1" sha
  read -r sha _ < <(git ls-remote origin "refs/pull/${pr_number}/head")
  [[ -n $sha ]] || { printf 'Unable to resolve PR #%s\n' "$pr_number" >&2; return 1; }
  printf '%s\n' "$sha"
}

pr_numbers_to_md(){
  for pr_number in "$@"; do
    printf '* #%s\n' "$pr_number"
  done
}

default_branch(){
  local head
  head=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null) \
    || head=$(git remote show origin | awk '/HEAD branch/ {print $NF; exit}')
  printf '%s\n' "${head#origin/}"
}

current_date=$(date +%Y-%m-%d)
current_date_tight=$(date +%Y%m%d)
branch_name="dependabot-${current_date_tight}"
default_branch=$(default_branch)

git fetch
git checkout -b "$branch_name" "origin/$default_branch"

for pr_number in "$@"; do
  head_sha=$(pr_sha "$pr_number")
  git rev-list --reverse "origin/${default_branch}..${head_sha}"|git cherry-pick --stdin --allow-empty
done

git push origin "$branch_name" --set-upstream

pr_body="
Cherry picked combination of:
$(pr_numbers_to_md "$@")
"

gh pr create --title "Dependabot updates from ${current_date}" --body "$pr_body"
