#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob; IFS=$'\n\t'

# --- Helpers ---
die() { printf '\e[31mERROR: %s\e[0m\n' "$*" >&2; exit 1; }
has() { command -v "$1" >/dev/null; }
need() { has "$1" || die "Missing dependency: $1"; }
log() { printf '\e[34m:: %s\e[0m\n' "$*"; }

# --- Dependencies ---
need gh; need git
JQ="jq"; has jaq && JQ="jaq"

# --- Subcommands ---
cmd_asset() {
  local repo="${1:-}" pattern="${2:-}" tag="" out=""
  [[ -z $repo || -z $pattern ]] && die "Usage: $0 asset OWNER/REPO PATTERN [-r TAG] [-o FILE]"
  shift 2
  while getopts "r:o:s" opt; do
    case $opt in r) tag="$OPTARG";; o) out="$OPTARG";; s) exec >/dev/null;; *) die "Invalid flag";; esac
  done
  local args=(release download "${tag:-opt}" --repo "$repo" --pattern "$pattern" --clobber)
  [[ -n $out ]] && args+=("--output" "$out")
  gh "${args[@]}" || die "Download failed"
}

cmd_install() {
  local repo="${1:-}" tag="" path="$HOME/.local/bin"
  [[ -z $repo ]] && die "Usage: $0 install OWNER/REPO [-t TAG] [-p PATH]"
  shift 1
  while getopts "t:p:" opt; do case $opt in t) tag="$OPTARG";; p) path="$OPTARG";; esac; done
  log "Fetching assets for $repo ${tag:+($tag)}..."
  local assets; mapfile -t assets < <(gh release view "${tag:-}" --repo "$repo" --json assets -q ".assets[].name")
  ((${#assets[@]} == 0)) && die "No assets found"
  echo "Select asset to install:"
  local selected; PS3="> "
  select selected in "${assets[@]}"; do
    [[ -n $selected ]] && break || echo "Invalid selection"
  done
  local tmp; tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  gh release download "${tag:-}" --repo "$repo" --pattern "$selected" --output "$tmp/$selected" --clobber
  log "Installing to $path..."
  case "$selected" in
    *.tar.gz|*.tgz) tar -xzf "$tmp/$selected" -C "$path" ;;
    *.zip) unzip -q -o "$tmp/$selected" -d "$path" ;;
    *) install -m 755 "$tmp/$selected" "$path/" ;;
  esac
  log "Installed $selected"
}
cmd_maint() {
  local mode="both" dry=0 yes=0
  [[ ${1:-} =~ ^(clean|update|both)$ ]] && { mode=$1; shift; }
  while getopts "dyv" opt; do case $opt in d) dry=1;; y) yes=1;; esac; done
  if [[ $mode =~ update|both ]]; then
    log "Updating remotes..."
    ((dry)) || { git fetch --all -p; git pull --autostash; }
  fi
  if [[ $mode =~ clean|both ]]; then
    log "Cleaning merged branches..."
    local -a branches; mapfile -t branches < <(git branch --merged | grep -vE '^\*|master|main|dev')
    ((${#branches[@]} == 0)) && { echo "No branches to clean"; return; }
    printf 'Branches to delete:\n%s\n' "${branches[*]}"
    ((dry)) && return
    ((yes)) || { read -rp "Confirm deletion? [y/N] " -n1 c; echo; [[ $c =~ [yY] ]] || return; }
    git branch -d "${branches[@]}"
  fi
}
cmd_combine() {
  (( $# < 1 )) && die "Usage: $0 combine-prs PR_NUMBER..."
  need awk
  log "Preparing branch..."
  git fetch origin
  local base branch="dependabot-$(date +%Y%m%d)"
  base=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
  git checkout -B "$branch" "origin/$base"
  for pr in "$@"; do
    log "Processing PR #$pr..."
    local sha; sha=$(git ls-remote origin "refs/pull/$pr/head" | awk '{print $1}')
    [[ -n $sha ]] || die "Could not resolve PR #$pr"
    # Cherry-pick range from base to PR head
    if ! git rev-list --reverse "origin/$base..$sha" | git cherry-pick --stdin --allow-empty; then
      die "Conflict processing PR #$pr. Resolve manually or skip."
    fi
  done
  log "Success! Created branch: $branch"
  echo "To push: git push origin $branch --set-upstream"
}
usage() {
  cat <<EOF
gh-tools - GitHub Utilities
Usage: ${0##*/} [asset|install|maint|combine-prs] [ARGS]

Commands:
  asset OWNER/REPO PATTERN [-r TAG] [-o FILE]   Download asset
  install OWNER/REPO [-t TAG] [-p PATH]         Interactive install
  maint [clean|update|both] [-d] [-y]           Repo maintenance
  combine-prs PR_ID [PR_ID...]                  Combine Dependabot PRs
EOF
  exit 1
}
# --- Main ---
[[ $# -eq 0 ]] && usage
CMD="$1"; shift
case "$CMD" in
  asset|install|maint) "cmd_$CMD" "$@" ;;
  combine-prs) cmd_combine "$@" ;;
  -h|--help) usage ;;
  *) die "Unknown command: $CMD" ;;
esac
