#!/usr/bin/env bash
shopt -s nullglob globstar; set -u
# Source common shell utilities
source "${HOME}/.local/lib/shell-common.sh" || {
  echo "Error: Failed to load shell-common.sh" >&2
  exit 1
}
set_c_locale
##==================================================================================================
##	Requirements
require git
##==================================================================================================
##	Helper functions
getGitDirs() {
  find "$1" -type d -name .git -not -path "*.local*" -printf '%h\n'
}

housekeepGitDir() {
  local dir=$1
  if [[ -d "${dir}" && -d "${dir}/.git" ]]; then
    echo -e "\e[1mGit housekeeping: ${dir}\e[0m"
   ## Fetch from remote, twice in case something goes wrong
    git -C "$dir" fetch || git -C "$dir" fetch

    ## Delete local (non-important) branches that have been merged.
    git -C "$dir" branch --merged \
            | grep -E -v "(^\*|HEAD|master|main|dev|release)" \
            | xargs -r git branch -d
    ## Prune origin: stop tracking branches that do not exist in origin
    git -C "$dir" remote prune origin >/dev/null
    ## Optimize, if needed
		git -C "$dir" repack -ad --depth=250 --window=250 --cruft --threads="$(nproc)" >/dev/null
  	git reflog expire --expire=now --all >/dev/null
    git -C "$dir" gc --auto --aggressive --prune=now >/dev/null
    git clean -fdXq >/dev/null
  fi
}

##==================================================================================================
##	Main script
##==================================================================================================
while IFS= read -r dir; do
  housekeepGitDir "$dir"
done < <(getGitDirs "$1"); wait
