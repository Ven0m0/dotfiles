#!/usr/bin/env bash
# media-toolkit.sh - Optimized media manipulation tools
set -euo pipefail; shopt -s nullglob globstar; IFS=$'\n\t'
export HOME="/home/${SUDO_USER:-$USER}" LC_ALL=C

# --- Helpers ---
B=$'\e[1;34m' G=$'\e[1;32m' R=$'\e[1;31m' X=$'\e[0m'
log() { printf '%b==>%b %s\n' "$B" "$X" "$*"; }
die() { printf '%bERROR:%b %s\n' "$R" "$X" "$*" >&2; exit "${2:-1}"; }
req() { command -v "$1" >/dev/null || die "missing: $1"; }
cleanup() { [[ -n ${TMP_DIR:-} ]] && rm -rf "$TMP_DIR"; }; trap cleanup EXIT

# --- Commands ---
cmd_cd() {
  req cdrdao; local iso=$1
  [[ -f $iso ]] || die "No ISO found: $iso"
  log "Burning $iso..."; sudo cdrdao write --eject --driver generic-mmc-raw "$iso"
}

cmd_usb() {
  req dd; local iso=$1 dev=$2
  [[ -f $iso && -b $dev ]] || die "Usage: usb <iso> <dev>"
  log "Flashing $iso to $dev..."; sudo dd if="$iso" of="$dev" bs=4M status=progress oflag=sync
}

cmd_format() {
  req mkfs.exfat; local dev=$1 label=$2
  [[ -b $dev ]] || die "Invalid device: $dev"
  log "Formatting $dev ($label)..."; sudo mkfs.exfat -n "$label" "$dev"
}

cmd_ripdvd() {
  req dd; local iso=${1:-dvd.iso}
  log "Ripping /dev/sr0 to $iso..."; sudo dd if=/dev/sr0 of="$iso" bs=2048 status=progress
}

cmd_pngzip() {
  req pngquant; local opts=()
  while getopts "gqtr:" opt; do
    case $opt in g) opts+=("--grayscale");; q) opts+=("--quiet");; r) opts+=("--posterize" "$OPTARG");; esac
  done
  shift $((OPTIND-1)); local path="${1:-.}"
  log "Optimizing PNGs in $path (Jobs: $(nproc))..."
  find "$path" -type f -name "*.png" -print0 | xargs -0 -r -P$(nproc) -n 16 pngquant "${opts[@]}" --ext .png --force
}

cmd_towebp() {
  req cwebp; local q=80 m=4 opts=()
  while getopts "lq:z:f" opt; do
    case $opt in l) opts+=("-lossless");; q) q=$OPTARG;; z) m=$OPTARG;; f) opts+=("-f");; esac
  done
  shift $((OPTIND-1)); local path="${1:-.}"
  log "Converting to WebP in $path (Jobs: $(nproc))..."

  local cwebp_cmd="cwebp -q $q -m $m"
  for opt in "${opts[@]}"; do cwebp_cmd="$cwebp_cmd $opt"; done
  export cwebp_cmd

  find "$path" -type f \( -iname "*.jpg" -o -iname "*.png" \) -print0 | \
    xargs -0 -r -P$(nproc) -n 16 bash -c '
      for file; do
        $cwebp_cmd "$file" -o "${file%.*}.webp"
      done
    ' _
}

cmd_vid() {
  req ffmpeg; local mode=$1 file=$2 opts
  [[ -f $file ]] || die "No file: $file"
  case $mode in
    1080) opts="-c:v libx264 -preset medium -crf 23 -c:a copy" ;;
    4k)   opts="-c:v libx265 -preset medium -crf 28 -c:a copy" ;;
  esac
  log "Transcoding $file to $mode..."; ffmpeg -i "$file" $opts "${file%.*}_${mode}.mp4"
}

cmd_img() {
  req convert; local mode=$1 img=$2; shift 2
  [[ -f $img ]] || die "No image: $img"
  case $mode in
    jpg)      convert "$img" -quality 85 "${img%.*}.jpg" ;;
    jpgsmall) convert "$img" -resize 1920x1080 -quality 85 "${img%.*}.jpg" ;;
    png)      convert "$img" "${img%.*}.png" ;;
  esac
}

usage() {
  cat <<EOF
media-toolkit - Media Ops
Usage: ${0##*/} [COMMAND] [ARGS]
Commands:
  cd <iso>              Burn ISO to CD
  usb <iso> <dev>       Flash ISO to USB (alias: iso2sd)
  format <dev> <label>  Format device to ExFAT
  ripdvd [iso]          Rip DVD to ISO
  pngzip [opts] [path]  Optimize PNGs (Parallel)
  towebp [opts] [path]  Convert to WebP (Parallel)
  vid1080/vid4k <file>  Transcode Video
  jpg/png/small <img>   Image conversion
EOF
  exit 1
}

# --- Main ---
[[ $# -eq 0 ]] && usage
case $1 in
  cd)        shift; cmd_cd "$@" ;;
  usb|iso2sd) shift; cmd_usb "$@" ;;
  format)    shift; cmd_format "$@" ;;
  ripdvd)    shift; cmd_ripdvd "$@" ;;
  pngzip)    shift; cmd_pngzip "$@" ;;
  towebp)    shift; cmd_towebp "$@" ;;
  vid1080)   shift; cmd_vid "1080" "$@" ;;
  vid4k)     shift; cmd_vid "4k" "$@" ;;
  jpg|jpgsmall|png) M=$1; shift; cmd_img "$M" "$@" ;;
  *) usage ;;
esac
