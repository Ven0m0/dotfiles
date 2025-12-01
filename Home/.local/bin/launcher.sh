#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'
export LC_ALL=C LANG=C HOME="/home/${SUDO_USER:-$USER}"
# summary: Unified launcher for apps, files, and power management
# targets: Arch/Wayland, Debian/Raspbian, Termux
# dependencies: fzf (preferred), fd, bemenu/rofi (GUI fallbacks), systemctl/loginctl
#
# usage: launcher.sh [app|power|file]
#        If no argument is provided, opens a mode selection menu.
has() { command -v "$1" &>/dev/null; }
# --- Menu Abstraction ---
# Detects context and available tools to select the best menu provider.
_menu(){
  local prompt="${1:-select: }"
  # 1. Prefer fzf if running in a terminal
  if [[ -t 0 ]] && has fzf; then
    fzf --prompt="$prompt" --height=40% --layout=reverse --border
    return
  fi
  # 2. GUI Menu Fallbacks
  if has bemenu; then
    # -i: insensitive, -l: lines, -p: prompt, --tf/hf: theme colors
    bemenu -i -l 10 -p "$prompt" --tf "#fab387" --hf "#89b4fa"
  elif has rofi; then
    rofi -dmenu -i -p "$prompt"
  elif has dmenu; then
    dmenu -i -p "$prompt"
  else
    printf "Error: No menu tool (fzf, bemenu, rofi) found.\n" >&2
    exit 1
  fi
}

# --- Confirmation Helper ---
_confirm(){
  local ans
  ans=$(printf "No\nYes" | _menu "Confirm execute?")
  [[ $ans == "Yes" ]]
}

# --- Mode: App Launcher (merged fmenu.sh) ---
mode_app(){
  local cmd dir file
  local -A paths
  # Iterate PATH to find executables (bash-native, avoids parsing ls)
  # Uses an associative array to deduplicate entries efficiently
  IFS=: read -ra path_dirs <<<"$PATH"
  for dir in "${path_dirs[@]}"; do
    [[ -d $dir && -r $dir ]] || continue
    for file in "$dir"/*; do
      [[ -x $file && ! -d $file ]] || continue
      paths["${file##*/}"]=1
    done
  done
  # Display sorted keys and execute selection
  cmd=$(printf '%s\n' "${!paths[@]}" | sort | _menu "Run: ") || return 0
  if [[ -n $cmd ]]; then
    # Use setsid/nohup to detach process fully
    nohup "$cmd" &>/dev/null &
    disown
  fi
}

# --- Mode: Power Menu (merged power.sh & launcher.sh) ---
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
  *) : ;;
  esac
}

# --- Mode: File Opener (from launcher.sh) ---
mode_file(){
  local target
  # fd: fast, ignores .git, hidden files excluded by default
  target=$(fd --type f . "$HOME" 2>/dev/null | _menu "Open File: ") || return 0
  [[ -n $target ]] && xdg-open "$target" &>/dev/null &
  disown
}

# --- Main Dispatch ---
main(){
  local mode="${1:-}"
  if [[ -z $mode ]]; then
    # Main menu if no argument provided
    local -a modes=("App Launcher" "File Opener" "Power Menu")
    local selection
    selection=$(printf '%s\n' "${modes[@]}" | _menu "Launcher: ") || exit 0
    case "$selection" in
    "App Launcher") mode="app" ;;
    "File Opener") mode="file" ;;
    "Power Menu") mode="power" ;;
    esac
  fi
  case "${mode,,}" in
  app | run) mode_app ;;
  power) mode_power ;;
  file | open) mode_file ;;
  *)
    printf "Usage: %s [app|power|file]\n" "$0"
    exit 1
    ;;
  esac
}

main "$@"
