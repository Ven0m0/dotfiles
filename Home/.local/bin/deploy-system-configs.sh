#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar
export LC_ALL=C; IFS=$'\n\t'
has(){ command -v -- "$1" &>/dev/null; }
info(){ printf '==> %s\n' "$*"; }
warn(){ printf '==> WARNING: %s\n' "$*"; }
die(){ printf '==> ERROR: %s\n' "$*" >&2; exit 1; }

# Get repository directory
get_repo_dir(){
  if yadm rev-parse --show-toplevel &>/dev/null; then
    yadm rev-parse --show-toplevel
  elif [[ -d "${HOME}/.local/share/yadm/repo.git" ]]; then
    echo "${HOME}/.local/share/yadm/repo.git"
  elif git rev-parse --show-toplevel &>/dev/null; then
    git rev-parse --show-toplevel
  else
    die "Cannot determine repository location"
  fi
}

usage(){
  cat <<'EOF'
deploy-system-configs - Deploy system configs using tuckr or stow

Usage: deploy-system-configs [OPTIONS] [PACKAGES...]

Options:
  -h, --help     Show this help
  -d, --dir DIR  Repository directory (auto-detected if omitted)
  -u, --unlink   Unlink/unstow packages instead of linking

Packages:
  etc            Deploy /etc configs
  usr            Deploy /usr configs
  (default: etc usr)

This script automatically uses tuckr if available, otherwise falls back to stow.

Examples:
  sudo deploy-system-configs           # Deploy both etc and usr
  sudo deploy-system-configs etc       # Deploy only etc
  sudo deploy-system-configs --unlink  # Unlink all packages
EOF
}

REPO_DIR=""
UNLINK=false
PACKAGES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -d|--dir) shift; REPO_DIR="${1:-}" ;;
    -u|--unlink) UNLINK=true ;;
    -*) die "Unknown option: $1" ;;
    *) PACKAGES+=("$1") ;;
  esac
  shift
done

# Auto-detect repo dir if not provided
[[ -z $REPO_DIR ]] && REPO_DIR="$(get_repo_dir)"
[[ -d $REPO_DIR ]] || die "Repository not found: $REPO_DIR"

# Default to etc and usr if no packages specified
((${#PACKAGES[@]} == 0)) && PACKAGES=(etc usr)

# Check if running as root
[[ $EUID -eq 0 ]] || die "This script must be run as root (use sudo)"

# Deploy using tuckr or stow
if has tuckr; then
  info "Using tuckr for deployment"
  local hooks_file="${REPO_DIR}/hooks.toml"
  for pkg in "${PACKAGES[@]}"; do
    local src="${REPO_DIR}/${pkg}"
    [[ -d $src ]] || { warn "Directory not found: $src"; continue; }

    if [[ $UNLINK == true ]]; then
      info "Unlinking ${pkg}/"
      tuckr unlink -d "$REPO_DIR" -t / "$pkg" || warn "Failed to unlink $pkg"
    else
      info "Linking ${pkg}/ → / (tuckr)"
      local cmd=(tuckr link -d "$REPO_DIR" -t / "$pkg")
      [[ -f $hooks_file ]] && cmd+=(-H "$hooks_file")
      "${cmd[@]}" || warn "Failed to link $pkg"
    fi
  done
elif has stow; then
  info "Using stow for deployment (tuckr not available)"
  for pkg in "${PACKAGES[@]}"; do
    local src="${REPO_DIR}/${pkg}"
    [[ -d $src ]] || { warn "Directory not found: $src"; continue; }

    if [[ $UNLINK == true ]]; then
      info "Unstowing ${pkg}/"
      (cd "$REPO_DIR" && stow -t / -d . -D "$pkg") || warn "Failed to unstow $pkg"
    else
      info "Stowing ${pkg}/ → / (stow)"
      (cd "$REPO_DIR" && stow -t / -d . "$pkg") || warn "Failed to stow $pkg"
    fi
  done
else
  die "Neither tuckr nor stow is installed. Install one of them:
  Arch: paru -S tuckr  OR  paru -S stow
  Debian: apt install stow"
fi

info "Deployment complete"
