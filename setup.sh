#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t'
export LC_ALL=C LANG=C LANGUAGE=C HOME="/home/${SUDO_USER:-$USER}"
cd -P -- "$(cd -P -- "${BASH_SOURCE[0]%/*}" && echo "$PWD")" || exit 1
# Arch/CachyOS System Setup
# 1. Installs AUR helper (paru) & essential packages.
# 2. Clones dotfiles repo with yadm.
# 3. Runs yadm bootstrap for user-level setup.
# 4. Uses tuckr to link system-wide configs (/etc, /usr).
#--- Helpers ---#
# Define color codes (used before common lib is installed)
BLK=$'\e[30m' RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m'
BLU=$'\e[34m' MGN=$'\e[35m' CYN=$'\e[36m' WHT=$'\e[37m'
LBLU=$'\e[38;5;117m' PNK=$'\e[38;5;218m' BWHT=$'\e[97m'
DEF=$'\e[0m' BLD=$'\e[1m'

# Basic utility functions (duplicated here as common lib may not exist yet)
has(){ command -v "$1" &>/dev/null; }
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
  local has_paru
  has_paru=$(has paru && echo 1 || echo 0)
  
  if [[ "$has_paru" == "0" ]]; then
    printf '%b\n' "${BLD}${BLU}==>${BWHT} Installing AUR helper (paru)...${DEF}"
    sudo pacman -S --needed --noconfirm base-devel git
    local tmpdir; tmpdir=$(mktemp -d)
    git clone --depth=1 https://aur.archlinux.org/paru-bin.git "$tmpdir"
    (cd "$tmpdir" && makepkg -si --noconfirm) || die "paru installation failed."
    rm -rf "$tmpdir"
    has_paru=1
  fi
  printf '%b\n' "${BLD}${BLU}==>${BWHT} AUR helper (paru) is ready.${DEF}"
}
install_packages(){
  printf '%b\n' "${BLD}${BLU}==>${BWHT} Installing packages from official and AUR repositories...${DEF}"
  local pkgs=(
    git gitoxide aria2 curl zsh fd sd ripgrep bat jq
    zoxide starship fzf yadm tuckr
  )
  local has_paru
  has_paru=$(has paru && echo 1 || echo 0)
  
  if [[ "$has_paru" == "1" ]]; then
    # Word splitting is intentional for PARU_OPTS
    # shellcheck disable=SC2086
    paru -Syuq $PARU_OPTS "${pkgs[@]}"
  else
    die "paru not found after installation attempt."
  fi
  ensure_tuckr
}
ensure_tuckr(){
  local has_tuckr
  has_tuckr=$(has tuckr && echo 1 || echo 0)
  
  if [[ "$has_tuckr" == "0" ]]; then
    printf '%b\n' "${BLD}${BLU}==>${BWHT} tuckr not found — installing via paru...${DEF}"
    # shellcheck disable=SC2086
    paru -S $PARU_OPTS tuckr || die "Failed to install tuckr via paru."
  fi
  printf '%b\n' "${BLD}${BLU}==>${BWHT} tuckr is ready.${DEF}"
}
setup_dotfiles(){
  has yadm || die "yadm command not found. Package installation failed."
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    printf '%b\n' "${BLD}${BLU}==>${BWHT} Cloning dotfiles with yadm...${DEF}"
    yadm clone --bootstrap "$DOTFILES_REPO"
  else
    printf '%b\n' "${BLD}${BLU}==>${BWHT} Dotfiles repo exists. Pulling latest changes & re-running bootstrap...${DEF}"
    yadm pull && yadm bootstrap
  fi
}
tuckr_system_configs(){
  printf '%b\n' "${BLD}${BLU}==>${BWHT} Linking system-wide configs for /etc and /usr with tuckr...${DEF}"
  has tuckr || die "tuckr command not found. Cannot link system configs."
  [[ -d "$TUCKR_DIR" ]] || die "Dotfiles directory not found at $TUCKR_DIR."
  local tuckr_pkgs=(etc usr)
  for pkg in "${tuckr_pkgs[@]}"; do
    if [[ -d "${TUCKR_DIR}/${pkg}" ]]; then
      printf '%b\n' "${BLD}${BLU}==>${BWHT} Linking '${pkg}' to target '/'...${DEF}"
      sudo tuckr link -d "$TUCKR_DIR" -t / "$pkg"
    else
      warn "tuckr package '${pkg}' not found in repo, skipping."
    fi
  done
}
final_steps(){
  printf '%b\n' "${BLD}${BLU}==>${BWHT} Setup complete. Some changes may require a reboot or new login session.${DEF}"
  [[ "$SHELL" != "/bin/zsh" ]] && warn "Your shell is set to Zsh. Log out and back in to use it."
  printf '%b\n' "${BLD}${BLU}==>${BWHT} Run 'yadm status' to check the state of your dotfiles.${DEF}"
}
#--- Execution ---#
main "$@"
