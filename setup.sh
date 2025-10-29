#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t'
export LC_ALL=C LANG=C LANGUAGE=C
HOME="/home/${SUDO_USER:-$USER}"
cd -P -- "$(cd -P -- "${BASH_SOURCE[0]%/*}" && echo "$PWD")" || exit 1
# Arch/CachyOS System Setup
# 1. Installs AUR helper (paru) & essential packages.
# 2. Clones dotfiles repo with yadm.
# 3. Runs yadm bootstrap for user-level setup.
# 4. Uses stow to link system-wide configs (/etc, /usr).
#--- Helpers ---#
BLK=$'\e[30m' RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m'
BLU=$'\e[34m' MGN=$'\e[35m' CYN=$'\e[36m' WHT=$'\e[37m'
LBLU=$'\e[38;5;117m' PNK=$'\e[38;5;218m' BWHT=$'\e[97m'
DEF=$'\e[0m' BLD=$'\e[1m'
has(){ command -v "$1" &>/dev/null; }
xecho(){ printf '%b\n' "${BLD}${BLU}==>${BWHT} $*${DEF}"; }
warn(){ printf '%b\n' "${BLD}${YLW}==> WARNING:${BWHT} $*${DEF}"; }
die(){ printf '%b\n' "${BLD}${RED}==> ERROR:${BWHT} $8${DEF}" >&2; exit 1; }

#--- Pre-flight Checks ---#
[[ $EUID -eq 0 ]] && die "Run as a regular user, not root."
! has sudo && die "Sudo is required. Please install it first."
! ping -c 1 archlinux.org &>/dev/null && die "No internet connection."

#--- Configuration ---#
readonly DOTFILES_REPO="https://github.com/Ven0m0/dotfiles.git"
readonly DOTFILES_DIR="${HOME}/.local/share/yadm/repo.git"
readonly STOW_DIR="${HOME}/.local/share/yadm/repo.git"
readonly PARU_OPTS="--needed --noconfirm --skipreview --sudoloop --batchinstall --combinedupgrade --nocheck"

#--- Main Logic ---#
main(){
  install_packages
  setup_dotfiles
  stow_system_configs
  final_steps
}

#--- Functions ---#
install_packages(){
  xecho "Installing packages from official and AUR repositories..."
  local pkgs=(
    git gitoxide aria2 curl zsh fd sd ripgrep bat jq
    zoxide starship fzf stow yadm
  )
  if has paru; then
    paru -Syuq $PARU_OPTS "${pkgs[@]}"
  else
    sudo pacman -Syuq --noconfirm --needed "${pkgs[@]}"
  fi
}

setup_dotfiles(){
  has yadm || die "yadm command not found. Package installation failed."
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    xecho "Cloning dotfiles with yadm..."
    yadm clone --bootstrap "$DOTFILES_REPO"
  else
    xecho "Dotfiles repo already exists. Pulling latest changes..."
    yadm pull
    xecho "Re-running bootstrap..."
    yadm bootstrap
  fi
}
stow_system_configs(){
  xecho "Stowing system-wide configs for /etc and /usr..."
  if ! has stow; then
    die "stow command not found. Cannot link system configs."
  fi
  if [[ ! -d "$STOW_DIR" ]]; then
    die "Dotfiles directory not found at $STOW_DIR."
  fi
  # Stow packages are the top-level dirs in the repo to be stowed
  local stow_pkgs=(etc usr)
  for pkg in "${stow_pkgs[@]}"; do
    if [[ -d "${STOW_DIR}/${pkg}" ]]; then
      xecho "Stowing '${pkg}' to target '/'..."
      # -v: verbose, -R: restow, -t: target
      sudo stow -vR -d "$STOW_DIR" -t / "$pkg"
    else
      warn "Stow package '${pkg}' not found in repo, skipping."
    fi
  done
}

final_steps(){
  xecho "Setup complete. Some changes may require a reboot or new login session."
  if [[ "$SHELL" != "/bin/zsh" ]]; then
    warn "Your shell has been set to Zsh. Please log out and back in to use it."
  fi
  xecho "Run 'yadm status' to check the state of your dotfiles."
}

#--- Execution ---#
main "$@"
