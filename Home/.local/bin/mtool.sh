#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar extglob
IFS=$'\n\t'; export LC_ALL=C LANG=C
#══════════════════════════════════════════════════════════════
#  mtool - Unified Media Tool
#  Combines image/video/audio optimization with display & utilities
#══════════════════════════════════════════════════════════════
#──────────── Colors ────────────
RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' BLU=$'\e[34m' DEF=$'\e[0m'
#──────────── Global Config (for optimize) ────────────
declare -gi QUALITY=85 VID_CRF=27 AUD_BR=128 ZOPFLI_ITER=60
declare -gi LOSSLESS=0 DRY=0 BACKUP=0 KEEP=0 JOBS=0 FFZAP_T=2 INTERACTIVE=0
declare -g OUTDIR="" BACKUP_DIR="" TYPE="all" SUFFIX="_opt"
declare -g IMG_FMT="webp" VID_CODEC="av1"
declare -gi TOTAL=0 OK=0 SKIP=0 FAIL=0
#──────────── Helpers ────────────
has(){ command -v "$1" &>/dev/null; }
die(){ printf '%b%s%b\n' "$RED" "$*" "$DEF" >&2; exit 1; }
warn(){ printf '%b%s%b\n' "$YLW" "$*" "$DEF"; }
log(){ printf '%s\n' "$*"; }
#──────────── Cleanup ────────────
TMPDIR=$(mktemp -d)
cleanup(){ rm -rf "$TMPDIR"; }
trap cleanup EXIT
#──────────── Tool Resolution (cached) ────────────
MAGICK="${MAGICK:-}"; [[ -z "$MAGICK" ]] && has magick && MAGICK=magick || :
CWEBP="${CWEBP:-}"; [[ -z "$CWEBP" ]] && has cwebp && CWEBP=cwebp || :
AVIFENC="${AVIFENC:-}"; [[ -z "$AVIFENC" ]] && has avifenc && AVIFENC=avifenc || :
FFTHUMB="${FFTHUMB:-}"; [[ -z "$FFTHUMB" ]] && has ffmpegthumbnailer && FFTHUMB=ffmpegthumbnailer || :
CHAFACMD="${CHAFACMD:-}"; [[ -z "$CHAFACMD" ]] && has chafa && CHAFACMD=chafa || :
#──────────── Type Detection ────────────
is_image(){ local m; m=$(file --mime-type -b -- "$1" 2>/dev/null || :); [[ "$m" == image/* ]]; }
is_video(){ local m; m=$(file --mime-type -b -- "$1" 2>/dev/null || :); [[ "$m" == video/* ]]; }
#══════════════════════════════════════════════════════════════
#  DISPLAY COMMAND (from imgtool)
#══════════════════════════════════════════════════════════════
term_dim(){
  local lines cols
  read -r lines cols < <(stty size </dev/tty 2>/dev/null || printf '40 120\n')
  printf '%sx%s' "$cols" "$lines"
}
display_one(){
  local p="$1" dim; dim="$(term_dim)"
  if [[ -n "${KITTY_WINDOW_ID:-}" || -n "${GHOSTTY_RESOURCES_DIR:-}" ]] && has kitten; then
    kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="$dim@0x0" -- "$p" | sed '$d' | sed $'$s/$/\e[m/'
  elif [[ -n "$CHAFACMD" ]]; then
    "$CHAFACMD" -f sixel -s "$dim" --animate false -- "$p" || "$CHAFACMD" -f symbols -s "$dim" -- "$p"
  else
    file --brief --dereference --mime -- "$p"
  fi
}
cmd_display(){
  (( $# )) || { printf 'Usage: mtool display FILE|DIR...\n' >&2; return 2; }
  local p
  for p in "$@"; do
    if [[ -d "$p" ]]; then
      mapfile -t imgs < <(find -- "$p" -maxdepth 1 -type f)
      ((${#imgs[@]})) || { printf 'empty: %s\n' "$p" >&2; continue; }
      display_one "${imgs[0]}"
    else
      display_one "$p"
    fi
  done
}

#══════════════════════════════════════════════════════════════
#  THUMB COMMAND (from imgtool)
#══════════════════════════════════════════════════════════════
cmd_thumb(){
  local size="1200" outdir="."
  while (( $# )); do
    case "$1" in
      -s) size="$2"; shift 2 ;;
      -o) outdir="$2"; shift 2 ;;
      --) shift; break ;;
      -h|--help) printf 'Usage: mtool thumb [-s SIZE] [-o OUTDIR] FILE...\n'; return 0 ;;
      -*) printf 'bad flag: %s\n' "$1" >&2; return 2 ;;
      *) break ;;
    esac
  done
  mkdir -p -- "$outdir" || :
  (( $# )) || { printf 'no inputs\n' >&2; return 2; }

  local f out base
  for f in "$@"; do
    [[ -f "$f" ]] || { printf 'skip (not file): %s\n' "$f" >&2; continue; }
    base="${f##*/}"; base="${base%.*}"
    out="${outdir%/}/${base}.jpg"
    if is_video "$f"; then
      [[ -n "$FFTHUMB" ]] || { printf 'need ffmpegthumbnailer for video: %s\n' "$f" >&2; continue; }
      "$FFTHUMB" -i "$f" -o "$out" -s "$size"
    elif is_image "$f"; then
      [[ -n "$MAGICK" ]] || { printf 'need magick for image: %s\n' "$f" >&2; continue; }
      "$MAGICK" convert "$f" -thumbnail "${size}x${size}>" -strip "$out"
    else
      printf 'skip (unknown type): %s\n' "$f" >&2
    fi
    printf '%s -> %s\n' "$f" "$out"
  done
}

#══════════════════════════════════════════════════════════════
#  CONVERT COMMAND (from imgtool)
#══════════════════════════════════════════════════════════════
out_path(){
  local outdir="$1" in="$2" newext="$3"
  local base="${in##*/}" stem="${base%.*}"
  printf '%s/%s.%s' "${outdir%/}" "$stem" "$newext"
}

cmd_convert(){
  local to="webp" q="" outdir="."
  while (( $# )); do
    case "$1" in
      -t) to="$2"; shift 2 ;;
      -q) q="$2"; shift 2 ;;
      -o) outdir="$2"; shift 2 ;;
      --) shift; break ;;
      -h|--help) printf 'Usage: mtool convert [-t webp|avif] [-q Q] [-o OUTDIR] FILE...\n'; return 0 ;;
      -*) printf 'bad flag: %s\n' "$1" >&2; return 2 ;;
      *) break ;;
    esac
  done
  mkdir -p -- "$outdir" || :
  [[ "$to" =~ ^(webp|avif)$ ]] || { printf 'target must be webp|avif\n' >&2; return 2; }
  (( $# )) || { printf 'no inputs\n' >&2; return 2; }

  local f out
  for f in "$@"; do
    [[ -f "$f" ]] || { printf 'skip (not file): %s\n' "$f" >&2; continue; }
    is_image "$f" || { printf 'skip (not image): %s\n' "$f" >&2; continue; }
    if [[ "$to" == "webp" ]]; then
      out="$(out_path "$outdir" "$f" webp)"
      if [[ -n "$CWEBP" ]]; then
        "$CWEBP" ${q:+-q "$q"} -mt -m 6 -metadata all -- "$f" -o "$out"
      elif [[ -n "$MAGICK" ]]; then
        "$MAGICK" convert "$f" -quality "${q:-82}" -define webp:method=6 -strip "$out"
      else
        printf 'need cwebp or magick\n' >&2; return 3
      fi
    else
      out="$(out_path "$outdir" "$f" avif)"
      if [[ -n "$AVIFENC" ]]; then
        "$AVIFENC" ${q:+--min "$q" --max "$q"} --speed 6 --jobs 0 -- "$f" "$out"
      elif [[ -n "$MAGICK" ]]; then
        "$MAGICK" convert "$f" -quality "${q:-32}" -define heic:speed=6 -strip "$out"
      else
        printf 'need avifenc or magick\n' >&2; return 3
      fi
    fi
    printf '%s -> %s\n' "$f" "$out"
  done
}

#══════════════════════════════════════════════════════════════
#  COMPRESS COMMAND (from imgtool)
#══════════════════════════════════════════════════════════════
cmd_compress(){
  local q="82"
  while (( $# )); do
    case "$1" in
      -q) q="$2"; shift 2 ;;
      --) shift; break ;;
      -h|--help) printf 'Usage: mtool compress [-q Q] FILE...\n'; return 0 ;;
      -*) printf 'bad flag: %s\n' "$1" >&2; return 2 ;;
      *) break ;;
    esac
  done
  (( $# )) || { printf 'no inputs\n' >&2; return 2; }

  local f ext tmp
  for f in "$@"; do
    [[ -f "$f" ]] || { printf 'skip (not file): %s\n' "$f" >&2; continue; }
    ext="${f##*.}"; ext="${ext,,}"
    case "$ext" in
      jpg|jpeg|png)
        [[ -n "$MAGICK" ]] || { printf 'need magick for %s\n' "$f" >&2; continue; }
        tmp="${f}.tmp"; "$MAGICK" convert "$f" -strip -quality "$q" "$tmp" && mv -f -- "$tmp" "$f"
        ;;
      webp)
        [[ -n "$CWEBP" ]] || { printf 'need cwebp for %s\n' "$f" >&2; continue; }
        tmp="${f%.webp}.tmp.webp"
        "$CWEBP" -q "$q" -mt -m 6 -metadata all -- "$f" -o "$tmp" && mv -f -- "$tmp" "$f"
        ;;
      avif)
        [[ -n "$AVIFENC" ]] || { printf 'need avifenc for %s\n' "$f" >&2; continue; }
        tmp="${f%.avif}.tmp.avif"
        "$AVIFENC" --min "$q" --max "$q" --speed 6 --jobs 0 -- "$f" "$tmp" && mv -f -- "$tmp" "$f"
        ;;
      *) printf 'skip (unknown ext): %s\n' "$f" >&2 ;;
    esac
  done
}

