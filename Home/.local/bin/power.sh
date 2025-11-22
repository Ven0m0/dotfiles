#!/bin/sh
#
# summary: a simple posix script for powering down your system
# repository: http://github.com/hollowillow/scripts
#
# usage: power
#
# depedencies: hyprlock (out of the box), systemctl (out of the box)

# create help message from comment block at the head of file
if [ "$1" = "-h" ]; then
        sed "1,2d;s/^# //;s/^#$/ /;/^$/ q" "$0"; exit 0
fi

CHOSEN="$(printf "Lock\nSuspend\nPower Off\nReboot" | fzf --prompt 'power: ')"

case $CHOSEN in
        # alter for usage with other utilities
        "Lock") if [ "$(printf '%s\n' Yes No | fzf --prompt 'confirm: ')" = "Yes" ]; then nohup hyprlock >/dev/null & fi;;
        "Suspend") if [ "$(printf '%s\n' Yes No | fzf --prompt 'confirm: ')" = "Yes" ]; then systemctl suspend; fi;;
        "Power Off") if [ "$(printf '%s\n' Yes No | fzf --prompt 'confirm: ')" = "Yes" ]; then systemctl poweroff; fi;;
        "Reboot") if [ "$(printf '%s\n' Yes No | fzf --prompt 'confirm: ')" = "Yes" ]; then systemctl reboot; fi;;
esac
