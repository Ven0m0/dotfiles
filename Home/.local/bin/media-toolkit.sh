#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
set -euo pipefail; shopt -s nullglob globstar
export LC_ALL=C; IFS=$'\n\t'
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
has(){ command -v -- "$1" &>/dev/null; }
# media-toolkit.sh - Optimized media manipulation tools
export HOME="/home/${SUDO_USER:-$USER}"
# Colors
B=$'\e[1;34m' C=$'\e[1;36m' G=$'\e[1;32m' R=$'\e[1;31m' X=$'\e[0m'
log(){ printf '%b==>%b %s\n' "$B" "$X" "$*"; }
ok(){ printf '%b==>%b %s\n' "$G" "$X" "$*"; }
die(){ printf '%b==> ERROR:%b %s\n' "$R" "$X" "$*" >&2; exit "${2:-1}"; }
req(){ has "$1" || die "missing: $1"; }
# Cleanup
cleanup(){ [[ -n ${TMP_DIR:-} ]] && rm -rf "$TMP_DIR"; }
trap cleanup EXIT
# CD/DVD/USB Operations
cd_burn(){
  local t=$1
  req cdrdao
  [[ -f $t ]] || die "not found: $t"
  log "Burning: $t"
  sudo cdrdao write --eject --driver generic-mmc-raw "$t"
  ok "Done"
}
usb_write(){
  local iso=$1 dst=$2 x="${iso##*.}" sz
  for c in dd pv stat; do req "$c"; done
  [[ -f $iso ]] || die "not found: $iso"
  x="${x,,}"
  [[ $x == iso || $x == img ]] || die "need .iso/.img: $iso"
  [[ -b $dst ]] || die "not block device: $dst"
  if grep -q "$dst" /proc/mounts; then die "device mounted: $dst"; fi
  log "WARNING: DESTROY all data on $dst!"
  read -rp "Continue? [y/N] " c
  [[ $c =~ ^[yY]$ ]] || { log "Cancelled"; exit 0; }
  sz=$(stat -c%s "$iso")
  log "Copying $iso ($sz bytes) to $dst..."
  # Optimized block size and sync
  sudo dd if="$iso" bs=4M iflag=fullblock status=none \
    | pv --size "$sz" -pterb \
    | sudo dd of="$dst" bs=4M oflag=sync status=none
  ok "Done"
}
iso2sd(){
  local iso=$1 dst=$2
  [[ -f $iso ]] || die "not found: $iso"
  [[ -b $dst ]] || die "not block: $dst"
  sudo dd bs=4M status=progress oflag=sync if="$iso" of="$dst"
  sudo eject "$dst" || :
}
format_exfat(){
  local dev=$1 nm=$2
  [[ -b $dev ]] || die "not block: $dev"
  log "WARNING: Erasing $dev, label '$nm'"
  read -rp "Continue? [y/N] " c
  [[ $c =~ ^[yY]$ ]] || { log "Cancelled"; exit 0; }
  sudo wipefs -a "$dev"
  # Zero beginning of disk
  sudo dd if=/dev/zero of="$dev" bs=1M count=10 status=none
  sudo parted -s "$dev" mklabel gpt mkpart primary 1MiB 100%
  local p="${dev}1"
  [[ $dev == *nvme* || $dev == *mmcblk* ]] && p="${dev}p1"
  sudo partprobe "$dev" || :
  sudo udevadm settle || :
  sudo mkfs.exfat -n "$nm" "$p"
  log "Formatted: $dev as exFAT '$nm'"
}
rip_dvd(){
  local iso=$1 dvd=/dev/sr0 inf bs vs sz oc cc
  for c in isoinfo dd pv sha1sum; do req "$c"; done
  [[ -b $dvd ]] || die "DVD not found: $dvd"
  log "Reading DVD info..."
  inf=$(isoinfo -d -i "$dvd")
  bs=$(grep -F "Logical block" <<<"$inf" | awk '{print $5}')
  vs=$(grep -F "Volume size" <<<"$inf" | awk '{print $4}')
  [[ -z $bs || -z $vs ]] && die "Failed to read DVD info"
  sz=$((bs * vs))
  log "Creating: $iso ($sz bytes)..."
  sudo dd if="$dvd" bs="$bs" count="$vs" status=none \
    | pv -pterb --size "$sz" \
    | dd of="$iso" bs="$bs" status=none
  log "Verifying checksums..."
  # Calculate checksums (can be slow)
  oc=$(sudo dd if="$dvd" bs="$bs" count="$vs" status=none | sha1sum | awk '{print $1}')
  cc=$(sha1sum "$iso" | awk '{print $1}')
  log "Original: $oc"
  log "Copy:     $cc"
  [[ $oc == "$cc" ]] || die "Checksum mismatch!"
  ok "Ripped successfully: $iso"
}
# Image Operations
# Exported worker for xargs parallelism
export_png_worker(){
  # Args: file gray touch verb dpi
  local f=$1 gray=$2 touch=$3 verb=$4 dpi=$5
  local tmp_pq="${f}.pq.$$" tmp_cr="${f}.cr.$$"
  local size_orig size_new
  size_orig=$(stat -c%s "$f")
  # 1. pngquant
  local opts=("--force" "--skip-if-larger" "--speed" "1")
  ((gray)) && opts+=("--grayscale")
  if pngquant --quality=70-95 --strip "${opts[@]}" --output "$tmp_pq" "$f" &>/dev/null; then
    if [[ -s $tmp_pq ]]; then
      mv "$tmp_pq" "$f"
    else
      rm -f "$tmp_pq"
    fi
  fi
  # 2. oxipng
  oxipng -o max --strip all --alpha --zopfli --fix --quiet "$f" &>/dev/null || :
  # 3. pngcrush (optional DPI)
  if ((dpi > 0)); then
    if pngcrush -brute -l9 -res "$dpi" -q "$f" "$tmp_cr" &>/dev/null; then
      if [[ -s $tmp_cr ]] && (($(stat -c%s "$tmp_cr") < $(stat -c%s "$f"))); then
        mv "$tmp_cr" "$f"
      fi
      rm -f "$tmp_cr"
    fi
  fi
  # Timestamp restoration
  ((touch)) && touch -r "$f" "$f" 2>/dev/null || :
  size_new=$(stat -c%s "$f")
  ((verb)) && printf "%s: %d -> %d bytes\n" "$f" "$size_orig" "$size_new"
}
export -f export_png_worker
pngzip(){
  local gray=0 touch=0 verb=1 dpi=0 opt
  while getopts ":gqtr:h" opt; do
    case $opt in
      g) gray=1 ;;
      q) verb=0 ;;
      t) touch=1 ;;
      r) dpi=${OPTARG//[^0-9]/} ;;
      h) usage; exit 0 ;;
      *) die "Invalid: -$OPTARG" ;;
    esac
  done
  shift $((OPTIND - 1))
  req pngquant; req oxipng
  ((dpi > 0)) && req pngcrush
  local search_paths=("${@:-.}") jobs=$(nproc)
  # Find files safely
  if has fd; then
    fd -t f -e png -0 . "${search_paths[@]}"
  else
    find "${search_paths[@]}" -type f -name '*.png' -print0
  fi | xargs -0 -P "$jobs" -I {} bash -c 'export_png_worker "$@"' _ {} "$gray" "$touch" "$verb" "$dpi"
}
export_webp_worker(){
  local f=$1 out=$2 ll=$3 q=$4 z=$5 force=$6
  if [[ -e $out && $force == "false" ]]; then
    return 0
  fi
  local opts=("-mt" "-quiet" "-m" "6")
  if [[ $ll == "true" ]]; then
    opts+=("-lossless" "-z" "$z")
  else
    opts+=("-q" "$q")
  fi
  if cwebp "${opts[@]}" "$f" -o "$out" &>/dev/null; then
    printf '%b->%b %s\n' "$G" "$X" "$out"
  else
    printf '%bERR%b %s\n' "$R" "$X" "$f" >&2
  fi
}
export -f export_webp_worker
towebp(){
  req cwebp
  local ll=true q=85 z=9 force=false opt
  while getopts ":lq:z:fh" opt; do
    case $opt in
      l) ll=true ;;
      q) q=${OPTARG//[^0-9]/} ;;
      z) z=${OPTARG//[^0-9]/} ;;
      f) force=true ;;
      h) usage; exit 0 ;;
      *) die "Invalid: -$OPTARG" ;;
    esac
  done
  shift $((OPTIND - 1))
  local root=${1:-.} jobs=$(nproc)
  if has fd; then
    fd -t f -e png -e jpg -e jpeg -E '*.webp' -0 . "$root"
  else
    find "$root" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) ! -iname '*.webp' -print0
  fi | xargs -0 -P "$jobs" -I {} bash -c 'export_webp_worker "$1" "${1%.*}.webp" "$2" "$3" "$4" "$5"' _ {} "$ll" "$q" "$z" "$force"
}
# Video & Image Magick Wrappers
vid1080(){
  local v=$1
  req ffmpeg
  ffmpeg -y -i "$v" -vf "scale=1920:1080" -c:v libx264 -preset fast -crf 23 -c:a copy "${v%.*}-1080p.mp4"
}
vid4k(){
  local v=$1
  req ffmpeg
  ffmpeg -y -i "$v" -c:v libx265 -preset medium -crf 24 -c:a aac -b:a 192k "${v%.*}-4k.mp4"
}
jpg_opt(){
  local i=$1; shift
  req magick
  magick "$i" "$@" -quality 85 -strip -interlace Plane -gaussian-blur 0.05 "${i%.*}-opt.jpg"
}
jpg_small(){
  local i=$1; shift
  req magick
  magick "$i" "$@" -resize "1080x>" -quality 80 -strip "${i%.*}-small.jpg"
}
png_opt(){
  local i=$1; shift
  req magick
  magick "$i" "$@" -strip -quality 95 "${i%.*}-opt.png"
}
usage(){
  cat <<'EOF'
media - Optimized Media Toolkit
USAGE: media COMMAND [ARGS...]

COMMANDS:
  cd <toc>              Burn audio CD
  usb <iso> <dev>       Write ISO to USB (Safe)
  iso2sd <iso> <dev>    Write ISO to SD
  format <dev> <label>  Format as exFAT
  ripdvd <iso>          Rip DVD to ISO
  pngzip [opts] [path]  Optimize PNGs (Parallel)
  towebp [opts] [path]  Convert to WebP (Parallel)
  vid1080 <video>       Transcode to 1080p/x264
  vid4k <video>         Transcode to 4K/x265
  jpg <img> [opts]      Convert/Optimize JPG
  jpgsmall <img> [opts] Resize to 1080p JPG
  png <img> [opts]      Convert to PNG

FLAGS:
  pngzip: -g (Gray) -q (Quiet) -t (Touch) -r DPI
  towebp: -l (Lossless) -q N (Qual) -z N (Comp) -f (Force)
EOF
}
main(){
  [[ $# -eq 0 || ${1:-} == "-h" || ${1:-} == "--help" ]] && { usage; exit 0; }
  local cmd=$1; shift
  case $cmd in
    cd)       [[ $# -eq 1 ]] || die "usage: cd <toc>"; cd_burn "$@" ;;
    usb)      [[ $# -eq 2 ]] || die "usage: usb <iso> <dev>"; usb_write "$@" ;;
    iso2sd)   [[ $# -eq 2 ]] || die "usage: iso2sd <iso> <dev>"; iso2sd "$@" ;;
    format)   [[ $# -eq 2 ]] || die "usage: format <dev> <label>"; format_exfat "$@" ;;
    ripdvd)   [[ $# -eq 1 ]] || die "usage: ripdvd <iso>"; rip_dvd "$@" ;;
    pngzip)   pngzip "$@" ;;
    towebp)   towebp "$@" ;;
    vid1080)  [[ $# -eq 1 ]] || die "usage: vid1080 <video>"; vid1080 "$@" ;;
    vid4k)    [[ $# -eq 1 ]] || die "usage: vid4k <video>"; vid4k "$@" ;;
    jpg)      [[ $# -ge 1 ]] || die "usage: jpg <img>"; jpg_opt "$@" ;;
    jpgsmall) [[ $# -ge 1 ]] || die "usage: jpgsmall <img>"; jpg_small "$@" ;;
    png)      [[ $# -ge 1 ]] || die "usage: png <img>"; png_opt "$@" ;;
    *)        die "Unknown command: $cmd" ;;
  esac
}
main "$@"
