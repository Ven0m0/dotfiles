#!/usr/bin/env bash
set -euo pipefail
# Select launcher based on availability
if command -v bemenu &>/dev/null; then
  # -i: insensitive, -l: lines (vertical), -p: prompt
  _menu() { bemenu -i -l 10 -p "$1" --tf "$COLOR_ACCENT" --hf "$COLOR_HIGHLIGHT"; }
elif command -v rofi &>/dev/null; then
  # -dmenu: pipe mode, -i: insensitive, -p: prompt
  _menu() { rofi -dmenu -i -p "$1"; }
else
  printf "No menu tool found.\n" >&2; exit 1
fi

run_menu(){
  local -a opts=("Lock" "Logout" "Reboot" "Poweroff"); local choice
  # Pass array elements as newlines to menu
  # mapfile reads result back into 'choice' strictly
  choice=$(printf "%s\n" "${opts[@]}" | _menu "System:")
  # Fast string matching
  case "${choice,,}" in # ,, = lowercase
    lock) loginctl lock-session ;;
    logout) loginctl terminate-user "$USER" ;;
    reboot) systemctl reboot ;;
    poweroff) systemctl poweroff ;;
    *) : ;; # Ignore cancel/empty
  esac
}
run_menu

# fd: fast, ignores .git, coloring off
open_file(){
  local target=$(fd --type f . "$HOME" | _menu "Open:")
  [[ -f "$target" ]] && { xdg-open "$target" &>/dev/null &; disown; }
}

