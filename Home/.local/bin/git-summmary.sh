#!/usr/bin/env bash

set -euo pipefail # Exit on error, undefined var, pipe failure

# Function to print usage
usage() {
    echo "Usage: $0 [starting_directory]"
    exit 1
}

# Function to summarize a single repo using git summary (from git-extras)
summarize_repo() {
    local repo_path="$1"
    echo "Git repository found: $repo_path"
    # Use git summary with --line to get a one-line summary
    # This is the most efficient way to get aggregated stats without complex parsing here
    git -C "$repo_path" summary --line
}

# Determine the starting directory
START_DIR="${1:-.}"

if [[ ! -d "$START_DIR" ]]; then
    echo "Error: Directory '$START_DIR' does not exist." >&2
    exit 1
fi

# Find all .git directories (which indicates a git repo root)
# Use -mindepth 1 to avoid matching the start dir itself if it's a .git dir
# Use -maxdepth 2 to find repos like /path/to/start/repo/.git
# Use -type d to ensure we match directories only
# Use -print0 and read -d '' for robust handling of filenames with spaces/special chars
export LC_ALL=C # Ensure find sorts consistently
find "$START_DIR" -mindepth 2 -maxdepth 3 -type d -name ".git" -print0 | \
while IFS= read -r -d '' git_dir; do
    repo_root=$(dirname "$git_dir")
    summarize_repo "$repo_root"
done
