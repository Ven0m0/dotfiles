#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar; IFS=$'\n\t'
export LC_ALL=C LANG=C HOME="/home/${SUDO_USER:-$USER}"
# media-opt.sh - Batch media optimization with AV1/WebP support
# Optimized for performance using xargs -P and fd
# Config
: "${JOBS:=$(nproc 2>/dev/null || echo 4)}"
: "${DRY:=0}"
: "${BACKUP:=0}"
: "${MTIME:=1}"
: "${BACKUP_DIR:=${HOME}/.cache/media-opt/$(date +%Y%m%d_%H%M%S)}"
: "${LOSSLESS:=1}"
: "${QUAL:=95}"
: "${VCRF:=28}"
: "${VCODEC:=libsvtav1}"
# Colors
R=$'\e[31m' G=$'\e[32m' Y=$'\e[33m' B=$'\e[34m' X=$'\e[0m'
# Helpers
log(){ printf "${B}[%s]${X} %s\n" "$(date +%T)" "$*"; }
err(){ printf "${R}[ERR]${X} %s\n" "$*" >&2; }
die(){ err "$@"; exit 1; }
has(){ command -v "$1" &>/dev/null; }
# Tool Capability Cache
declare -A TC
cache_tools(){
  local t
  for t in rimage jpegoptim oxipng cwebp gifsicle ffmpeg; do
    has "$t" && TC[$t]=1 || TC[$t]=0
  done
}
hc(){ [[ ${TC[$1]:-0} -eq 1 ]]; }
# Worker Function (Exported)
opt_img(){
  local f=$1 o=$2 t c=() x="${f##*.}" lx="${x,,}"
  if hc rimage; then
    t="rimage"; cp "$f" "$o"
    # rimage handles jpg/png/webp
    [[ $LOSSLESS -eq 1 ]] && c=(rimage "$o" -q 100) || c=(rimage "$o" -q "$QUAL")
  else
    case "$lx" in
      jpg|jpeg|mjpg)
        if hc jpegoptim; then
          t="jpegoptim"; c=(jpegoptim --strip-all --all-progressive --stdout "$f")
          [[ $LOSSLESS -eq 0 ]] && c+=(-m"$QUAL")
        fi ;;
      png)
        if hc oxipng; then
          t="oxipng"; c=(oxipng -o 7 --strip safe -i 0 --out - "$f")
        fi ;;
      webp)
        if hc cwebp; then
          t="cwebp"; c=(cwebp -mt -quiet "$f" -o -)
          [[ $LOSSLESS -eq 1 ]] && c+=(-lossless -z 9) || c+=(-q "$QUAL" -m 6)
        fi ;;
    esac
  fi
  [[ -n $t ]] && printf '%s:%s\n' "$t" "${c[*]}"
}
opt_vid(){
  local f=$1 o=$2 t="ffmpeg" c=() va=()
  hc ffmpeg || return 0
  case "$VCODEC" in
    libsvtav1) [[ $LOSSLESS -eq 1 ]] && va=(-preset 6 -crf "$VCRF" -svtav1-params tune=0:scd=1) || va=(-preset 8 -crf $((VCRF + 6))) ;;
    libaom-av1) [[ $LOSSLESS -eq 1 ]] && va=(-cpu-used 4 -crf "$VCRF" -b:v 0) || va=(-cpu-used 6 -crf $((VCRF + 6)) -b:v 0) ;;
    libx265) [[ $LOSSLESS -eq 1 ]] && va=(-preset slow -crf "$VCRF") || va=(-preset medium -crf $((VCRF + 4))) ;;
    libvpx-vp9) va=(-b:v 0 -crf $((VCRF + 8)) -cpu-used 3 -row-mt 1) ;;
  esac
  c=(ffmpeg -y -v error -i "$f" -c:v "$VCODEC" "${va[@]}" -c:a libopus -b:a 128k -movflags +faststart "$o")
  printf '%s:%s\n' "$t" "${c[*]}"
}
optimize_worker(){
  local f=$1
  [[ ! -f $f ]] && return 0
  local x="${f##*.}" lx="${x,,}" tmp="${f}.tmp.${x}" res t c=()
  # Dispatcher
  case "$lx" in
    jpg|jpeg|mjpg|png|webp|avif|jxl|bmp) res=$(opt_img "$f" "$tmp") ;;
    gif)
      if hc gifsicle; then
        t="gifsicle"
        [[ $LOSSLESS -eq 1 ]] && c=(gifsicle "$f" -O3 --careful) || c=(gifsicle "$f" -O3 --lossy=80)
        res="${t}:${c[*]}"
      fi ;;
    mp4|mkv|mov|avi|webm) res=$(opt_vid "$f" "$tmp") ;;
    svg)
      if hc cwebp; then
        t="cwebp"; c=(cwebp -mt -quiet "$f" -o -)
        res="${t}:${c[*]}"
      fi ;;
    *) return 0 ;;
  esac
  [[ -z $res ]] && { [[ -f $tmp ]] && rm -f "$tmp"; return 0; }
  t="${res%%:*}"
  local cmdstr="${res#*:}"
  read -ra c <<< "$cmdstr"
  if [[ $DRY -eq 1 ]]; then
    printf "${B}[DRY]${X} %-10s %s\n" "$t" "$f"
    [[ -f $tmp ]] && rm -f "$tmp"
    return 0
  fi
  # Execute optimization
  local ok=0
  if [[ $t =~ ^(oxipng|cwebp|jpegoptim)$ ]] && [[ ${c[*]} =~ (--stdout|--out.*-|-o.*-) ]]; then
    "${c[@]}" >"$tmp" 2>/dev/null && ok=1
  else
    "${c[@]}" &>/dev/null && ok=1
  fi
  # Compare & Replace
  if [[ $ok -eq 1 && -s $tmp ]]; then
    local os=$(stat -c%s "$f") ns=$(stat -c%s "$tmp") d p
    if [[ $os -gt 0 && $ns -lt $os ]]; then
      d=$((os - ns)); p=$((d * 100 / os))
      if [[ $BACKUP -eq 1 ]]; then
        local bp="${BACKUP_DIR}/${f#.}"
        mkdir -p "$(dirname "$bp")"
        cp -p "$f" "$bp"
      fi
      mv "$tmp" "$f"
      [[ $MTIME -eq 1 ]] && touch -r "$f" "$f"
      # Use printf directly to avoid race conditions with log function
      printf "${G}[OK]${X} %-10s -%d%% (%s) %s\n" "[$t]" "$p" "$(numfmt --to=iec "$d")" "$(basename "$f")"
    else
      rm -f "$tmp"
    fi
  else
    [[ -f $tmp ]] && rm -f "$tmp"
  fi
}
export -f optimize_worker opt_img opt_vid hc
export TC LOSSLESS QUAL VCRF VCODEC DRY BACKUP BACKUP_DIR MTIME B G Y R X
# Interactive Mode
interactive(){
  has ffmpeg || die "ffmpeg required"
  local inp
  while :; do
    printf '\033c' # Clear screen
    log "Media Conversion Tool"
    read -rp "Input file (q=quit): " inp
    [[ $inp == q ]] && break
    # Strip quotes
    inp="${inp//\'/}"; inp="${inp%\"}"; inp="${inp#\"}"
    [[ -f $inp ]] || { err "File not found"; sleep 1; continue; }
    local fn="${inp##*/}" ext="${fn##*.}" lext="${ext,,}" cext="" vf=()
    local tgts=("mkv" "mp4" "webm" "webp" "gif" "avif")
    PS3=$'\n'"${B}Convert ${fn} to?${X} "
    select ch in "${tgts[@]}" "Back"; do
      case "$ch" in
        Back) break ;;
        "") err "Invalid"; continue ;;
        *) cext=$ch; break ;;
      esac
    done
    [[ $ch == Back ]] && continue
    # Filters
    local opts=("Scale 50%" "Scale 75%" "Width 1920" "Width 1280" "Rot 90 CW" "Done")
    while :; do
      printf "${Y}Filters: %s${X}\n" "${vf[*]:-(none)}"
      PS3=$'\n'"${B}Add filter?${X} "
      select o in "${opts[@]}"; do
        case "$o" in
          "Scale 50%") vf+=(scale=iw/2:-2) ;;
          "Scale 75%") vf+=(scale=iw*0.75:-2) ;;
          "Width 1920") vf+=(scale=1920:-2) ;;
          "Width 1280") vf+=(scale=1280:-2) ;;
          "Rot 90 CW") vf+=(transpose=1) ;;
          Done) break 2 ;;
          *) err "Invalid" ;;
        esac; break
      done
    done
    local od="${inp%/*}" of="${od}/${fn%.*}-opt.${cext}" vff
    IFS=, vff="${vf[*]}"
    local cmd=(ffmpeg -y -hide_banner -v error -stats -i "$inp")
    [[ -n $vff ]] && cmd+=(-vf "$vff")
    # Smart codec defaults
    case "$cext" in
      mp4) cmd+=(-c:v libx264 -preset slow -crf 23 -c:a aac -b:a 128k) ;;
      webm) cmd+=(-c:v libvpx-vp9 -b:v 0 -crf 30 -cpu-used 3 -c:a libopus) ;;
      gif) 
        # High quality GIF palette gen
        local pal="${od}/pal.png"
        ffmpeg -y -i "$inp" -vf "${vff:+$vff,}palettegen" "$pal" &>/dev/null
        cmd=(-i "$pal" -lavfi "${vff:+$vff,}paletteuse")
        # Reset cmd structure for complex filter
        cmd=(ffmpeg -y -hide_banner -v error -i "$inp" -i "$pal" -lavfi "${vff:+$vff}[x];[x][1:v]paletteuse" -f gif) ;;
    esac
    cmd+=("$of")
    log "Processing..."
    "${cmd[@]}" && log "Saved: $of" || err "Conversion failed"
    [[ -f ${pal:-} ]] && rm -f "$pal"
    read -rp "Press ENTER..."
  done
}
batch(){
  local dir=${1:-.}
  # Safe NUL-delimited file finding
  if has fd; then
    fd -t f -0 -e jpg -e jpeg -e png -e webp -e gif -e avif -e mp4 -e mkv -e mov . "$dir"
  else
    find "$dir" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.mp4" -o -iname "*.mkv" \) -print0
  fi | xargs -0 -P "$JOBS" -I {} bash -c 'optimize_worker "$@"' _ {}
}
usage(){
  cat <<EOF
media-opt.sh - Batch media optimization
USAGE: media-opt.sh [OPTIONS] [PATH...]
OPTIONS:
  -j N          Jobs (default: $(nproc))
  -l            Lossy mode (default: lossless)
  -q N          Quality 1-100 (default: 95)
  --crf N       Video CRF (default: 24)
  --vcodec C    Video codec (libsvtav1, libx265, libvpx-vp9)
  -i            Interactive conversion
  --backup      Enable backups
  --dry-run     Simulate
EOF
}
main(){
  local inputs=()
  while [[ $# -gt 0 ]]; do
    case $1 in
      -i|--interactive) interactive; exit 0 ;;
      -j|--jobs) JOBS=$2; shift 2 ;;
      -l|--lossy) LOSSLESS=0; shift ;;
      -q|--quality) QUAL=$2; shift 2 ;;
      --crf) VCRF=$2; shift 2 ;;
      --vcodec) VCODEC=$2; shift 2 ;;
      --backup) BACKUP=1; shift ;;
      --dry-run) DRY=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) inputs+=("$1"); shift ;;
    esac
  done
  [[ ${#inputs[@]} -eq 0 ]] && inputs=(.)
  if [[ $BACKUP -eq 1 ]]; then
    mkdir -p "$BACKUP_DIR"
    log "Backups: $BACKUP_DIR"
  fi
  cache_tools
  log "Optimizing ($JOBS threads, $VCODEC)..."
  for i in "${inputs[@]}"; do
    batch "$i"
  done
  log "Done."
}

main "$@"