#══════════════════════════════════════════════════════════════
#  OPTIMIZE COMMAND (comprehensive, from mtool)
#══════════════════════════════════════════════════════════════
find_files(){
  local dir=${1:-.}
  local -a img=(jpg jpeg png gif webp avif jxl tiff bmp)
  local -a vid=(mp4 mkv mov webm avi flv)
  local -a aud=(opus flac mp3 m4a aac ogg wav)
  local -a doc=(html htm css js svg)
  local -a exts=()
  case $TYPE in
    all) exts=("${img[@]}" "${vid[@]}" "${aud[@]}" "${doc[@]}");;
    image) exts=("${img[@]}");;
    video) exts=("${vid[@]}");;
    audio) exts=("${aud[@]}");;
    web) exts=("${doc[@]}");;
  esac
  if has fd; then
    local -a args=(-tf --no-require-git -S+10k)
    for e in "${exts[@]}"; do args+=(-e "$e"); done
    fd "${args[@]}" "$dir" 2>/dev/null | grep -v "$SUFFIX"
  else
    local patterns=$(printf -- "-o -iname *.%s " "${exts[@]}")
    find "$dir" -type f ! -name "*${SUFFIX}*" -size +10k \( ${patterns#-o } \) 2>/dev/null
  fi
}

outpath(){
  local src=$1 fmt=${2:-${src##*.}}
  local dir=${OUTDIR:-$(dirname "$src")}
  local base=$(basename "$src")
  local name="${base%.*}"
  printf '%s/%s%s.%s' "$dir" "$name" "$SUFFIX" "$fmt"
}

backup_file(){
  (( BACKUP == 0 )) && return 0
  local src=$1
  local dst="$BACKUP_DIR$src"
  mkdir -p "${dst%/*}"
  cp -p "$src" "$dst"
}

opt_image(){
  local src=$1 ext="${src##*.}" && ext="${ext,,}"
  local out=$(outpath "$src" "$IMG_FMT")
  [[ -f $out && $KEEP -eq 1 ]] && { ((SKIP++)); return 0; }
  [[ $DRY -eq 1 ]] && { log "[DRY] $(basename "$src") → $IMG_FMT"; return 0; }
  backup_file "$src"
  local tmp="$TMPDIR/$(basename "$src")"
  cp "$src" "$tmp" || return 1

  # Format conversion
  if [[ $IMG_FMT != "$ext" ]]; then
    local conv="$TMPDIR/$(basename "$src" ."$ext").$IMG_FMT"
    if has rimage; then
      local cmd="$IMG_FMT"
      [[ $IMG_FMT == "webp" ]] && cmd="mozjpeg"
      if (( LOSSLESS )); then
        rimage "$cmd" -d "$TMPDIR" "$tmp" &>/dev/null
      else
        rimage "$cmd" -q "$QUALITY" -d "$TMPDIR" "$tmp" &>/dev/null
      fi
      [[ -f $conv ]] && mv "$conv" "$out" || { rm -f "$tmp"; return 1; }
    else
      case $IMG_FMT in
        webp)
          has cwebp && {
            if (( LOSSLESS )); then
              cwebp -lossless "$tmp" -o "$out" &>/dev/null
            else
              cwebp -q "$QUALITY" -m 6 "$tmp" -o "$out" &>/dev/null
            fi
          };;
        avif) has avifenc && avifenc -s 6 -j "$JOBS" --min 0 --max 60 "$tmp" "$out" &>/dev/null;;
        jxl)
          has cjxl && {
            if (( LOSSLESS )); then
              cjxl "$tmp" "$out" -d 0 -e 7 &>/dev/null
            else
              cjxl "$tmp" "$out" -q "$QUALITY" -e 7 &>/dev/null
            fi
          };;
      esac
    fi
    rm -f "$tmp"
  else
    # In-place optimization
    if (( LOSSLESS )); then
      if has flaca; then
        flaca --preserve-times "$tmp" &>/dev/null || { rm -f "$tmp"; return 1; }
      else
        case $ext in
          png)
            has oxipng && oxipng -o max --strip all -a -i 0 --scale16 -Z --zi "$ZOPFLI_ITER" -q "$tmp" &>/dev/null
            has optipng && optipng -o7 -quiet "$tmp" &>/dev/null;;
          jpg|jpeg) has jpegoptim && jpegoptim --strip-all --all-progressive -q "$tmp" &>/dev/null;;
          webp) has cwebp && cwebp -lossless "$tmp" -o "${tmp}.webp" &>/dev/null && mv "${tmp}.webp" "$tmp";;
          gif) has gifsicle && gifsicle -O3 --batch "$tmp" &>/dev/null;;
        esac
      fi
    else
      if has rimage; then
        rimage mozjpeg -q "$QUALITY" -d "$TMPDIR" "$tmp" &>/dev/null || { rm -f "$tmp"; return 1; }
        local opt="$TMPDIR/$(basename "$tmp")"
        [[ -f $opt ]] && mv -f "$opt" "$tmp"
      else
        case $ext in
          png)
            has pngquant && {
              pngquant --quality="$((QUALITY-20))"-"$QUALITY" --speed=1 -f "$tmp" -o "${tmp}.q" &>/dev/null && mv "${tmp}.q" "$tmp"
            }
            has oxipng && oxipng -o max --strip all -a -i 0 -q "$tmp" &>/dev/null;;
          jpg|jpeg) has jpegoptim && jpegoptim --max="$QUALITY" --strip-all -q -f "$tmp" &>/dev/null;;
          webp) has cwebp && cwebp -q "$QUALITY" -m 6 "$tmp" -o "${tmp}.webp" &>/dev/null && mv "${tmp}.webp" "$tmp";;
          gif) has gifsicle && gifsicle -O3 --batch "$tmp" &>/dev/null;;
        esac
      fi
    fi
    mv -f "$tmp" "$out"
  fi

  [[ -f $out ]] || { ((FAIL++)); return 1; }

  local orig=$(stat -c%s "$src" 2>/dev/null || echo 0)
  local new=$(stat -c%s "$out" 2>/dev/null || echo 0)

  if (( new > 0 && new < orig )); then
    printf '%s → %d%%\n' "$(basename "$src")" "$((100 - new * 100 / orig))"
    [[ $KEEP -eq 0 ]] && rm -f "$src"
    ((OK++))
  else
    rm -f "$out"
    ((SKIP++))
  fi
}

