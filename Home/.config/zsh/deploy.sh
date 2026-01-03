#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail
shopt -s nullglob
IFS=$'\n\t'

has(){ command -v -- "$1" &>/dev/null; }
readonly ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
readonly BACKUP="$HOME/.zsh_backup_$(date +%s)"

main(){
  printf '=== Zsh Modular Deployment ===\n\n'
  # Backup existing configs
  if [[ -d $ZDOTDIR ]] || [[ -f $HOME/.zshrc ]]; then
    mkdir -p "$BACKUP"
    [[ -d $ZDOTDIR ]] && cp -r "$ZDOTDIR" "$BACKUP/"
    [[ -f $HOME/.zshrc ]] && cp "$HOME/.zshrc" "$BACKUP/"
    printf 'Backed up to: %s\n' "$BACKUP"
  fi
  # Create directory structure
  mkdir -p "$ZDOTDIR/config" "$ZDOTDIR/completions"
  # Deploy files
  cp zshrc.zsh "$ZDOTDIR/.zshrc"
  cp zimrc.zsh "$ZDOTDIR/.zimrc"
  cp aliases.zsh "$ZDOTDIR/config/aliases.zsh"
  cp functions.zsh "$ZDOTDIR/config/functions.zsh"
  cp completions.zsh "$ZDOTDIR/config/completions.zsh"
  # Create symlink for backward compatibility
  ln -sf "$ZDOTDIR/.zshrc" "$HOME/.zshrc"
  # Verify zsh
  has zsh || { printf '\n⚠ Install zsh first\n'; exit 1; }
  printf '\n✅ Deployed\n'
  printf 'Structure:\n'
  printf '  ~/.config/zsh/\n'
  printf '    ├── .zshrc            (main config)\n'
  printf '    ├── .zimrc            (plugins)\n'
  printf '    ├── config/\n'
  printf '    │   ├── aliases.zsh   (aliases + abbreviations)\n'
  printf '    │   ├── functions.zsh (utility functions)\n'
  printf '    │   └── completions.zsh (tab completion)\n'
  printf '    └── completions/      (custom completions)\n\n'
  printf 'Quick edit aliases:\n'
  printf '  zshrc        - Edit main config\n'
  printf '  aliases      - Edit aliases\n'
  printf '  functions    - Edit functions\n'
  printf '  completions  - Edit completions\n\n'
  [[ -t 0 ]] && read -rp 'Start zsh now? [Y/n] ' r && [[ ${r,,} =~ ^(y|)$ ]] && exec zsh
}
main "$@"
