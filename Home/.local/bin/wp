#!/bin/sh
#
# summary: a simple posix wrapper script for setting wallpapers
# repository: https://github.com/hollowillow/scripts
#
# usage: wp -r|s [-hq] [-d arg]
# options: 
#       
#       -d      specify directory
#       -h      display this help message
#       -q      supress all output
#       -r      set a random wallpaper from directory
#       -s      select a wallpaper from directory via fzf
#
# dependencies: fzf, swaybg (wayland), fehbg (x11), libnotify (optional)

# exit 0 - successful execution
# exit 1 - no selection
# exit 2 - error

WALLPAPERS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers"
mkdir -p "$AUTOSTART_DIR" # create directory if it doesn't already exist

### define functions ###

sendFeedback() {
        if [ -z "$QUIET" ]; then
                printf '%s\n' "$1"; notify-send "$1"
        fi
}

setWallpaper() {
        if [ "$(printenv XDG_SESSION_TYPE)" = wayland ]; then
                swaybg --image "$1" &
        elif [ "$(printenv XDG_SESSION_TYPE)" = x11 ]; then
                fehbg --no-fehbg --bg-scale "$1" &
        fi
}

randomWallpaper() {
        WALLPAPER="$(\
                find "$WALLPAPERS_DIR" -type f -not -path '*/\.git/*' |
                shuf -n 1
        )"
        if [ -n "$WALLPAPER" ]; then 
                setWallpaper "$WALLPAPER"; sendFeedback "Set random wallpaper."; exit 0
        else
                sendFeedback "No file selected"; exit 1
        fi
}

selectWallpaper() {
        WALLPAPER="$(\
                find "$WALLPAPERS_DIR" -type f -not -path '*/\.git/*' -exec basename {} \; |
                sed "s/\.png$//;s/\.jpg$//;s/\.jpeg$//;" |
                fzf \
                --prompt "wallpaper: " \
                --header="$(printf '%s\n' "$FZF_DEFAULT_HEADER")"
        )"
        if [ -n "$WALLPAPER" ]; then 
                setWallpaper "$(find "$WALLPAPERS_DIR" -type f -name "*$WALLPAPER\.*")"; sendFeedback "Set selected wallpaper"; exit 0
        else
                sendFeedback "No file selected!"; exit 1
        fi
}

### parse options ###

while getopts ":d:hqrs" OPT >/dev/null >&2
do
        case "$OPT" in
                d) if [ -d "$OPTARG" ]; then WALLPAPERS_DIR="$OPTARG"; else sendFeedback "Error: \"$OPTARG\" is not a directory" >&2; exit 2; fi;;
                h) sed "1,2d;s/^# //;s/^#$/ /;/^$/ q" "$0"; exit 0;;
                q) QUIET=true;;
                r) randomWallpaper;;
                s) selectWallpaper;;
                :) sendFeedback "Error: Option -""${OPTARG}"" requires an argument"; exit 2;;
                \?) sendFeedback "Error: Option -""${OPTARG}"" is not an option"; exit 2;;
        esac
done
### execute ###

if [ ! -d "$WALLPAPERS_DIR" ]; then
        sendFeedback "Error: no directory provided"; exit 2
fi
