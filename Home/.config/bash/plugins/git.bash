#!/usr/bin/env bash
has git || return
gpush(){
  git maintenance run --auto --quiet; git add -A >/dev/null
  git commit -q -m "${1:-Update}" && LC_ALL=C git push --recurse-submodules=on-demand --prune
  git status
}
gctl(){
  [[ $# -eq 0 ]] && { printf "Usage: gctl <git-repo-url> [directory]\n" >&2; return 1; }
  local url="$1" dir="$2"
  [[ -n $2 ]] || { dir="$(basename "${url%%/}")"; dir="${dir%.git}"; }
  if [[ ! -d $dir ]]; then
    if has gix; then
      LC_ALL=C gix clone --depth 1 --no-tags "$url" "$dir" || return 1
    else
      LC_ALL=C git clone --depth 1 --no-tags --filter='blob:none' -c protocol.version=2 -c http.version=HTTP/2 "$url" "$dir" || return 1
    fi
  else
    [[ -d $dir ]] && {
      cd "$dir" || return
      LC_ALL=C git pull -c protocol.version=2 -c http.version=HTTP/2
      return 0
    }
  fi
  git status
  git branch -vv
}
# Export GitHub token for MCP if gh is available
# Lazy-load: only fetch token when needed, not on every shell startup
if has gh; then
  # Setup git to use gh for authentication (one-time config)
  gh auth setup-git &>/dev/null
  # Define lazy function to get token only when GITHUB_TOKEN is accessed
  get_github_token(){ export GITHUB_TOKEN="$(gh auth token &>/dev/null)"; }
fi
# Git dotfiles
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
# Display git repository file structure as a tree
alias git-tree="git ls-tree -r HEAD --name-only | tree --fromfile"
# GitHub PR metadata quick view
alias gh-pr-view="gh pr view --json number,title,state,url,author,createdAt,updatedAt,mergeable,reviewDecision"
# PR stats with detailed information including additions, deletions, and files
alias gh-pr-stats="gh pr view --json additions,deletions,changedFiles,files,title,state,url"
# PR stats with full detailed information
alias gh-pr-stats-full="gh pr view --json additions,deletions,changedFiles,files,title,author,state,createdAt,updatedAt,url,assignees,body,closed,closedAt,comments,commits,headRefName,headRefOid,isDraft,labels,mergeStateStatus,mergeable,mergedAt,mergedBy,reviewDecision,reviews"
gcommits(){
  if [[ -z $1 ]]; then
    git log --format="%C(auto)%h (%s, %ad)" -n 20 | cat
  else
    git log --format="%H" -n "$1" | cat
  fi
}
gh-cp(){
    usage(){ echo "Usage: gh cp <repo> <path> <dest>"; }
    [[ $# -lt 3 ]] && { usage >&2; return 1; }
    local repo="$1" path="$2" dest="$3" dest_file dest_dir
    dest_file="${dest%/}/$(basename "$path")"
    if [[ ! -d "$dest" ]] && [[ $dest != */ ]]; then
      dest_file="$dest"
    fi
    dest_dir="$(dirname "$dest_file")"
    [[ "$dest_dir" = "." ]] || mkdir -p "$dest_dir"
    gh api -H 'accept: application/vnd.github.v3.raw' "repos/$repo/contents/$path" > "$dest_file"
}
