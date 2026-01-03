#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail
shopt -s nullglob
IFS=$'\n\t'

has(){ command -v -- "$1" &>/dev/null; }
readonly ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
readonly BACKUP="$HOME/.zsh_backup_$(date +%s)"

main(){
  printf '=== Zsh Fish-Like Deployment ===\n\n'
  # Backup
  if [[ -d $ZDOTDIR ]] || [[ -f $HOME/.zshrc ]]; then
    mkdir -p "$BACKUP"
    [[ -d $ZDOTDIR ]] && cp -r "$ZDOTDIR" "$BACKUP/"
    [[ -f $HOME/.zshrc ]] && cp "$HOME/.zshrc" "$BACKUP/"
    printf 'Backed up to: %s\n' "$BACKUP"
  fi
  # Deploy
  mkdir -p "$ZDOTDIR/completions"
  cp zshrc.zsh "$ZDOTDIR/.zshrc"
  cp zimrc.zsh "$ZDOTDIR/.zimrc"
  ln -sf "$ZDOTDIR/.zshrc" "$HOME/.zshrc"
  # Verify
  has zsh || { printf '\n⚠ Install zsh first\n'; exit 1; }
  printf '\n✅ Deployed\n'
  printf 'Commands:\n'
  printf '  exec zsh      - Start zsh\n'
  printf '  zimupdate     - Update plugins\n'
  printf '  reload        - Reload config\n\n'
  [[ -t 0 ]] && read -rp 'Start now? [Y/n] ' r && [[ ${r,,} =~ ^(y|)$ ]] && exec zsh
}
main "$@"
