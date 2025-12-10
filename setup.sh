#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar; IFS=$'\n\t'
export LC_ALL=C LANG=C LANGUAGE=C
cd -- "$(cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd -P)" || exit 1
#--- Options ---#
DRY_RUN=false; VERBOSE=true
#--- Helpers ---#
BLK=$'\e[30m' RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' BLU=$'\e[34m'
MGN=$'\e[35m' CYN=$'\e[36m' WHT=$'\e[37m' BLD=$'\e[1m' BWHT=$'\e[97m' DEF=$'\e[0m'
has(){ command -v -- "$1" &>/dev/null; }
warn(){ printf '%b\n' "${BLD}${YLW}==> WARNING:${BWHT} $1${DEF}"; }
die(){ printf '%b[ERROR]%b %s\n' '\e[1;31m' '\e[0m' "$*" >&2; exit "${2:-1}"; }
info(){ printf '%b\n' "${BLD}${BLU}==>${BWHT} $1${DEF}"; }
success(){ printf '%b\n' "${BLD}${GRN}==>${BWHT} $1${DEF}"; }
#--- Argument Parsing ---#
parse_args(){
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run|-n) DRY_RUN=true; info "Dry-run mode enabled"; shift ;;
      --verbose|-v) VERBOSE=true; shift ;;
      --help|-h) show_help; exit 0 ;;
      *) warn "Unknown option: $1"; show_help; exit 1 ;;
    esac
  done
}
show_help(){
  cat <<EOF
${BLD}Dotfiles Setup Script${DEF}
Usage: $(basename "$0") [OPTIONS]
Options:
  -n, --dry-run    Show what would be done without making changes
  -h, --help       Show this help message
EOF
}
#--- Pre-flight Checks ---#
parse_args "$@"
[[ $EUID -eq 0 ]] && die "Run as a regular user, not root."
[[ $DRY_RUN == false ]] && { sudo -v || die "sudo access required"; }
ping -c 1 archlinux.org &>/dev/null || die "No internet connection"
#--- Configuration ---#
readonly DOTFILES_REPO="https://github.com/Ven0m0/dotfiles.git"
readonly DOTFILES_DIR="${HOME}/.local/share/yadm/repo.git"
readonly TUCKR_DIR="$DOTFILES_DIR"
#--- Main Logic ---#
main(){
  install_packages
  setup_dotfiles; deploy_dotfiles
  tuckr_system_configs
  final_steps
}
#--- Functions ---#
install_packages(){
  info "Installing packages..."
  local paru_opts=(--needed --noconfirm --skipreview --sudoloop --batchinstall --combinedupgrade)
  local pkgs=(git gitoxide aria2 curl zsh fd sd ripgrep bat jq
    zoxide starship fzf yadm tuckr)
  has paru || die "paru not found."
  if [[ $DRY_RUN == true ]]; then
    info "[DRY-RUN] Would install: ${pkgs[*]}"
  else
    # shellcheck disable=SC2086
    paru -Syuq "${paru_opts[@]}" "${pkgs[@]}" || die "Failed to install packages"
  fi
}
setup_dotfiles(){
  has yadm || die "yadm not found."
  if [[ ! -d $DOTFILES_DIR ]]; then
    info "Cloning dotfiles..."
    yadm clone --bootstrap "$DOTFILES_REPO" || die "Failed to clone dotfiles"
  else
    info "Pulling changes..."
    yadm pull || warn "Failed to pull changes"
    yadm bootstrap || warn "Bootstrap failed"
  fi
}
deploy_dotfiles(){
  info "Deploying Home/ configs..."
  local repo_dir
  if has yadm && yadm rev-parse --git-dir &>/dev/null; then
    repo_dir="$(yadm rev-parse --show-toplevel)"
  elif [[ -d $DOTFILES_DIR ]]; then
    repo_dir="$DOTFILES_DIR"
  else
    warn "Cannot determine repo location."; return 0
  fi
  local home_dir="${repo_dir}/Home"
  [[ ! -d $home_dir ]] && { warn "Home dir not found: $home_dir"; return 0; }
  if has rsync; then
    rsync -av --exclude='.git' "${home_dir}/" "${HOME}/"
  else
    cp -r "${home_dir}/." "${HOME}/"
  fi
}
tuckr_system_configs(){
  info "Linking system configs..."
  has tuckr || die "tuckr not found."
  [[ -d $TUCKR_DIR ]] || die "Repo not found at $TUCKR_DIR."
  local tuckr_pkgs=(etc usr) hooks_file="${TUCKR_DIR}/hooks.toml"
  for pkg in "${tuckr_pkgs[@]}"; do
    if [[ -d "${TUCKR_DIR}/${pkg}" ]]; then
      local cmd=(sudo tuckr link -d "$TUCKR_DIR" -t / "$pkg")
      [[ -f $hooks_file ]] && cmd+=(-H "$hooks_file")
      "${cmd[@]}" || warn "Failed to link ${pkg}"
    fi
  done
}
final_steps(){ success "Setup complete."; info "Run 'yadm status' to check state."; }
main "$@"

# vim: ts=2 sw=2 et:
