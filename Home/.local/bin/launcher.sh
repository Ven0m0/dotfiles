#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
set -euo pipefail; shopt -s nullglob globstar
export LC_ALL=C; IFS=$'\n\t'
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
has(){ command -v -- "$1" &>/dev/null; }
# Unified launcher for apps, files, and power management
# Targets: Arch/Wayland, Debian/Raspbian, Termux
# Dependencies: fzf, fd, bemenu/rofi (GUI fallbacks), systemctl/loginctl
export HOME="/home/${SUDO_USER:-$USER}"

# Menu abstraction - detects context and selects best provider
_menu(){
  local prompt="${1:-select: }"
  if [[ -t 0 ]] && has fzf; then
    fzf --prompt="$prompt" --height=40% --layout=reverse-list --border; return
  fi
  if has bemenu; then
    bemenu -i -l 10 -p "$prompt" --tf "#fab387" --hf "#89b4fa"
  elif has rofi; then
    rofi -dmenu -i -p "$prompt"
  elif has dmenu; then
    dmenu -i -p "$prompt"
  else
    printf 'Error: No menu tool (fzf, bemenu, rofi) found.\n' >&2; exit 1
  fi
}

_confirm(){
  local ans
  ans=$(printf "No\nYes" | _menu "Confirm execute?")
  [[ $ans == "Yes" ]]
}

# Mode: App Launcher
mode_app(){
  local cmd dir file
  local -A paths
  # Iterate PATH to find executables (bash-native, no ls parsing)
  IFS=: read -ra path_dirs <<<"$PATH"
  for dir in "${path_dirs[@]}"; do
    [[ -d $dir && -r $dir ]] || continue
    for file in "$dir"/*; do
      [[ -x $file && ! -d $file ]] || continue
      paths["${file##*/}"]=1
    done
  done
  cmd=$(printf '%s\n' "${!paths[@]}" | sort | _menu "Run: ") || return 0
  if [[ -n $cmd ]]; then
    nohup "$cmd" &>/dev/null &
    disown
  fi
}

# Mode: Power Menu
mode_power(){
  local -a opts=("Lock" "Suspend" "Logout" "Reboot" "Power Off" "Firmware Setup")
  local action
  action=$(printf '%s\n' "${opts[@]}" | _menu "Power: ") || return 0
  case "$action" in
    "Lock") loginctl lock-session ;;
    "Suspend") _confirm && systemctl suspend ;;
    "Logout") _confirm && loginctl terminate-user "$USER" ;;
    "Reboot") _confirm && systemctl reboot ;;
    "Power Off") _confirm && systemctl poweroff ;;
    "Firmware Setup") _confirm && systemctl reboot --firmware-setup ;;
  esac
}

# Mode: File Opener
mode_file(){
  local target
  target=$(fd --type f . "$HOME" 2>/dev/null|_menu "Open File: ")||return 0
  if [[ -n $target ]]; then
    xdg-open "$target" &>/dev/null &
    disown
  fi
}

# Main dispatch
main(){
  local mode="${1:-}"
  if [[ -z $mode ]]; then
    # Main menu if no argument provided
    local -a modes=("App Launcher" "File Opener" "Power Menu")
    local selection
    selection=$(printf '%s\n' "${modes[@]}"|_menu "Launcher: ")||exit 0
    case "$selection" in
      "App Launcher") mode="app" ;;
      "File Opener") mode="file" ;;
      "Power Menu") mode="power" ;;
    esac
  fi
  case "${mode,,}" in
    app|run) mode_app ;;
    power) mode_power ;;
    file|open) mode_file ;;
    *) printf "Usage: %s [app|power|file]\n" "$0"; exit 1 ;;
  esac
}

main "$@"
