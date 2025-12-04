#!/usr/bin/env bash
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

set -euo pipefail
has() { command -v "$1" &>/dev/null; }

# exit 0 - successful execution
# exit 1 - no selection
# exit 2 - error

WALLPAPERS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers"
mkdir -p "$WALLPAPERS_DIR"
QUIET=""

send_feedback(){
  local msg="$1"
  if [[ -z $QUIET ]]; then
    printf '%s\n' "$msg"
    has notify-send && notify-send "$msg" || :
  fi
}

set_wallpaper(){
  local wallpaper="$1"
  case "${XDG_SESSION_TYPE:-}" in
    wayland)
      killall -q swaybg || :
      swaybg --image "$wallpaper" &
      ;;
    x11)
      feh --no-fehbg --bg-scale "$wallpaper" &
      ;;
    *)
      send_feedback "Unknown session type: ${XDG_SESSION_TYPE:-none}"
      exit 2
      ;;
  esac
}

random_wallpaper(){
  local wallpaper
  wallpaper=$(find "$WALLPAPERS_DIR" -type f -not -path '*/.git/*' | shuf -n 1) || {
    send_feedback "No file selected"
    exit 1
  }

  if [[ -n $wallpaper ]]; then
    set_wallpaper "$wallpaper"
    send_feedback "Set random wallpaper."
    exit 0
  else
    send_feedback "No file selected"
    exit 1
  fi
}

select_wallpaper(){
  local wallpaper
  wallpaper=$(
    find "$WALLPAPERS_DIR" -type f -not -path '*/.git/*' -exec basename {} \; \
      | sed 's/\.\(png\|jpg\|jpeg\)$//' \
      | fzf \
        --prompt "wallpaper: " \
        --header="${FZF_DEFAULT_HEADER:-}"
  ) || {
    send_feedback "No file selected!"
    exit 1
  }

  if [[ -n $wallpaper ]]; then
    local full_path
    full_path=$(find "$WALLPAPERS_DIR" -type f -name "*${wallpaper}.*")
    set_wallpaper "$full_path"
    send_feedback "Set selected wallpaper"
    exit 0
  else
    send_feedback "No file selected!"
    exit 1
  fi
}

while getopts ":d:hqrs" opt; do
  case "$opt" in
    d)
      if [[ -d $OPTARG ]]; then
        WALLPAPERS_DIR="$OPTARG"
      else
        send_feedback "Error: \"$OPTARG\" is not a directory" >&2
        exit 2
      fi
      ;;
    h)
      sed "1,2d;s/^# //;s/^#$/ /;/^$/ q" "$0"
      exit 0
      ;;
    q)
      QUIET=true
      ;;
    r)
      random_wallpaper
      ;;
    s)
      select_wallpaper
      ;;
    :)
      send_feedback "Error: Option -${OPTARG} requires an argument" >&2
      exit 2
      ;;
    \?)
      send_feedback "Error: Option -${OPTARG} is not an option" >&2
      exit 2
      ;;
  esac
done

if [[ ! -d $WALLPAPERS_DIR ]]; then
  send_feedback "Error: no directory provided" >&2
  exit 2
fi