opt_video(){
  local src=$1 out=$(outpath "$src")

  [[ -f $out && $KEEP -eq 1 ]] && { ((SKIP++)); return 0; }
  [[ $DRY -eq 1 ]] && { log "[DRY] $(basename "$src")"; return 0; }

  has ffmpeg || { warn "ffmpeg missing"; ((FAIL++)); return 1; }

  backup_file "$src"
  local enc=$(ffmpeg -hide_banner -encoders 2>/dev/null)
  local vc="libx264"
  # TODO: compare av1an with ffzap for av1 speed and implement it if it is faster/more useful
  case $VID_CODEC in
    av1)
    # TODO: compare SVT-AV1-PSY/SVT-AV1-forks vs AOMenc
      [[ $enc == *libsvtav1* ]] && vc="libsvtav1" || \
      [[ $enc == *libaom-av1* ]] && vc="libaom-av1";;
    vp9) [[ $enc == *libvpx-vp9* ]] && vc="libvpx-vp9";;
    h265) [[ $enc == *libx265* ]] && vc="libx265";;
    h264) vc="libx264";;
  esac
  local -a vargs=() aargs=(-c:a libopus -b:a "${AUD_BR}k")
  case $vc in
    libsvtav1) vargs=(-c:v libsvtav1 -preset 8 -crf "$VID_CRF");;
    libaom-av1) vargs=(-c:v libaom-av1 -cpu-used 6 -crf "$VID_CRF");;
    libvpx-vp9) vargs=(-c:v libvpx-vp9 -crf "$VID_CRF" -b:v 0 -row-mt 1);;
    libx265) vargs=(-c:v libx265 -preset medium -crf "$VID_CRF");;
    *) vargs=(-c:v libx264 -preset medium -crf "$VID_CRF");;
  esac
  local tmp="$TMPDIR/$(basename "$out")"
  if has ffzap; then
    ffzap -i "$src" -f "${vargs[*]} ${aargs[*]}" -o "$tmp" -t "$FFZAP_T" --overwrite &>/dev/null
  else
    ffmpeg -i "$src" "${vargs[@]}" "${aargs[@]}" -y "$tmp" &>/dev/null
  fi
  [[ -f $tmp ]] || { ((FAIL++)); return 1; }
  local orig=$(stat -c%s "$src" 2>/dev/null || echo 0)
  local new=$(stat -c%s "$tmp" 2>/dev/null || echo 0)
  if (( new > 0 && new < orig )); then
    mv -f "$tmp" "$out"
    printf '%s → %d%%\n' "$(basename "$src")" "$((100 - new * 100 / orig))"
    [[ $KEEP -eq 0 ]] && rm -f "$src"
    ((OK++))
  else
    rm -f "$tmp"
    ((SKIP++))
  fi
}

