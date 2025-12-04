#!/usr/bin/env bash
# Media toolkit: CD burning, USB creation, transcoding, and image optimization

set -euo pipefail
IFS=$'\n\t'

# ANSI colors
BLD=$'\e[1m' BLU=$'\e[34m' CYN=$'\e[36m' RED=$'\e[31m' DEF=$'\e[0m'

# Helper functions
has(){ command -v "$1" &>/dev/null; }
log(){ printf '%b==>\e[0m %s\n' "${BLD}${BLU}" "$*"; }
info(){ printf '%b==>\e[0m %s\n' "${BLD}${CYN}" "$*"; }
die(){ printf '%b==> ERROR:\e[0m %s\n' "${BLD}${RED}" "$*" >&2; exit "${2:-1}"; }
need(){ has "$1" || die "Required command not found: $1"; }

usage(){
  cat << 'EOF'
media - Media toolkit for CD burning, USB creation, and transcoding

USAGE:
  media COMMAND [ARGS...]

COMMANDS:
  cd          Burn audio CD image to disk
  usb         Copy ISO/IMG to USB device with progress
  compress    Compress directory to tar.gz
  decompress  Extract tar.gz archive
  iso2sd      Write ISO to SD card
  format      Format drive as exFAT
  ripdvd      Create ISO from DVD
  pngzip      Compress PNG files (pngquant + oxipng)
  vid1080     Transcode video to 1080p
  vid4k       Transcode video to 4K
  jpg         Convert image to optimized JPG
  jpgsmall    Convert image to smaller JPG (1080px max)
  png         Convert image to compressed PNG

OPTIONS:
  -h, --help  Show this help message

EXAMPLES:
  media cd audio.toc
  media usb ubuntu.iso /dev/sdc
  media ripdvd movie.iso
  media pngzip -g -r 72 images/
  media jpg wallpaper.png
  media vid1080 video.mp4

PNGZIP OPTIONS:
  -g          Convert to grayscale
  -q          Quiet mode
  -t          Preserve timestamps
  -r DPI      Set DPI resolution
EOF
}

cmd_cd(){
  local toc="$1"
  need cdrdao
  [[ -f $toc ]] || die "TOC file not found: $toc"
  printf 'Burning CD from: %s\n' "$toc"
  sudo cdrdao write --eject --driver generic-mmc-raw "$toc"
  printf '✓ CD burned successfully\n'
}

cmd_usb(){
  local iso="$1" dst="$2" size
  for cmd in dd pv stat; do need "$cmd"; done
  [[ -f $iso ]] || die "File not found: $iso"
  local ext="${iso##*.}"
  ext="${ext,,}"
  [[ $ext == iso || $ext == img ]] || die "Expected .iso or .img: $iso"
  [[ -b $dst ]] || die "Not a block device: $dst"
  grep -q "$dst" /proc/mounts && die "Device mounted. Unmount first: $dst"
  log "⚠️  WARNING: This will DESTROY all data on $dst!"
  read -rp "Continue? [y/N] " confirm
  [[ $confirm == [yY] ]] || {
    info "Cancelled"
    exit 0
  }
  size=$(stat -c '%s' "$iso")
  log "Copying $iso (${size} bytes) to $dst..."
  dd if="$iso" bs=4M status=none | pv --size "$size" -pterb | sudo dd of="$dst" bs=4M status=none conv=fsync
  sync
  log "✓ Copy completed!"
}

cmd_compress(){ tar -czf "${1%/}.tar.gz" "${1%/}"; }
cmd_decompress(){ tar -xzf "$1"; }

cmd_iso2sd(){
  local iso="$1" dst="$2"
  [[ -f $iso ]] || die "File not found: $iso"
  [[ -b $dst ]] || die "Not a block device: $dst"
  sudo dd bs=4M status=progress oflag=sync if="$iso" of="$dst"
  sudo eject "$dst" || :
}

