#!/usr/bin/env bash
#
# summary: a simple posix script for powering down your system
# repository: http://github.com/hollowillow/scripts
#
# usage: power
#
# depedencies: hyprlock (out of the box), systemctl (out of the box)
set -euo pipefail

# create help message from comment block at the head of file
if [[ "${1:-}" == "-h" ]]; then
    sed "1,2d;s/^# //;s/^#$/ /;/^$/ q" "$0"
    exit 0
fi

chosen=$(printf "Lock\nSuspend\nPower Off\nReboot" | fzf --prompt 'power: ') || exit 0

confirm() {
    [[ "$(printf '%s\n' Yes No | fzf --prompt 'confirm: ')" == "Yes" ]]
}

case "$chosen" in
    "Lock")
        confirm && nohup hyprlock >/dev/null 2>&1 &
        ;;
    "Suspend")
        confirm && systemctl suspend
        ;;
    "Power Off")
        confirm && systemctl poweroff
        ;;
    "Reboot")
        confirm && systemctl reboot
        ;;
esac
