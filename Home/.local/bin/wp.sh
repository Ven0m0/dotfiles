#!/usr/bin/env bash
set -euo pipefail;shopt -s nullglob globstar extglob;IFS=$'\n\t';LC_ALL=C;LANG=C
has(){ command -v "$1" &>/dev/null;}
die(){ printf '%b[ERROR]%b %s\n' '\e[1;31m' '\e[0m' "$*" >&2;exit "${2:-1}";}
warn(){ printf '%b[WARN]%b %s\n' '\e[1;33m' '\e[0m' "$*" >&2;}
log(){ printf '%b[INFO]%b %s\n' '\e[1;34m' '\e[0m' "$*";}
WALLPAPERS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers"
mkdir -p "$WALLPAPERS_DIR"
QUIET=""
send_feedback(){ local msg="$1";[[ -z $QUIET ]] && { printf '%s\n' "$msg";has notify-send && notify-send "$msg"||:;};}
set_wallpaper(){
  local wallpaper="$1"
  case "${XDG_SESSION_TYPE:-}" in
    wayland) killall -q swaybg||:;swaybg --image "$wallpaper" &;;
    x11) feh --no-fehbg --bg-scale "$wallpaper" &;;
    *) die "Unknown session type: ${XDG_SESSION_TYPE:-none}" 2;;
  esac
}
random_wallpaper(){
  local wallpaper=$(find "$WALLPAPERS_DIR" -type f -not -path '*/.git/*'|shuf -n 1)||{ send_feedback "No file selected";exit 1;}
  [[ -n $wallpaper ]] && { set_wallpaper "$wallpaper";send_feedback "Set random wallpaper.";exit 0;}||{ send_feedback "No file selected";exit 1;}
}
select_wallpaper(){
  local wallpaper=$(find "$WALLPAPERS_DIR" -type f -not -path '*/.git/*' -exec basename {} \;|sed 's/\.\(png\|jpg\|jpeg\)$//'|fzf --prompt "wallpaper: " --header="${FZF_DEFAULT_HEADER:-}")||{ send_feedback "No file selected!";exit 1;}
  [[ -n $wallpaper ]] && { local full_path=$(find "$WALLPAPERS_DIR" -type f -name "*${wallpaper}.*");set_wallpaper "$full_path";send_feedback "Set selected wallpaper";exit 0;}||{ send_feedback "No file selected!";exit 1;}
}
while getopts ":d:hqrs" opt;do
  case "$opt" in
    d) [[ -d $OPTARG ]] && WALLPAPERS_DIR="$OPTARG"||die "Directory not found: $OPTARG" 2;;
    h) sed -n '2,/^$/p' "$0"|sed 's/^# \?//';exit 0;;
    q) QUIET=1;;
    r) random_wallpaper;;
    s) select_wallpaper;;
    \?) die "Invalid option: -$OPTARG" 2;;
    :) die "Option -$OPTARG requires an argument" 2;;
  esac
done
[[ $OPTIND -eq 1 ]] && { sed -n '2,/^$/p' "$0"|sed 's/^# \?//';exit 2;}
[[ ! -d $WALLPAPERS_DIR ]] && die "Directory not found: $WALLPAPERS_DIR" 2
