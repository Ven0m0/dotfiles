#!/usr/bin/env bash
set -euo pipefail
# summary: a simple posix script for powering down your system
# depedencies: hyprlock (out of the box), systemctl (out of the box)
[[ "${1:-}" == "-h" ]] && { sed "1,2d;s/^# //;s/^#$/ /;/^$/ q" "$0"; exit 0; }
chosen=$(printf "Lock\nSuspend\nPower Off\nReboot" | fzf --prompt 'power: ') || exit 0
confirm(){ [[ "$(printf '%s\n' Yes No | fzf --prompt 'confirm: ')" == "Yes" ]]; }
case "$chosen" in
  "Lock") confirm && nohup hyprlock &>/dev/null &;;
  "Suspend") confirm && systemctl suspend;;
  "Power Off") confirm && systemctl poweroff;;
  "Reboot") confirm && systemctl reboot;;
esac
