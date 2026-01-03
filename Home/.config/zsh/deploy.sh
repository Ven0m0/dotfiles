#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail
shopt -s nullglob
IFS=$'\n\t'
has(){ command -v -- "$1" &>/dev/null; }

readonly ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
readonly BACKUP="$HOME/.zsh_backup_$(date +%s)"

main(){
  printf '=== Fish-Like Zsh Deployment ===\n\n'
  # Backup
  if [[ -d $ZDOTDIR ]] || [[ -f $HOME/.zshrc ]]; then
    mkdir -p "$BACKUP"
    [[ -d $ZDOTDIR ]] && cp -r "$ZDOTDIR" "$BACKUP/"
    [[ -f $HOME/.zshrc ]] && cp "$HOME/.zshrc" "$BACKUP/"
    printf 'Backed up to: %s\n' "$BACKUP"
  fi
  # Deploy
  mkdir -p "$ZDOTDIR"
  cp zshrc.zsh "$ZDOTDIR/.zshrc"
  cp zimrc.zsh "$ZDOTDIR/.zimrc"
  ln -sf "$ZDOTDIR/.zshrc" "$HOME/.zshrc"
  # Verify zsh
  has zsh || { printf '\n⚠ Install zsh first\n'; exit 1; }
  printf '\n✅ Deployed\nRun: exec zsh\n'
  [[ -t 0 ]] && read -rp 'Start now? [Y/n] ' r && [[ ${r,,} =~ ^(y|)$ ]] && exec zsh
}
main "$@"