opt_audio(){
  local src=$1 ext="${src##*.}" && ext="${ext,,}"
  local out=$(outpath "$src" "opus")
  [[ $ext == "opus" ]] && { ((SKIP++)); return 0; }
  [[ -f $out && $KEEP -eq 1 ]] && { ((SKIP++)); return 0; }
  [[ $DRY -eq 1 ]] && { log "[DRY] $(basename "$src") → opus"; return 0; }
  has ffmpeg || { warn "ffmpeg missing"; ((FAIL++)); return 1; }
  backup_file "$src"
  local tmp="$TMPDIR/$(basename "$out")"
  if has ffzap; then
    ffzap -i "$src" -f "-c:a libopus -b:a ${AUD_BR}k" -o "$tmp" -t "$FFZAP_T" --overwrite &>/dev/null
  else
    ffmpeg -i "$src" -c:a libopus -b:a "${AUD_BR}k" -y "$tmp" &>/dev/null
  fi
  [[ -f $tmp ]] || { ((FAIL++)); return 1; }
  local orig=$(stat -c%s "$src" 2>/dev/null || echo 0)
  local new=$(stat -c%s "$tmp" 2>/dev/null || echo 0)
  if (( new > 0 && new < orig )); then
    mv "$tmp" "$out"
    printf '%s → %d%%\n' "$(basename "$src")" "$((100 - new * 100 / orig))"
    [[ $KEEP -eq 0 ]] && rm -f "$src"
    ((OK++))
  else
    rm -f "$tmp"
    ((SKIP++))
  fi
}

