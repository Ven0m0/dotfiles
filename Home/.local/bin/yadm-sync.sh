#!/usr/bin/env bash
# yadm-sync - Bidirectional sync helper for subdirectory-based dotfiles
# Syncs changes between ~/ and ${REPO}/Home/

set -euo pipefail
export LC_ALL=C LANG=C

# Colors
readonly BLD=$'\e[1m' RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m'
readonly BLU=$'\e[34m' DEF=$'\e[0m'

# Helper functions
has(){ command -v "$1" &>/dev/null; }
info(){ printf '%b==>\e[0m %b%s%b\n' "${BLD}${BLU}" "$BLD" "$*" "$DEF"; }
success(){ printf '%b==>\e[0m %b%s%b\n' "${BLD}${GRN}" "$BLD" "$*" "$DEF"; }
warn(){ printf '%b==> WARNING:\e[0m %b%s%b\n' "${BLD}${YLW}" "$BLD" "$*" "$DEF"; }
error(){ printf '%b==> ERROR:\e[0m %b%s%b\n' "${BLD}${RED}" "$BLD" "$*" "$DEF" >&2; }
die(){ error "$*"; exit 1; }

# Determine repository directory
get_repo_dir(){
  if yadm rev-parse --show-toplevel &>/dev/null; then
    yadm rev-parse --show-toplevel
  elif [[ -d "${HOME}/.local/share/yadm/repo.git" ]]; then
    echo "${HOME}/.local/share/yadm/repo.git"
  else
    die "Cannot determine yadm repository location"
  fi
}

# Show usage
usage(){
  cat <<EOF
${BLD}yadm-sync${DEF} - Sync dotfiles between ~/ and repository

${BLD}Usage:${DEF}
  yadm-sync <command> [options]

${BLD}Commands:${DEF}
  ${BLD}pull${DEF}     Sync FROM repository TO home directory (repo → ~/)
  ${BLD}push${DEF}     Sync FROM home directory TO repository (~/ → repo)
  ${BLD}status${DEF}   Show differences between ~/ and repo
  ${BLD}diff${DEF}     Show detailed diff between ~/ and repo

${BLD}Options:${DEF}
  -h, --help       Show this help message
  -n, --dry-run    Show what would be synced without making changes
  -v, --verbose    Verbose output

${BLD}Examples:${DEF}
  yadm-sync pull              # Deploy dotfiles from repo to ~/
  yadm-sync push              # Update repo with changes from ~/
  yadm-sync push --dry-run    # Preview changes without syncing
  yadm-sync status            # Check what files differ
  yadm-sync diff              # View detailed differences

${BLD}Workflow:${DEF}
  1. Make changes to your dotfiles in ~/
  2. Run 'yadm-sync push' to update the repository
  3. Commit changes: cd \$(yadm rev-parse --show-toplevel) && git add -A && git commit
  4. Push to remote: yadm push

${BLD}Note:${DEF} This script manages the Home/ subdirectory. System configs (etc/, usr/)
      are managed separately with tuckr.
EOF
}

# Sync from repo to home (deploy)
sync_pull(){
  local repo_dir home_dir dry_run="${1:-0}"

  repo_dir="$(get_repo_dir)"
  home_dir="${repo_dir}/Home"

  [[ -d "$home_dir" ]] || die "Home/ directory not found: $home_dir"

  has rsync || die "rsync is required for syncing. Install it first."

  info "Syncing FROM repository TO home directory..."
  info "Source: $home_dir/"
  info "Target: $HOME/"

  local rsync_opts=(-av --exclude='.git' --exclude='.gitignore')
  [[ "$dry_run" == "1" ]] && rsync_opts+=(--dry-run)

  rsync "${rsync_opts[@]}" "${home_dir}/" "${HOME}/"

  if [[ "$dry_run" == "1" ]]; then
    warn "DRY RUN - No files were actually modified"
  else
    success "Dotfiles deployed to home directory"
  fi
}

