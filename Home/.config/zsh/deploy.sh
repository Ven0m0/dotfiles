#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
IFS=$'\n\t'

# ============================================================================
# Zsh Config Deployment - Optimized with Zimfw
# ============================================================================

readonly ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
readonly BACKUP_DIR="$HOME/.zsh_backup_$(date +%s)"

has(){ command -v -- "$1" &>/dev/null; }

main(){
  printf '=== Zsh Config Deployment ===\n\n'
  
  # Backup existing configs
  if [[ -d $ZDOTDIR ]] || [[ -f $HOME/.zshrc ]]; then
    printf 'Backing up existing configs to: %s\n' "$BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    [[ -d $ZDOTDIR ]] && cp -r "$ZDOTDIR" "$BACKUP_DIR/"
    [[ -f $HOME/.zshrc ]] && cp "$HOME/.zshrc" "$BACKUP_DIR/"
  fi
  
  # Create directory structure
  mkdir -p "$ZDOTDIR"
  
  # Deploy configs (assuming they're in current directory)
  if [[ -f zimrc.zsh ]]; then
    cp zimrc.zsh "$ZDOTDIR/.zimrc"
    printf '✓ Deployed .zimrc\n'
  fi
  
  if [[ -f zshrc.zsh ]]; then
    cp zshrc.zsh "$ZDOTDIR/.zshrc"
    printf '✓ Deployed .zshrc\n'
  fi
  
  # Create symlink for backward compatibility
  if [[ ! -L $HOME/.zshrc ]]; then
    ln -sf "$ZDOTDIR/.zshrc" "$HOME/.zshrc"
    printf '✓ Created symlink: ~/.zshrc -> %s/.zshrc\n' "$ZDOTDIR"
  fi
  
  # Verify zsh is available
  if ! has zsh; then
    printf '\n⚠ Zsh not found. Install it:\n'
    printf '  Arch: sudo pacman -S zsh\n'
    printf '  Debian: sudo apt install zsh\n'
    exit 1
  fi
  
  printf '\n=== Installation Complete ===\n'
  printf 'Next steps:\n'
  printf '1. Start new zsh session: zsh\n'
  printf '2. Zimfw will auto-install plugins on first run\n'
  printf '3. Set as default shell: chsh -s /usr/bin/zsh\n'
  printf '4. Check startup time: zsh -i -c exit\n\n'
  
  # Offer to start zsh
  if [[ -t 0 ]]; then
    read -rp 'Start zsh now? [Y/n] ' response
    [[ ${response,,} =~ ^(y|yes|)$ ]] && exec zsh
  fi
}

main "$@"