opt_web(){
  local src=$1 ext="${src##*.}" && ext="${ext,,}"
  local out=$(outpath "$src" "$ext")

  [[ -f $out && $KEEP -eq 1 ]] && { ((SKIP++)); return 0; }
  [[ $DRY -eq 1 ]] && { log "[DRY] $(basename "$src")"; return 0; }

  backup_file "$src"
  local tmp="$TMPDIR/$(basename "$src")"
  cp "$src" "$tmp"

  case $ext in
    svg)
      has svgo && svgo --multipass --quiet "$tmp" &>/dev/null
      has scour && scour -i "$tmp" -o "${tmp}.sc" --enable-id-stripping --enable-comment-stripping &>/dev/null && mv "${tmp}.sc" "$tmp"
      ;;
    html|htm)
      has minhtml && minhtml --in-place "$tmp" &>/dev/null
      ;;
    css)
      has minhtml && minhtml --in-place --minify-css "$tmp" &>/dev/null
      ;;
    js)
      has minhtml && minhtml --in-place --minify-js "$tmp" &>/dev/null
      ;;
  esac

  mv "$tmp" "$out"

  local orig=$(stat -c%s "$src" 2>/dev/null || echo 0)
  local new=$(stat -c%s "$out" 2>/dev/null || echo 0)

  if (( new > 0 && new < orig )); then
    printf '%s → %d%%\n' "$(basename "$src")" "$((100 - new * 100 / orig))"
    [[ $KEEP -eq 0 ]] && rm -f "$src"
    ((OK++))
  else
    ((SKIP++))
  fi
}

