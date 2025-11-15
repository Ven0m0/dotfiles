#!/usr/bin/env bash
# Deploy dotfiles from Home/ subdirectory to actual home directory
set -euo pipefail

# Colors
RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' BLU=$'\e[34m'
BWHT=$'\e[97m' DEF=$'\e[0m' BLD=$'\e[1m'

info() { printf '%b\n' "${BLD}${BLU}==>${BWHT} $1${DEF}"; }
warn() { printf '%b\n' "${BLD}${YLW}==> WARNING:${BWHT} $1${DEF}"; }
die() { printf '%b\n' "${BLD}${RED}==> ERROR:${BWHT} $1${DEF}" >&2; exit 1; }

# Determine the repository location
if command -v yadm &>/dev/null && yadm rev-parse --git-dir &>/dev/null; then
  REPO_DIR="$(yadm rev-parse --show-toplevel)"
  info "Using yadm repository at: $REPO_DIR"
elif [ -d "${HOME}/.local/share/yadm/repo.git" ]; then
  REPO_DIR="${HOME}/.local/share/yadm/repo.git"
  info "Using yadm default location: $REPO_DIR"
elif [ -d "$(dirname "${BASH_SOURCE[0]}")" ]; then
  # Fallback: assume script is in the repo
  REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel 2>/dev/null || pwd)"
  info "Using script location: $REPO_DIR"
else
  die "Cannot determine repository location"
fi

HOME_DIR="${REPO_DIR}/Home"

[ ! -d "$HOME_DIR" ] && die "Home directory not found at: $HOME_DIR"

info "Deploying dotfiles from ${HOME_DIR} to ${HOME}"

# Use rsync if available, otherwise fallback to cp
if command -v rsync &>/dev/null; then
  info "Using rsync for deployment..."
  rsync -av --exclude='.git' "${HOME_DIR}/" "${HOME}/"
else
  info "Using cp for deployment (rsync not available)..."
  cp -r "${HOME_DIR}/." "${HOME}/"
fi

info "Dotfiles deployed successfully!"
info "Note: You may need to log out and back in for some changes to take effect."
