#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'
export LC_ALL=C LANG=C LANGUAGE=C HOME="/home/${SUDO_USER:-$USER}"
cd -P -- "$(cd -P -- "${BASH_SOURCE[0]%/*}" && echo "$PWD")" || exit 1
# Arch/CachyOS System Setup
# 1. Installs AUR helper (paru) & essential packages.
# 2. Clones dotfiles repo with yadm.
# 3. Runs yadm bootstrap for user-level setup.
# 4. Deploys dotfiles from Home/ subdirectory to home directory.
# 5. Uses tuckr to link system-wide configs (/etc, /usr).
#--- Options ---#
DRY_RUN=false
VERBOSE=false
#--- Helpers ---#
# Define color codes (used before common lib is installed)
BLK=$'\e[30m' RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m'
BLU=$'\e[34m' MGN=$'\e[35m' CYN=$'\e[36m' WHT=$'\e[37m'
LBLU=$'\e[38;5;117m' PNK=$'\e[38;5;218m' BWHT=$'\e[97m'
DEF=$'\e[0m' BLD=$'\e[1m'

# Basic utility functions (duplicated here as common lib may not exist yet)
has() { command -v "$1" &>/dev/null; }
warn() { printf '%b\n' "${BLD}${YLW}==> WARNING:${BWHT} $1${DEF}"; }
die() {
	printf '%b\n' "${BLD}${RED}==> ERROR:${BWHT} $1${DEF}" >&2
	exit 1
}
info() { printf '%b\n' "${BLD}${BLU}==>${BWHT} $1${DEF}"; }
success() { printf '%b\n' "${BLD}${GRN}==>${BWHT} $1${DEF}"; }

# Dry-run execution wrapper
run_cmd() {
	if [[ $DRY_RUN == true ]]; then
		printf '%b\n' "${BLD}${CYN}[DRY-RUN]${BWHT} $*${DEF}"
		return 0
	fi
	"$@"
}
#--- Argument Parsing ---#
parse_args() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--dry-run | -n)
			DRY_RUN=true
			info "Dry-run mode enabled - no changes will be made"
			shift
			;;
		--verbose | -v)
			VERBOSE=true
			shift
			;;
		--help | -h)
			show_help
			exit 0
			;;
		*)
			warn "Unknown option: $1"
			show_help
			exit 1
			;;
		esac
	done
}

show_help() {
	cat <<EOF
${BLD}Dotfiles Setup Script${DEF}

Usage: $(basename "$0") [OPTIONS]

Options:
  -n, --dry-run    Show what would be done without making changes
  -v, --verbose    Enable verbose output
  -h, --help       Show this help message

Description:
  This script sets up the dotfiles repository by:
  1. Installing required packages (paru, yadm, tuckr, etc.)
  2. Cloning dotfiles with yadm
  3. Deploying user configs from Home/ to ~/
  4. Linking system configs from etc/ and usr/ to /

Requirements:
  - Arch Linux or CachyOS
  - Internet connection
  - sudo access
  - Must NOT be run as root

EOF
}

#--- Pre-flight Checks ---#
parse_args "$@"

[[ $EUID -eq 0 ]] && die "Run as a regular user, not root."

if [[ "$DRY_RUN" == false ]]; then
	sudo -v || die "sudo access required"
fi

! ping -c 1 archlinux.org &>/dev/null && die "No internet connection."
#--- Configuration ---#
readonly DOTFILES_REPO="https://github.com/Ven0m0/dotfiles.git"
readonly DOTFILES_DIR="${HOME}/.local/share/yadm/repo.git" # yadm's default git dir
readonly TUCKR_DIR="$DOTFILES_DIR"                         # Source for tuckr packages
readonly PARU_OPTS="--needed --noconfirm --skipreview --sudoloop --batchinstall --combinedupgrade"
#--- Main Logic ---#
main() {
	install_packages
	setup_dotfiles
	deploy_dotfiles
	tuckr_system_configs
	final_steps
}
#--- Functions ---#
install_packages() {
	info "Installing packages from official and AUR repositories..."
	local pkgs=(
		git gitoxide aria2 curl zsh fd sd ripgrep bat jq
		zoxide starship fzf yadm tuckr
	)

	# paru is a hard dependency on CachyOS and should always be available
	has paru || die "paru not found. This script requires CachyOS or Arch with paru installed."

	if [[ "$DRY_RUN" == true ]]; then
		info "[DRY-RUN] Would install packages: ${pkgs[*]}"
	else
		# Word splitting is intentional for PARU_OPTS
		# shellcheck disable=SC2086
		paru -Syuq "$PARU_OPTS" "${pkgs[@]}" || die "Failed to install packages"
	fi
	ensure_tuckr
}
ensure_tuckr() {
	if ! has tuckr; then
		info "tuckr not found — installing via paru..."
		if [[ "$DRY_RUN" == true ]]; then
			info "[DRY-RUN] Would install tuckr"
		else
			# shellcheck disable=SC2086
			paru -S "$PARU_OPTS" tuckr || die "Failed to install tuckr via paru."
		fi
	fi
	success "tuckr is ready."
}
setup_dotfiles() {
	has yadm || die "yadm command not found. Package installation failed."
	if [[ ! -d "$DOTFILES_DIR" ]]; then
		info "Cloning dotfiles with yadm..."
		if [[ "$DRY_RUN" == true ]]; then
			info "[DRY-RUN] Would clone: $DOTFILES_REPO"
		else
			yadm clone --bootstrap "$DOTFILES_REPO" || die "Failed to clone dotfiles"
		fi
	else
		info "Dotfiles repo exists. Pulling latest changes & re-running bootstrap..."
		if [[ "$DRY_RUN" == true ]]; then
			info "[DRY-RUN] Would pull and bootstrap"
		else
			yadm pull || warn "Failed to pull latest changes"
			yadm bootstrap || warn "Bootstrap failed"
		fi
	fi
}
deploy_dotfiles() {
	info "Deploying dotfiles from Home/ subdirectory..."

	# Determine the repository location
	local repo_dir
	if has yadm && yadm rev-parse --git-dir &>/dev/null; then
		repo_dir="$(yadm rev-parse --show-toplevel)"
	elif [[ -d "$DOTFILES_DIR" ]]; then
		repo_dir="$DOTFILES_DIR"
	else
		warn "Cannot determine repository location for Home/ deployment, skipping."
		return 0
	fi

	local home_dir="${repo_dir}/Home"

	if [[ ! -d "$home_dir" ]]; then
		warn "Home directory not found at: $home_dir, skipping deployment."
		return 0
	fi

	if [[ "$DRY_RUN" == true ]]; then
		info "[DRY-RUN] Would deploy from: $home_dir to $HOME"
		if has rsync; then
			info "[DRY-RUN] Using rsync for deployment"
		else
			info "[DRY-RUN] Using cp for deployment (rsync not available)"
		fi
		return 0
	fi

	# Use rsync if available, otherwise fallback to cp
	if has rsync; then
		info "Using rsync for deployment..."
		rsync -av --exclude='.git' "${home_dir}/" "${HOME}/" || die "rsync deployment failed"
	else
		info "Using cp for deployment (rsync not available)..."
		cp -r "${home_dir}/." "${HOME}/" || die "cp deployment failed"
	fi

	success "Dotfiles from Home/ deployed successfully!"
}
tuckr_system_configs() {
	info "Linking system-wide configs for /etc and /usr with tuckr..."
	has tuckr || die "tuckr command not found. Cannot link system configs."
	[[ -d "$TUCKR_DIR" ]] || die "Dotfiles directory not found at $TUCKR_DIR."

	local tuckr_pkgs=(etc usr)
	for pkg in "${tuckr_pkgs[@]}"; do
		if [[ -d "${TUCKR_DIR}/${pkg}" ]]; then
			if [[ "$DRY_RUN" == true ]]; then
				info "[DRY-RUN] Would link '${pkg}' to target '/'"
			else
				info "Linking '${pkg}' to target '/'..."
				sudo tuckr link -d "$TUCKR_DIR" -t / "$pkg" || warn "Failed to link ${pkg}"
			fi
		else
			warn "tuckr package '${pkg}' not found in repo, skipping."
		fi
	done
}
final_steps() {
	if [[ $DRY_RUN == true ]]; then
		success "Dry-run complete! No changes were made."
		info "To apply changes, run without --dry-run flag"
	else
		success "Setup complete!"
		info "Dotfiles have been cloned, deployed, and system configs linked."
		info "Some changes may require a reboot or new login session."
		[[ "$SHELL" != "/bin/zsh" ]] && warn "Consider changing your shell to Zsh with: chsh -s /bin/zsh"
		info "Run 'yadm status' to check the state of your dotfiles."
		info "Run 'yadm encrypt' to encrypt sensitive files (configured in .yadm/encrypt)"
	fi
}
#--- Execution ---#
main "$@"