process(){
  local f=$1 ext="${f##*.}" && ext="${ext,,}"
  ((TOTAL++))

  case $ext in
    jpg|jpeg|png|gif|webp|avif|jxl|tiff|bmp)
      [[ $TYPE =~ ^(all|image)$ ]] && opt_image "$f";;
    mp4|mkv|mov|webm|avi|flv)
      [[ $TYPE =~ ^(all|video)$ ]] && opt_video "$f";;
    opus|flac|mp3|m4a|aac|ogg|wav)
      [[ $TYPE =~ ^(all|audio)$ ]] && opt_audio "$f";;
    html|htm|css|js|svg)
      [[ $TYPE =~ ^(all|web)$ ]] && opt_web "$f";;
    *) ((SKIP++));;
  esac
}

cmd_optimize(){
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) cat <<'EOF'
mtool optimize - Comprehensive media optimizer

USAGE: mtool optimize [OPTIONS] [paths...]

OPTIONS:
  -t TYPE      Type: all|image|video|audio|web (default: all)
  -q N         Quality 1-100 (default: 85)
  -c N         Video CRF 0-51 (default: 27)
  -b N         Audio bitrate kbps (default: 128)
  -o DIR       Output directory
  -B DIR       Backup directory (enables backup)
  -k           Keep originals
  -j N         Parallel jobs (0=auto, default: 0)
  -l           Lossless mode
  -n           Dry-run
  -i           Interactive mode (fzf/sk)
  --img FMT    Image format: webp|avif|jxl|png|jpg (default: webp)
  --vid CODEC  Video codec: av1|vp9|h265|h264 (default: av1)
  --zopfli N   Zopfli iterations (default: 60)
  --ffzap-t N  ffzap threads (default: 2)

FEATURES:
  • Recursive processing, min 10KB files
  • Excludes *_opt* paths automatically
  • Backup system with timestamp
  • Interactive picker with preview
  • Parallel: rust-parallel → parallel → xargs
