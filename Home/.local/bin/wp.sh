#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
# shellcheck source=../lib/bash-common.sh
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s
source "${s%/bin/*}/lib/bash-common.sh"
init_strict
shopt -s extglob
cd -P -- "${s%/*}"
WALLPAPERS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers"
mkdir -p "$WALLPAPERS_DIR"
QUIET=""
send_feedback(){
  local msg="$1"
  if [[ -z $QUIET ]]; then
    printf '%s\n' "$msg"
    if command -v notify-send &>/dev/null; then
      notify-send "$msg"
    fi
  fi
}
set_wallpaper(){
  local wallpaper="$1"
  case "${XDG_SESSION_TYPE:-}" in
    wayland) killall -q swaybg || :; swaybg --image "$wallpaper" & ;;
    x11) feh --no-fehbg --bg-scale "$wallpaper" & ;;
    *) die "Unknown session type: ${XDG_SESSION_TYPE:-none}" 2 ;;
  esac
}
random_wallpaper(){
  local -a wallpapers=()
  mapfile -d '' -t wallpapers < <(find "$WALLPAPERS_DIR" -type f -not -path '*/.git/*' -print0)
  if ((${#wallpapers[@]} == 0)); then
    send_feedback "No file selected"
    exit 1
  fi
  local wallpaper="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
  set_wallpaper "$wallpaper"
  send_feedback "Set random wallpaper."
  exit 0
}
select_wallpaper(){
  local -a wallpapers=()
  mapfile -d '' -t wallpapers < <(find "$WALLPAPERS_DIR" -type f -not -path '*/.git/*' -print0)
  if ((${#wallpapers[@]} == 0)); then
    send_feedback "No file selected!"
    exit 1
  fi
  local -a names=()
  for path in "${wallpapers[@]}"; do
    local base="${path##*/}"
    names+=("${base%.*}")
  done
  local wallpaper
  wallpaper=$(printf '%s\n' "${names[@]}" | fzf --prompt "wallpaper: " --header="${FZF_DEFAULT_HEADER:-}") || { send_feedback "No file selected!"; exit 1; }
  if [[ -z $wallpaper ]]; then
    send_feedback "No file selected!"
    exit 1
  fi
  local full_path=""
  for path in "${wallpapers[@]}"; do
    local base="${path##*/}"
    base="${base%.*}"
    if [[ $base == "$wallpaper" ]]; then
      full_path="$path"
      break
    fi
  done
  if [[ -z $full_path ]]; then
    send_feedback "No file selected!"
    exit 1
  fi
  set_wallpaper "$full_path"
  send_feedback "Set selected wallpaper"
  exit 0
}
while getopts ":d:hqrs" opt; do
  case "$opt" in
    d)
      if [[ -d $OPTARG ]]; then
        WALLPAPERS_DIR="$OPTARG"
      else
        die "Directory not found: $OPTARG" 2
      fi
      ;;
    h) sed -n '2,/^$/p' "$0"|sed 's/^# \?//'; exit 0 ;;
    q) QUIET=1 ;;
    r) random_wallpaper ;;
    s) select_wallpaper ;;
    \?) die "Invalid option: -$OPTARG" 2 ;;
    :) die "Option -$OPTARG requires an argument" 2 ;;
    *) ;;
  esac
done
[[ $OPTIND -eq 1 ]] && { sed -n '2,/^$/p' "$0"|sed 's/^# \?//'; exit 2; }
[[ ! -d $WALLPAPERS_DIR ]] && die "Directory not found: $WALLPAPERS_DIR" 2
