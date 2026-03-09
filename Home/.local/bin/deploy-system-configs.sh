#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail
shopt -s nullglob globstar
export LC_ALL=C
IFS=$'\n\t'
has() { command -v -- "$1" &> /dev/null; }
info() { printf '==> %s\n' "$*"; }
warn() { printf '==> WARNING: %s\n' "$*"; }
die() {
  printf '==> ERROR: %s\n' "$*" >&2
  exit 1
}

# Get repository directory
get_repo_dir() {
  if yadm rev-parse --show-toplevel &> /dev/null; then
    yadm rev-parse --show-toplevel
  elif [[ -d "${HOME}/.local/share/yadm/repo.git" ]]; then
    echo "${HOME}"
  elif git rev-parse --show-toplevel &> /dev/null; then
    git rev-parse --show-toplevel
  else
    die "Cannot determine repository location"
  fi
}

usage() {
  cat << 'EOF'
deploy-system-configs - Deploy system configs using stow or tuckr

Usage: deploy-system-configs [OPTIONS] [PACKAGES...]

Options:
  -h, --help     Show this help
  -d, --dir DIR  Repository directory (auto-detected if omitted)
  -u, --unlink   Unlink/unstow packages instead of linking

Packages:
  etc            Deploy /etc configs
  usr            Deploy /usr configs
  (default: etc usr)

This script automatically uses stow if available, otherwise falls back to tuckr.

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
    -h | --help)
      usage
      exit 0
      ;;
    -d | --dir)
      if [[ -z ${2:-} ]]; then die "Option '$1' requires an argument."; fi
      REPO_DIR="$2"
      shift
      ;;
    -u | --unlink) UNLINK=true ;;
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

deploy_configs() {
  local repo_dir="$1"
  local unlink="$2"
  shift 2
  local packages=("$@")

  if has stow; then
    info "Using stow for deployment"
    local valid_pkgs=()
    for pkg in "${packages[@]}"; do
      local src="${repo_dir}/${pkg}"
      if [[ -d $src ]]; then
        valid_pkgs+=("$pkg")
      else
        warn "Directory not found: $src"
      fi
    done

    if ((${#valid_pkgs[@]} > 0)); then
      local pkgs_str
      printf -v pkgs_str '%s ' "${valid_pkgs[@]}"
      pkgs_str="${pkgs_str% }"

      if [[ $unlink == true ]]; then
        info "Unstowing ${pkgs_str}"
        (cd "$repo_dir" && stow -t / -d . -D "${valid_pkgs[@]}") || warn "Failed to unstow ${pkgs_str}"
      else
        info "Stowing ${pkgs_str} → / (stow)"
        (cd "$repo_dir" && stow -t / -d . "${valid_pkgs[@]}") || warn "Failed to stow ${pkgs_str}"
      fi
    fi
  elif has tuckr; then
    info "Using tuckr for deployment (stow not available)"
    local hooks_file="${repo_dir}/hooks.toml"
    local valid_pkgs=()
    for pkg in "${packages[@]}"; do
      local src="${repo_dir}/${pkg}"
      if [[ -d $src ]]; then
        valid_pkgs+=("$pkg")
      else
        warn "Directory not found: $src"
      fi
    done

    if ((${#valid_pkgs[@]} > 0)); then
      local pkgs_str
      printf -v pkgs_str '%s ' "${valid_pkgs[@]}"
      pkgs_str="${pkgs_str% }"

      if [[ $unlink == true ]]; then
        info "Unlinking ${pkgs_str}"
        tuckr unlink -d "$repo_dir" -t / "${valid_pkgs[@]}" || warn "Failed to unlink ${pkgs_str}"
      else
        info "Linking ${pkgs_str} → / (tuckr)"
        local cmd=(tuckr link -d "$repo_dir" -t / "${valid_pkgs[@]}")
        [[ -f $hooks_file ]] && cmd+=(-H "$hooks_file")
        "${cmd[@]}" || warn "Failed to link ${pkgs_str}"
      fi
    fi
  else
    die "Neither stow nor tuckr is installed. Install one of them:
  Arch: paru -S stow  OR  paru -S tuckr
  Debian: apt install stow"
  fi
}

# Deploy using tuckr or stow
deploy_configs "$REPO_DIR" "$UNLINK" "${PACKAGES[@]}"

info "Deployment complete"