EOF
        return 0;;
      -t) TYPE="${2,,}"; shift 2;;
      -q) QUALITY=$2; shift 2;;
      -c) VID_CRF=$2; shift 2;;
      -b) AUD_BR=$2; shift 2;;
      -o) OUTDIR=$2; shift 2;;
      -B) BACKUP=1; BACKUP_DIR="${2%/}/backup_$(date +%Y%m%d_%H%M%S)/"; shift 2;;
      -k) KEEP=1; shift;;
      -j) JOBS=$2; shift 2;;
      -l) LOSSLESS=1; shift;;
      -n) DRY=1; shift;;
      -i) INTERACTIVE=1; shift;;
      --img) IMG_FMT="${2,,}"; shift 2;;
      --vid) VID_CODEC="${2,,}"; shift 2;;
      --zopfli) ZOPFLI_ITER=$2; shift 2;;
      --ffzap-t) FFZAP_T=$2; shift 2;;
      -*) die "Unknown: $1";;
      *) break;;
    esac
  done

  (( QUALITY < 1 || QUALITY > 100 )) && die "Quality: 1-100"
  (( VID_CRF < 0 || VID_CRF > 51 )) && die "CRF: 0-51"
  [[ -n $OUTDIR ]] && mkdir -p "$OUTDIR"
  [[ $BACKUP -eq 1 ]] && mkdir -p "$BACKUP_DIR"
  [[ $JOBS -eq 0 ]] && JOBS=$(nproc)

  local -a files=()

  if (( INTERACTIVE )); then
    has fzf || has sk || die "Interactive requires fzf/sk"
    local picker=$(has fzf && echo fzf || echo sk)
    local preview=$(has bat && echo "bat --color=always --style=numbers --line-range=:50 {}" || echo "stat -c'Size: %s | Modified: %y' {}")
    mapfile -t files < <(find_files "${1:-.}" | "$picker" -m --height=~90% --layout=reverse \
      --preview="$preview" --preview-window=right:50%:wrap \
      --bind='ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all')
  elif [[ $# -eq 0 ]]; then
    mapfile -t files < <(find_files .)
  else
    for p in "$@"; do
      [[ -f $p ]] && files+=("$p") || mapfile -t -O "${#files[@]}" files < <(find_files "$p")
    done
  fi

  [[ ${#files[@]} -eq 0 ]] && die "No files"

  log "Files: ${#files[@]} | Jobs: $JOBS | Mode: $([[ $LOSSLESS -eq 1 ]] && echo Lossless || echo "Lossy Q=$QUALITY")"
  log "Formats: Img=$IMG_FMT Vid=$VID_CODEC | Backup: $([[ $BACKUP -eq 1 ]] && echo "$BACKUP_DIR" || echo "Disabled")"

  if (( JOBS > 1 )); then
    export -f process opt_image opt_video opt_audio opt_web outpath backup_file has
    export QUALITY VID_CRF AUD_BR LOSSLESS OUTDIR KEEP DRY TYPE SUFFIX TMPDIR BACKUP BACKUP_DIR
    export IMG_FMT VID_CODEC FFZAP_T ZOPFLI_ITER JOBS RED GRN YLW DEF

    if has rust-parallel; then
      printf '%s\0' "${files[@]}" | rust-parallel -0 -j "$JOBS" bash -c 'process "$1"' _ {}
    elif has parallel; then
      printf '%s\0' "${files[@]}" | parallel -0 -j "$JOBS" --no-notice process {}
    else
      printf '%s\0' "${files[@]}" | xargs -0 -r -P "$JOBS" -n1 bash -c 'process "$1"' _
    fi
  else
    for f in "${files[@]}"; do process "$f"; done
  fi

  log "Done: OK=$OK Skip=$SKIP Fail=$FAIL Total=$TOTAL"
  [[ $BACKUP -eq 1 ]] && log "Backups: $BACKUP_DIR"
}

#══════════════════════════════════════════════════════════════
#  MAIN DISPATCHER
#══════════════════════════════════════════════════════════════
usage(){
  cat <<'EOF'
mtool - Unified Media Tool

USAGE:
  mtool <command> [options] [args...]

COMMANDS:
  optimize     Comprehensive media optimization (image/video/audio/web)
  convert      Convert images to webp/avif
  compress     Compress images in-place
  display      Display images/videos in terminal
  thumb        Generate thumbnails

OPTIONS:
  -h, --help   Show help for command

EXAMPLES:
  mtool optimize -t image -q 85 photos/
  mtool convert -t webp -o output/ *.jpg
  mtool compress -q 80 image.png
  mtool display image.jpg
  mtool thumb -s 800 video.mp4

For detailed help on a command:
  mtool <command> --help
EOF
}

main(){
  local cmd="${1:-}"; shift || :
  case "${cmd:-}" in
    optimize) cmd_optimize "$@" ;;
    convert) cmd_convert "$@" ;;
    compress) cmd_compress "$@" ;;
    display) cmd_display "$@" ;;
    thumb) cmd_thumb "$@" ;;
    ""|-h|--help|help) usage ;;
    *) printf '%bUnknown command: %s%b\n' "$RED" "$cmd" "$DEF" >&2; usage; return 2 ;;
  esac
}

main "$@"