# Sync from home to repo (update repo)
sync_push(){
  local repo_dir home_dir dry_run="${1:-0}"

  repo_dir="$(get_repo_dir)"
  home_dir="${repo_dir}/Home"

  [[ -d "$home_dir" ]] || die "Home/ directory not found: $home_dir"

  has rsync || die "rsync is required for syncing. Install it first."

  info "Syncing FROM home directory TO repository..."
  info "Source: $HOME/"
  info "Target: $home_dir/"

  # Exclude patterns to avoid syncing everything from ~/
  local exclude_file
  exclude_file="$(mktemp)"

  cat > "$exclude_file" <<'EXCLUDES'
.cache
.local/share
.local/state
.mozilla
.thunderbird
Downloads
Documents
Pictures
Music
Videos
Desktop
Public
Templates
.Trash
.steam
.cargo/registry
.cargo/git
.npm
.node_modules
.rustup
.vscode-oss
.vscode
.var
.pki
*.log
*.tmp
EXCLUDES

  local rsync_opts=(
    -av
    --delete
    --exclude-from="$exclude_file"
    --exclude='.git'
    --exclude='.gitignore'
    --filter='dir-merge,- .gitignore'
    --files-from=-
  )
  [[ "$dry_run" == "1" ]] && rsync_opts+=(--dry-run)

  # Only sync files that exist in Home/ directory structure
  # This prevents syncing random files from ~/ to repo
  if [[ "$dry_run" == "1" ]]; then
    warn "DRY RUN - Showing what would be synced..."
  fi

  # Build list of files to sync (only those that exist in both locations)
  local -a files_to_sync=()
  while IFS= read -r -d '' file; do
    local rel_path="${file#${home_dir}/}"
    local source_file="${HOME}/${rel_path}"
    [[ -e "$source_file" ]] && files_to_sync+=("$rel_path")
  done < <(find "$home_dir" -type f -print0)

  # Sync all files at once using --files-from
  if (( ${#files_to_sync[@]} > 0 )); then
    printf '%s\n' "${files_to_sync[@]}" | rsync "${rsync_opts[@]}" "${HOME}/" "${home_dir}/"
  fi

  rm -f "$exclude_file"

  if [[ "$dry_run" == "1" ]]; then
    warn "DRY RUN - No files were actually modified"
  else
    success "Repository updated with changes from home directory"
    info "Next steps:"
    info "  cd $repo_dir"
    info "  git add -A"
    info "  git commit -m 'Update dotfiles'"
    info "  git push"
  fi
}

# Show sync status
sync_status(){
  local repo_dir home_dir

  repo_dir="$(get_repo_dir)"
  home_dir="${repo_dir}/Home"

  [[ -d "$home_dir" ]] || die "Home/ directory not found: $home_dir"

  has rsync || die "rsync is required. Install it first."

  info "Checking differences between repository and home directory..."

  rsync -avn --delete --exclude='.git' "${home_dir}/" "${HOME}/" | grep -v '^sending\|^sent\|^total\|^$' || {
    success "No differences found - repository and home are in sync!"
    return 0
  }
}

# Show detailed diff
sync_diff(){
  local repo_dir home_dir

  repo_dir="$(get_repo_dir)"
  home_dir="${repo_dir}/Home"

  [[ -d "$home_dir" ]] || die "Home/ directory not found: $home_dir"

  has diff || die "diff command not found"

  info "Showing detailed differences..."

  # Find common files and compare
  while IFS= read -r -d '' file; do
    local rel_path="${file#${home_dir}/}"
    local source_file="${HOME}/${rel_path}"

    if [[ -f "$source_file" && -f "$file" ]]; then
      if ! diff -q "$source_file" "$file" &>/dev/null; then
        echo ""
        echo "${BLD}${BLU}Differences in:${DEF} ${rel_path}"
        echo "${BLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${DEF}"
        diff -u --color=always "$file" "$source_file" 2>/dev/null || :
      fi
    fi
  done < <(find "$home_dir" -type f -print0 2>/dev/null)
}

# Main
main(){
  local command="${1:-}"
  local dry_run=0

  # Parse options
  shift || :
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) usage; exit 0 ;;
      -n|--dry-run) dry_run=1; shift ;;
      -v|--verbose) set -x; shift ;;
      *) error "Unknown option: $1"; usage; exit 1 ;;
    esac
  done

  case "$command" in
    pull)   sync_pull "$dry_run" ;;
    push)   sync_push "$dry_run" ;;
    status) sync_status ;;
    diff)   sync_diff ;;
    -h|--help|help) usage; exit 0 ;;
    "") error "No command specified"; usage; exit 1 ;;
    *) error "Unknown command: $command"; usage; exit 1 ;;
  esac
}

main "$@"