cmd_format(){
  local dev="$1" name="$2"
  [[ -b $dev ]] || die "Not a block device: $dev"
  log "⚠️  WARNING: Erasing all data on $dev, label '$name'"
  read -rp "Continue? [y/N] " confirm
  [[ $confirm == [yY] ]] || {
    info "Cancelled"
    exit 0
  }
  sudo wipefs -a "$dev"
  sudo dd if=/dev/zero of="$dev" bs=1M count=100 status=progress
  sudo parted -s "$dev" mklabel gpt mkpart primary 1MiB 100%
  local part="$([[ $dev == *nvme* ]] && echo "${dev}p1" || echo "${dev}1")"
  sudo partprobe "$dev" || :
  sudo udevadm settle || :
  sudo mkfs.exfat -n "$name" "$part"
  info "Drive $dev formatted as exFAT, labeled '$name'"
}

cmd_ripdvd(){
  local iso="$1" dvd="/dev/sr0"
  for cmd in isoinfo dd pv sha1sum; do need "$cmd"; done
  [[ -b $dvd ]] || die "DVD device not found: $dvd"
  log "Reading DVD info..."
  local dvd_info block_size volume_size total_size
  dvd_info=$(isoinfo -d -i "$dvd")
  block_size=$(grep -F "Logical block" <<< "$dvd_info" | awk '{print $5}')
  volume_size=$(grep -F "Volume size" <<< "$dvd_info" | awk '{print $4}')
  total_size=$((block_size * volume_size))
  log "Creating ISO: $iso (${total_size} bytes)..."
  dd if="$dvd" bs="$block_size" count="$volume_size" 2> /dev/null \
    | pv -pterb --size "$total_size" \
    | dd of="$iso" bs="$block_size" 2> /dev/null
  log "Verifying checksums..."
  local orig_check copy_check
  orig_check=$(sha1sum "$dvd" | awk '{print $1}')
  copy_check=$(sha1sum "$iso" | awk '{print $1}')
  info "Original: $orig_check"
  info "Copy:     $copy_check"
  [[ $orig_check == "$copy_check" ]] || die "Checksums do not match!"
  log "✓ DVD ripped successfully!"
}

