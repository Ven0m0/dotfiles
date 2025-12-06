#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar; IFS=$'\n\t'; LC_ALL=C; LANG=C
B=$'\e[1;34m' C=$'\e[1;36m' G=$'\e[1;32m' R=$'\e[1;31m' X=$'\e[0m'
has(){ command -v "$1" &>/dev/null; }
log(){ printf '%b==>%b %s\n' "$B" "$X" "$*"; }
ok(){ printf '%b==>%b %s\n' "$G" "$X" "$*"; }
die(){ printf '%b==> ERROR:%b %s\n' "$R" "$X" "$*" >&2; exit "${2:-1}"; }
req(){ has "$1"||die "missing: $1"; }

cd_burn(){ local t=$1; req cdrdao; [[ -f $t ]]||die "not found: $t"; log "Burning: $t"; sudo cdrdao write --eject --driver generic-mmc-raw "$t"; ok "Done"; }
usb_write(){
  local iso=$1 dst=$2 x="${iso##*.}" sz
  for c in dd pv stat; do req "$c"; done
  [[ -f $iso ]]||die "not found: $iso"; x="${x,,}"; [[ $x == iso || $x == img ]]||die "need .iso/.img: $iso"
  [[ -b $dst ]]||die "not block device: $dst"; grep -q "$dst" /proc/mounts&&die "mounted: $dst"
  log "⚠️  WARNING: DESTROY all data on $dst!"; read -rp "Continue? [y/N] " c; [[ $c == [yY] ]]||{ log "Cancelled"; exit 0; }
  sz=$(stat -c%s "$iso"); log "Copying $iso ($sz bytes) to $dst..."
  dd if="$iso" bs=4M status=none|pv --size "$sz" -pterb|sudo dd of="$dst" bs=4M status=none conv=fsync; sync; ok "Done"
}
iso2sd(){ local iso=$1 dst=$2; [[ -f $iso ]]||die "not found: $iso"; [[ -b $dst ]]||die "not block: $dst"; sudo dd bs=4M status=progress oflag=sync if="$iso" of="$dst"; sudo eject "$dst"||:; }
format_exfat(){
  local dev=$1 nm=$2; [[ -b $dev ]]||die "not block: $dev"
  log "⚠️  WARNING: Erasing $dev, label '$nm'"; read -rp "Continue? [y/N] " c; [[ $c == [yY] ]]||{ log "Cancelled"; exit 0; }
  sudo wipefs -a "$dev"; sudo dd if=/dev/zero of="$dev" bs=1M count=100 status=progress
  sudo parted -s "$dev" mklabel gpt mkpart primary 1MiB 100%
  local p=$([[ $dev == *nvme* ]]&&printf '%sp1' "$dev"||printf '%s1' "$dev")
  sudo partprobe "$dev"||:; sudo udevadm settle||:; sudo mkfs.exfat -n "$nm" "$p"; log "Formatted: $dev as exFAT '$nm'"
}
rip_dvd(){
  local iso=$1 dvd=/dev/sr0 inf bs vs sz oc cc
  for c in isoinfo dd pv sha1sum; do req "$c"; done
  [[ -b $dvd ]]||die "DVD not found: $dvd"; log "Reading DVD..."
  inf=$(isoinfo -d -i "$dvd"); bs=$(grep -F "Logical block"<<<"$inf"|awk '{print $5}'); vs=$(grep -F "Volume size"<<<"$inf"|awk '{print $4}')
  sz=$((bs*vs)); log "Creating: $iso ($sz bytes)..."
  dd if="$dvd" bs="$bs" count="$vs" 2>/dev/null|pv -pterb --size "$sz"|dd of="$iso" bs="$bs" 2>/dev/null
  log "Verifying..."; oc=$(sha1sum "$dvd"|awk '{print $1}'); cc=$(sha1sum "$iso"|awk '{print $1}')
  log "Original: $oc"; log "Copy: $cc"; [[ $oc == "$cc" ]]||die "Checksum mismatch!"; ok "Ripped: $iso"
}
pngzip(){
  local GRAY=0 TOUCH=0 VERB=1 DPI=0 OPTIND o
  while getopts ":gqtr:h" o; do case $o in g)GRAY=1;;q)VERB=0;;t)TOUCH=1;;r)DPI=${OPTARG//[^0-9]/};;h)usage; exit 0;;*)die "Invalid: -$OPTARG";;esac; done
  shift $((OPTIND-1)); for c in pngquant oxipng; do req "$c"; done; ((DPI>0))&&req pngcrush
  local -a tgts=() fs; for x in "${@:-.}"; do
    [[ -d $x ]]&&{ has fd&&mapfile -t fs < <(fd -tf -e png "$x")||mapfile -t fs < <(find "$x" -type f -name '*.png'); tgts+=("${fs[@]}"); }
    [[ -f $x && $x == *.png ]]&&tgts+=("$x")
  done; [[ ${#tgts[@]} -eq 0 ]]&&die "No PNGs"
  for f in "${tgts[@]}"; do
    [[ -f $f && -r $f && -w $f ]]||{ ((VERB))&&printf "skip: %s\n" "$f"; continue; }
    local p=() ga=(); ((TOUCH))&&p+=(--preserve=timestamps); ((GRAY))&&ga+=(--grayscale)
    local os=$(stat -c%s "$f") tq="${f}.pq.$$"
    pngquant -Q 70-95 --strip "${ga[@]}" --force -o "$tq" -- "$f"&>/dev/null||rm -f "$tq"
    [[ -s $tq && $(stat -c%s "$tq") -lt $os ]]&&{ cp "${p[@]}" "$tq" "$f"; ((VERB))&&printf 'pngquant: %s %s→%s\n' "$f" "$os" "$(stat -c%s "$f")"; }
    rm -f "$tq"; oxipng -o max --strip all --alpha --zopfli -P --zi 25 --fix --scale16 -- "$f"&>/dev/null||:
    local ns=$(stat -c%s "$f")
    if ((DPI>0)); then
      local tc="${f}.cr.$$"
      pngcrush -brute -l9 -res "$DPI" -s "$f" "$tc"&>/dev/null&&[[ -s $tc && $(stat -c%s "$tc") -lt $ns ]]&&\
        { cp "${p[@]}" "$tc" "$f"; ((VERB))&&printf 'pngcrush: %s DPI=%s %s→%s\n' "$f" "$DPI" "$ns" "$(stat -c%s "$f")"; }
      rm -f "$tc"
    fi
    ((VERB))&&printf "%s: %s→%s bytes\n" "$f" "$os" "$(stat -c%s "$f")"
  done
}
towebp(){
  req cwebp; local ll=true q=85 z=9 force=false OPTIND o
  while getopts ":lq:z:fh" o; do case $o in l)ll=true;;q)q=${OPTARG//[^0-9]/};;z)z=${OPTARG//[^0-9]/};;f)force=true;;h)usage; exit 0;;*)die "Invalid: -$OPTARG";;esac; done
  shift $((OPTIND-1)); local rt=${1:-.} fs=() cnt=0
  has fd&&mapfile -t fs < <(fd -tf -E '*.webp' -e png -e jpg -e jpeg "$rt")||mapfile -t fs < <(find "$rt" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) ! -iname '*.webp')
  [[ ${#fs[@]} -eq 0 ]]&&die "No images in: $rt"
  for s in "${fs[@]}"; do
    local out="${s%.*}.webp" x="${s##*.}" lx="${x,,}"
    [[ -e $out && $force == false ]]&&{ log "skip: $out (exists)"; continue; }
    case "$lx" in
      png)cwebp -lossless -z "$z" -mt -quiet "$s" -o "$out"&&ok "$s→$out"&&((cnt++))||printf 'ERR: %s\n' "$s" >&2;;
      jpg|jpeg)cwebp -q "$q" -m6 -mt -quiet "$s" -o "$out"&&ok "$s→$out"&&((cnt++))||printf 'ERR: %s\n' "$s" >&2;;
    esac
  done; log "Converted $cnt image(s)"
}
vid1080(){ local v=$1; req ffmpeg; ffmpeg -i "$v" -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy "${v%.*}-1080p.mp4"; }
vid4k(){ local v=$1; req ffmpeg; ffmpeg -i "$v" -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k "${v%.*}-4k.mp4"; }
jpg_opt(){ local i=$1; shift; req magick; magick "$i" "$@" -quality 95 -strip "${i%.*}-opt.jpg"; }
jpg_small(){ local i=$1; shift; req magick; magick "$i" "$@" -resize 1080x\> -quality 95 -strip "${i%.*}-small.jpg"; }
png_opt(){ local i=$1; shift; req magick; magick "$i" "$@" -strip -define png:compression-filter=5 -define png:compression-level=9 -define png:compression-strategy=1 -define png:exclude-chunk=all "${i%.*}-opt.png"; }
usage(){
  cat <<'EOF'
media - Media toolkit
USAGE: media COMMAND [ARGS...]
COMMANDS:
  cd <toc>              Burn audio CD
  usb <iso> <dev>       Write ISO to USB
  iso2sd <iso> <dev>    Write ISO to SD
  format <dev> <label>  Format as exFAT
  ripdvd <iso>          Rip DVD to ISO
  pngzip [opts] [path]  Compress PNGs
  towebp [opts] [path]  Convert to WebP
  vid1080 <video>       Transcode to 1080p
  vid4k <video>         Transcode to 4K
  jpg <img> [opts]      Convert to optimized JPG
  jpgsmall <img> [opts] Convert to small JPG
  png <img> [opts]      Convert to PNG
PNGZIP OPTIONS:
  -g  Grayscale  -q  Quiet  -t  Preserve mtime  -r DPI  Set DPI
TOWEBP OPTIONS:
  -l  Lossless (default)  -q N  Quality  -z N  Compression  -f  Force
EXAMPLES:
  media cd audio.toc
  media usb ubuntu.iso /dev/sdc
  media pngzip -g -r 72 images/
  media towebp -q 85 photos/
  media vid1080 video.mp4
EOF
}
main(){
  [[ $# -eq 0 || $1 == -h || $1 == --help ]]&&{ usage; exit 0; }
  local cmd=$1; shift
  case $cmd in
    cd)[[ $# -eq 1 ]]||die "usage: cd <toc>"; cd_burn "$@";;
    usb)[[ $# -eq 2 ]]||die "usage: usb <iso> <dev>"; usb_write "$@";;
    iso2sd)[[ $# -eq 2 ]]||die "usage: iso2sd <iso> <dev>"; iso2sd "$@";;
    format)[[ $# -eq 2 ]]||die "usage: format <dev> <label>"; format_exfat "$@";;
    ripdvd)[[ $# -eq 1 ]]||die "usage: ripdvd <iso>"; rip_dvd "$@";;
    pngzip)pngzip "$@";;
    towebp)towebp "$@";;
    vid1080)[[ $# -eq 1 ]]||die "usage: vid1080 <video>"; vid1080 "$@";;
    vid4k)[[ $# -eq 1 ]]||die "usage: vid4k <video>"; vid4k "$@";;
    jpg)[[ $# -ge 1 ]]||die "usage: jpg <img> [opts]"; jpg_opt "$@";;
    jpgsmall)[[ $# -ge 1 ]]||die "usage: jpgsmall <img> [opts]"; jpg_small "$@";;
    png)[[ $# -ge 1 ]]||die "usage: png <img> [opts]"; png_opt "$@";;
    *)die "Unknown: $cmd (use --help)";;
  esac
}
main "$@"
