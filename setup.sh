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
# 4. Uses tuckr to link system-wide configs (/etc, /usr).
#--- Helpers ---#
BLK=$'\e[30m' RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m'
BLU=$'\e[34m' MGN=$'\e[35m' CYN=$'\e[36m' WHT=$'\e[37m'
LBLU=$'\e[38;5;117m' PNK=$'\e[38;5;218m' BWHT=$'\e[97m'
DEF=$'\e[0m' BLD=$'\e[1m'
has(){ command -v "$1" &>/dev/null; }
xecho(){ printf '%b\n' "${BLD}${BLU}==>${BWHT} $1${DEF}"; }
warn(){ printf '%b\n' "${BLD}${YLW}==> WARNING:${BWHT} $1${DEF}"; }
die(){ printf '%b\n' "${BLD}${RED}==> ERROR:${BWHT} $1${DEF}" >&2; exit 1; }
#--- Pre-flight Checks ---#
[[ $EUID -eq 0 ]] && die "Run as a regular user, not root."
sudo -v
! ping -c 1 archlinux.org &>/dev/null && die "No internet connection."
#--- Configuration ---#
readonly DOTFILES_REPO="https://github.com/Ven0m0/dotfiles.git"
readonly DOTFILES_DIR="${HOME}/.local/share/yadm/repo.git" # yadm's default git dir
readonly TUCKR_DIR="${DOTFILES_DIR}" # Source for tuckr packages
readonly PARU_OPTS="--needed --noconfirm --skipreview --sudoloop --batchinstall --combinedupgrade"
#--- Main Logic ---#
main(){
  setup_aur
  install_packages
  setup_dotfiles
  tuckr_system_configs
  final_steps
}
#--- Functions ---#
setup_aur(){
  if ! has paru; then
    xecho "Installing AUR helper (paru)..."
    sudo pacman -S --needed --noconfirm base-devel git
    local tmpdir; tmpdir=$(mktemp -d)
    git clone --depth=1 https://aur.archlinux.org/paru-bin.git "$tmpdir"
    (cd "$tmpdir" && makepkg -si --noconfirm) || die "paru installation failed."
    rm -rf "$tmpdir"
  fi
  xecho "AUR helper (paru) is ready."
}
install_packages(){
  xecho "Installing packages from official and AUR repositories..."
  local pkgs=(
    git gitoxide aria2 curl zsh fd sd ripgrep bat jq
    zoxide starship fzf yadm tuckr
  )
  if has paru; then
    # Word splitting is intentional for PARU_OPTS
    # shellcheck disable=SC2086
    paru -Syuq $PARU_OPTS "${pkgs[@]}"
  else
    die "paru not found after installation attempt."
  fi
  ensure_tuckr
}
ensure_tuckr(){
  if ! has tuckr; then
    xecho "tuckr not found — installing via paru..."
    # shellcheck disable=SC2086
    paru -S $PARU_OPTS tuckr || die "Failed to install tuckr via paru."
  fi
  xecho "tuckr is ready."
}
setup_dotfiles(){
  has yadm || die "yadm command not found. Package installation failed."
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    xecho "Cloning dotfiles with yadm..."
    yadm clone --bootstrap "$DOTFILES_REPO"
  else
    xecho "Dotfiles repo exists. Pulling latest changes & re-running bootstrap..."
    yadm pull && yadm bootstrap
  fi
}
tuckr_system_configs(){
  xecho "Linking system-wide configs for /etc and /usr with tuckr..."
  has tuckr || die "tuckr command not found. Cannot link system configs."
  [[ -d "$TUCKR_DIR" ]] || die "Dotfiles directory not found at $TUCKR_DIR."
  local tuckr_pkgs=(etc usr)
  for pkg in "${tuckr_pkgs[@]}"; do
    if [[ -d "${TUCKR_DIR}/${pkg}" ]]; then
      xecho "Linking '${pkg}' to target '/'..."
      sudo tuckr link -d "$TUCKR_DIR" -t / "$pkg"
    else
      warn "tuckr package '${pkg}' not found in repo, skipping."
    fi
  done
}
final_steps(){
  xecho "Setup complete. Some changes may require a reboot or new login session."
  [[ "$SHELL" != "/bin/zsh" ]] && warn "Your shell is set to Zsh. Log out and back in to use it."
  xecho "Run 'yadm status' to check the state of your dotfiles."
}
#--- Execution ---#
main "$@"
