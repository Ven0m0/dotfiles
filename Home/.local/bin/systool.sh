#!/usr/bin/env bash
set -euo pipefail;shopt -s nullglob globstar extglob;IFS=$'\n\t';LC_ALL=C;LANG=C
has(){ command -v "$1" &>/dev/null;}
die(){ printf '%b[ERROR]%b %s\n' '\e[1;31m' '\e[0m' "$*" >&2;exit "${2:-1}";}
warn(){ printf '%b[WARN]%b %s\n' '\e[1;33m' '\e[0m' "$*" >&2;}
log(){ printf '%b[INFO]%b %s\n' '\e[1;34m' '\e[0m' "$*";}
SUDO="";((EUID!=0)) && has sudo && SUDO=sudo
usage(){ printf 'sysmaint: ln2 swap symclean usb sysz prsync\n';}
ln2_usage(){ printf 'Usage: sysmaint ln2 [opts] LINK > TARGET | TARGET < LINK\n';}
ln2_cmd(){
  local -a a=("$@")
  ((${#a[@]}>=3))||{ ln2_usage;return 2;}
  [[ " ${a[*]} " =~ \ -h\  || " ${a[*]} " =~ \ --help\  ]] && { ln2_usage;return 0;}
  local op1 op op2;op2=${a[-1]};op=${a[-2]};op1=${a[-3]};a=("${a[@]:0:${#a[@]}-3}")
  [[ $op1 == -* ]] && { ln2_usage;return 2;}
  local tgt link
  case "$op" in '>') tgt=$op2;link=$op1;;'<') tgt=$op1;link=$op2;;*) ln2_usage;return 2;;esac
  ln "${a[@]}" -- "$tgt" "$link"
}
swap_usage(){ printf 'Usage: sysmaint swap A B\n';}
swap_cmd(){
  (($#==2))||{ swap_usage;return 2;}
  local file_a="$1" file_b="$2" tmp
  [[ -d $file_a ]] && { tmp="tmp.$$.dir";mkdir -p "$tmp";}||tmp="$(mktemp)"
  mv -- "$file_a" "$tmp" && mv -- "$file_b" "$file_a" && mv -- "$tmp" "$file_b"
}
symclean_usage(){ printf 'Usage: sysmaint symclean [DIR]\n';}
symclean_cmd(){ local d="${1:-$PWD}";[[ -d $d ]]||die "not dir: $d";log "cleaning broken symlinks in $d";find "$d" -xtype l -print -delete 2>/dev/null||find -L "$d" -type l -print -delete 2>/dev/null||:;}
usb_usage(){ printf 'Usage: sysmaint usb [-n COUNT] [-s START] [-b BASE]\n';}
usb_cmd(){
  local cnt=4 start="b" base="/mnt/usbstick"
  while (($#));do case "$1" in -n) cnt="$2";shift 2;;-s) start="$2";shift 2;;-b) base="${2%/}";shift 2;;-h|--help) usb_usage;return 0;;*) break;;esac;done
  has lsblk||die "lsblk required"
  local -a names uuids fss labels mpts lines
  mapfile -t lines < <(lsblk -pn -o NAME,UUID,FSTYPE,LABEL,MOUNTPOINT|awk -v s="$start" '/^\/dev\/sd[a-z][0-9]/{dev=substr($1,9,1);if(dev>=s){name=$1;uuid=$2;fs=$3;label=$4;mp=$5;printf"%s\t%s\t%s\t%s\t%s\n",name,(uuid?uuid:""),(fs?fs:""),(label?label:""),(mp?mp:"")}}')
  ((${#lines[@]}))||{ log "no new device";return 0;}
  log "Mount/Umount tool";local i=0
  for line in "${lines[@]}";do IFS=$'\t' read -r names[i] uuids[i] fss[i] labels[i] mpts[i] <<<"$line";printf ' %2d) %s %s [%s]%s\n' "$((i+1))" "${uuids[i]:-—}" "${fss[i]:-—}" "${labels[i]:-—}" "$([[ -n ${mpts[i]} ]] && printf ' -> %s' "${mpts[i]}")";((i++));done
  printf '  q) quit\n';local pick="";has fzf && pick="$(printf '%s\n' "$(seq 1 "${#lines[@]}")" q|fzf --prompt='Choose: ' --height=15 --no-info||:)"
  [[ -z $pick ]] && { read -r -p "Choose [1-${#lines[@]}/q]: " pick||:;}
  [[ $pick =~ ^[Qq]$ ]] && { log exit;return 0;}
  [[ $pick =~ ^[0-9]+$ ]]||{ warn invalid;return 1;}
  ((pick>=1 && pick<=${#lines[@]}))||{ warn range;return 1;}
  local idx=$((pick-1)) uuid="${uuids[idx]}" mp="${mpts[idx]}"
  if [[ -z $mp ]];then
    local k free="";for ((k=1;k<=cnt;k++));do local candidate="${base}${k}" used=0;for mp in "${mpts[@]}";do [[ $mp == "$candidate" ]] && { used=1;break;};done;((used==0)) && { free="$candidate";break;};done
    [[ -z $free ]] && die "increase -n"
    "$SUDO" mkdir -p "$free"||:;"$SUDO" mount -o gid=users,fmask=113,dmask=002 -U "$uuid" "$free";log "mounted $uuid at $free"
  else "$SUDO" umount -- "$mp";log "unmounted $uuid [$mp]";fi
}
