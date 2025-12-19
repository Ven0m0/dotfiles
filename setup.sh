#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
# shellcheck disable=SC2310
# shellcheck source=Home/.local/lib/bash-common.sh
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s
source "${s%/*}/Home/.local/lib/bash-common.sh"
init_strict
cd -P -- "${s%/*}"
DRY_RUN=false
VERBOSE=true
parse_args(){
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--dry-run) DRY_RUN=true; info "Dry-run mode enabled";;
      -v|--verbose) VERBOSE=true;;
      -h|--help) show_help; exit 0;;
      *) warn "Unknown option: $1"; show_help; exit 1;;
    esac
    shift
  done
}
show_help(){
  cat <<'EOF'
Dotfiles Setup Script
Usage: setup.sh [OPTIONS]
  -n, --dry-run   Show actions without applying
  -v, --verbose   Verbose output
  -h, --help      Show this help
EOF
}
parse_args "$@"
[[ $EUID -eq 0 ]] && die "Run as a regular user, not root."
[[ $DRY_RUN == false ]] && { sudo -v || die "sudo access required"; }
readonly DOTFILES_REPO="https://github.com/Ven0m0/dotfiles.git"
readonly YADM_DIR="${HOME}/.local/share/yadm/repo.git"
readonly WORKTREE="$(
  has yadm && yadm config core.worktree 2>/dev/null || printf '%s\n' "${HOME}"
)"
main(){
  install_packages
  setup_dotfiles
  deploy_home
  link_system_configs
  final_steps
}
install_packages(){
  info "Installing packages..."
  local paru_opts=(--needed --noconfirm --skipreview --sudoloop --batchinstall --combinedupgrade)
  local pkgs=(git gitoxide aria2 curl zsh fd sd ripgrep bat jq zoxide starship fzf yadm tuckr konsave)
  if ! has paru; then
    die "paru not found."
  fi
  if [[ $DRY_RUN == true ]]; then
    info "[DRY-RUN] Would install: ${pkgs[*]}"
    return 0
  fi
  paru -Syuq "${paru_opts[@]}" "${pkgs[@]}" || die "Failed to install packages"
}
setup_dotfiles(){
  if ! has yadm; then
    die "yadm not found."
  fi
  if [[ ! -d $YADM_DIR ]]; then
    info "Cloning dotfiles..."
    yadm clone --bootstrap "$DOTFILES_REPO" || die "Failed to clone dotfiles"
  else
    info "Pulling changes..."
    yadm pull || warn "Failed to pull changes"
    yadm bootstrap || warn "Bootstrap failed"
  fi
}
deploy_home(){
  local home_dir="${WORKTREE}/Home"
  [[ -d $home_dir ]] || { warn "Home dir not found: $home_dir"; return 0; }
  info "Deploying Home/ → $HOME/"
  if has rsync; then
    rsync -a --delete --exclude='.git' --exclude='.gitignore' "${home_dir}/" "${HOME}/"
  else
    warn "rsync not available, using cp"
    cp -a "${home_dir}/." "${HOME}/"
  fi
}
link_system_configs(){
  if ! has tuckr; then
    warn "tuckr not found; skipping etc/usr deploy"
    return 0
  fi
  local hooks_file="${WORKTREE}/hooks.toml" pkg
  for pkg in etc usr; do
    local src="${WORKTREE}/${pkg}"
    [[ -d $src ]] || { warn "Directory not found: $src"; continue; }
    info "Linking ${pkg}/ → /"
    local cmd=(sudo tuckr link -d "$WORKTREE" -t / "$pkg")
    [[ -f $hooks_file ]] && cmd+=(-H "$hooks_file")
    "${cmd[@]}" || warn "Failed to link ${pkg}"
  done
}
final_steps(){
  info "Run 'yadm status' to review."
  info "For system configs: sudo tuckr link -d $WORKTREE -t / etc usr"
  info "Validate /etc/fstab with: sudo systemd-analyze verify /etc/fstab"
  info "Setup complete."
}
main "$@"