cmd_pngzip(){
  local GRAYSCALE=0 TOUCH=0 VERBOSE=1 DPI=0 OPTIND
  while getopts ":gqtr:h" o; do
    case $o in
      g) GRAYSCALE=1 ;;
      q) VERBOSE=0 ;;
      t) TOUCH=1 ;;
      r) DPI=${OPTARG//[^0-9]/} ;;
      h)
        usage
        exit 0
        ;;
      *) die "Invalid option: -$OPTARG" ;;
    esac
  done
  shift $((OPTIND - 1))
  for cmd in pngquant oxipng; do need "$cmd"; done
  ((DPI > 0)) && need pngcrush
  local targets=()
  for x in "${@:-.}"; do
    if [[ -d $x ]]; then
      if has fd; then
        mapfile -t files < <(fd -tf -e png --strip-cwd-prefix "$x")
      else
        mapfile -t files < <(find "$x" -type f -name "*.png")
      fi
      targets+=("${files[@]}")
    elif [[ -f $x && $x == *.png ]]; then
      targets+=("$x")
    fi
  done
  [[ ${#targets[@]} -eq 0 ]] && die "No PNG files found"
  for f in "${targets[@]}"; do
    [[ -f $f && -r $f && -w $f ]] || {
      ((VERBOSE)) && printf "skip: %s\n" "$f"
      continue
    }
    local preserve=() grayargs=()
    ((TOUCH)) && preserve+=("--preserve=timestamps")
    ((GRAYSCALE)) && grayargs+=(--grayscale)
    local orig_size=$(stat -c %s "$f")
    local tmpq="${f}.pq.$$"
    pngquant -Q 70-95 --strip "${grayargs[@]}" --force -o "$tmpq" -- "$f" &> /dev/null || rm -f "$tmpq"
    if [[ -s $tmpq && $(stat -c %s "$tmpq") -lt $orig_size ]]; then
      cp "${preserve[@]}" "$tmpq" "$f"
      ((VERBOSE)) && printf 'pngquant: %s %s → %s\n' "$f" "$orig_size" "$(stat -c %s "$f")"
    fi
    rm -f "$tmpq"
    oxipng -o max --strip all --alpha --zopfli -P --zi 25 --fix --scale16 -- "$f" &> /dev/null || :
    local osize=$(stat -c %s "$f")
    if ((DPI > 0)); then
      local tmpc="${f}.cr.$$"
      pngcrush -brute -l 9 -res "$DPI" -s "$f" "$tmpc" &> /dev/null \
        && [[ -s $tmpc && $(stat -c %s "$tmpc") -lt $osize ]] \
        && cp "${preserve[@]}" "$tmpc" "$f" \
        && ((VERBOSE)) && printf 'pngcrush: %s DPI=%s %s → %s\n' "$f" "$DPI" "$osize" "$(stat -c %s "$f")"
      rm -f "$tmpc"
    fi
    ((VERBOSE)) && printf "%s: %s → %s bytes\n" "$f" "$orig_size" "$(stat -c %s "$f")"
  done
}

cmd_vid1080(){
  local vid="$1"
  need ffmpeg
  ffmpeg -i "$vid" -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy "${vid%.*}"-1080p.mp4
}

cmd_vid4k(){
  local vid="$1"
  need ffmpeg
  ffmpeg -i "$vid" -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k "${vid%.*}"-optimized.mp4
}

cmd_jpg(){
  local img="$1"
  shift
  need magick
  magick "$img" "$@" -quality 95 -strip "${img%.*}"-optimized.jpg
}

cmd_jpgsmall(){
  local img="$1"
  shift
  need magick
  magick "$img" "$@" -resize 1080x\> -quality 95 -strip "${img%.*}"-optimized.jpg
}

cmd_png(){
  local img="$1"
  shift
  need magick
  magick "$img" "$@" -strip -define png:compression-filter=5 \
    -define png:compression-level=9 -define png:compression-strategy=1 \
    -define png:exclude-chunk=all "${img%.*}"-optimized.png
}

main(){
  [[ ${#} -eq 0 || $1 == -h || $1 == --help ]] && {
    usage
    exit 0
  }
  local cmd="$1"
  shift
  case $cmd in
    cd)
      [[ ${#} -eq 1 ]] || die "Usage: media cd TOCFILE"
      cmd_cd "$@"
      ;;
    usb)
      [[ ${#} -eq 2 ]] || die "Usage: media usb ISO DEVICE"
      cmd_usb "$@"
      ;;
    compress)
      [[ ${#} -eq 1 ]] || die "Usage: media compress DIR"
      cmd_compress "$@"
      ;;
    decompress)
      [[ ${#} -eq 1 ]] || die "Usage: media decompress FILE"
      cmd_decompress "$@"
      ;;
    iso2sd)
      [[ ${#} -eq 2 ]] || die "Usage: media iso2sd ISO DEVICE"
      cmd_iso2sd "$@"
      ;;
    format)
      [[ ${#} -eq 2 ]] || die "Usage: media format DEVICE NAME"
      cmd_format "$@"
      ;;
    ripdvd)
      [[ ${#} -eq 1 ]] || die "Usage: media ripdvd OUTPUT.iso"
      cmd_ripdvd "$@"
      ;;
    pngzip) cmd_pngzip "$@" ;;
    vid1080)
      [[ ${#} -eq 1 ]] || die "Usage: media vid1080 VIDEO"
      cmd_vid1080 "$@"
      ;;
    vid4k)
      [[ ${#} -eq 1 ]] || die "Usage: media vid4k VIDEO"
      cmd_vid4k "$@"
      ;;
    jpg)
      [[ ${#} -ge 1 ]] || die "Usage: media jpg IMAGE [MAGICK_OPTS...]"
      cmd_jpg "$@"
      ;;
    jpgsmall)
      [[ ${#} -ge 1 ]] || die "Usage: media jpgsmall IMAGE [MAGICK_OPTS...]"
      cmd_jpgsmall "$@"
      ;;
    png)
      [[ ${#} -ge 1 ]] || die "Usage: media png IMAGE [MAGICK_OPTS...]"
      cmd_png "$@"
      ;;
    *) die "Unknown command: $cmd (run 'media --help')" ;;
  esac
}
main "$@"
