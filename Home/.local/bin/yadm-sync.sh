#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar extglob
export LC_ALL=C; IFS=$'\n\t'
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
has(){ command -v -- "$1" &>/dev/null; }
die(){ printf '%b[ERROR]%b %s\n' '\e[1;31m' '\e[0m' "$*" >&2; exit "${2:-1}"; }
warn(){ printf '%b[WARN]%b %s\n' '\e[1;33m' '\e[0m' "$*" >&2; }
log(){ printf '%b[INFO]%b %s\n' '\e[1;34m' '\e[0m' "$*"; }
ok(){ printf '%b[OK]%b %s\n' '\e[1;32m' '\e[0m' "$*"; }
readonly BLD=$'\e[1m' BLU=$'\e[34m' DEF=$'\e[0m'
get_repo_dir(){
  if yadm rev-parse --show-toplevel &>/dev/null; then
    yadm rev-parse --show-toplevel
    return
  fi
  if [[ -d "${HOME}/.local/share/yadm/repo.git" ]]; then
    echo "${HOME}/.local/share/yadm/repo.git"
    return
  fi
  die "Cannot determine yadm repository location"
}
usage(){
  cat <<EOF
${BLD}yadm-sync${DEF} - Sync dotfiles between ~/ and repository
${BLD}Usage:${DEF} yadm-sync <cmd> [opts]
${BLD}Commands:${DEF} pull(repo→~/) push(~/→repo) status diff
${BLD}Options:${DEF} -h,--help -n,--dry-run -v,--verbose
${BLD}Examples:${DEF}
  yadm-sync pull              # Deploy dotfiles
  yadm-sync push --dry-run    # Preview changes
${BLD}Note:${DEF} Manages Home/ subdirectory. System configs (etc/, usr/) use tuckr.
EOF
}
sync_pull(){
  local repo_dir home_dir dry_run="${1:-0}"
  repo_dir="$(get_repo_dir)"; home_dir="${repo_dir}/Home"
  [[ -d $home_dir ]] || die "Home/ directory not found: $home_dir"
  if ! command -v rsync &>/dev/null; then
    die "rsync required"
  fi
  log "Syncing FROM repository TO home directory..."
  log "Source: $home_dir/"
  log "Target: $HOME/"
  local -a rsync_opts=(-av --exclude='.git' --exclude='.gitignore')
  [[ $dry_run == "1" ]] && rsync_opts+=(--dry-run)
  rsync "${rsync_opts[@]}" "${home_dir}/" "${HOME}/"
  if [[ $dry_run == "1" ]]; then
    warn "DRY RUN - No files modified"
  else
    ok "Dotfiles deployed to home directory"
  fi
}
sync_push(){
  local repo_dir home_dir dry_run="${1:-0}"
  repo_dir="$(get_repo_dir)"; home_dir="${repo_dir}/Home"
  [[ -d $home_dir ]] || die "Home/ directory not found: $home_dir"
  if ! command -v rsync &>/dev/null; then
    die "rsync required"
  fi
  log "Syncing FROM home directory TO repository..."
  log "Source: $HOME/"
  log "Target: $home_dir/"
  local exclude_file
  exclude_file=$(mktemp)
  cat >"$exclude_file" <<'EXCLUDES'
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
  local -a rsync_opts=(-av --delete --exclude-from="$exclude_file" --exclude='.git' --exclude='.gitignore' --filter='dir-merge,- .gitignore' --files-from=-)
  [[ $dry_run == "1" ]] && rsync_opts+=(--dry-run)
  [[ $dry_run == "1" ]] && warn "DRY RUN - Showing what would be synced..."
  local -a files_to_sync=()
  while IFS= read -r -d '' file; do
    local rel_path source_file
    rel_path="${file#"${home_dir}/"}"
    source_file="${HOME}/${rel_path}"
    [[ -e $source_file ]] && files_to_sync+=("$rel_path")
  done < <(find "$home_dir" -type f -print0)
  ((${#files_to_sync[@]}>0)) && printf '%s\n' "${files_to_sync[@]}" | rsync "${rsync_opts[@]}" "${HOME}/" "${home_dir}/"
  rm -f "$exclude_file"
  if [[ $dry_run == "1" ]]; then
    warn "DRY RUN - No files modified"
  else
    ok "Repository updated"
    log "Next steps:"
    log "  cd $repo_dir"
    log "  git add -A"
    log "  git commit -m 'Update dotfiles'"
    log "  git push"
  fi
}
sync_status(){
  local repo_dir home_dir
  repo_dir="$(get_repo_dir)"; home_dir="${repo_dir}/Home"
  [[ -d $home_dir ]] || die "Home/ directory not found: $home_dir"
  if ! command -v rsync &>/dev/null; then
    die "rsync required"
  fi
  log "Checking differences..."
  if ! rsync -avn --delete --exclude='.git' "${home_dir}/" "${HOME}/" | grep -v '^sending\|^sent\|^total\|^$'; then
    ok "No differences - in sync!"
  fi
}
sync_diff(){
  local repo_dir home_dir
  repo_dir="$(get_repo_dir)"; home_dir="${repo_dir}/Home"
  [[ -d $home_dir ]] || die "Home/ directory not found: $home_dir"
  if ! command -v diff &>/dev/null; then
    die "diff command not found"
  fi
  log "Showing detailed differences..."
  while IFS= read -r -d '' file; do
    local rel_path="${file#"${home_dir}"/}"
    local source_file="${HOME}/${rel_path}"
    if [[ -f $source_file && -f $file ]]; then
      # Quick size/time check before spawning diff
      if [[ ! $source_file -ef $file ]] && { [[ $(stat -c%s "$source_file") -ne $(stat -c%s "$file") ]] || ! diff -q "$source_file" "$file" &>/dev/null; }; then
        printf '\n%b%bDifferences in:%b %s\n%b━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%b\n' "$BLD" "$BLU" "$DEF" "$rel_path" "$BLD" "$DEF"
        diff -u --color=always "$file" "$source_file" 2>/dev/null || :
      fi
    fi
  done < <(find "$home_dir" -type f -print0 2>/dev/null)
}
main(){
  local command="${1:-}" dry_run=0
  shift || :
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) usage; exit 0 ;;
      -n|--dry-run) dry_run=1; shift ;;
      -v|--verbose) set -x; shift ;;
      *) die "Unknown option: $1" ;;
    esac
  done
  case "$command" in
    pull) sync_pull "$dry_run" ;;
    push) sync_push "$dry_run" ;;
    status) sync_status ;;
    diff) sync_diff ;;
    -h|--help|help) usage; exit 0 ;;
    "") die "No command specified" ;;
    *) die "Unknown command: $command" ;;
  esac
}
main "$@"
