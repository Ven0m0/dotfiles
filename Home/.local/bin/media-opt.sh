#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar
IFS=$' \n\t'; export LC_ALL=C LANG=C HOME="/home/${SUDO_USER:-$USER}"
# ==============================================================================
# MEDIA OPTIMIZER (Universal)
# ==============================================================================
# Integrates: rimage, image-optimizer, ffzap, ffmpeg, minify, scour, svgcleaner
# Features: Deep Codec Flags, Atomic Replaces, Size Guards, Parallel Execution
# ==============================================================================
# ==============================================================================
# CONFIGURATION & DEFAULTS
# ==============================================================================
# Override these via Environment Variables or CLI Flags
# General
: "${VERSION:=5.1}"
: "${JOBS:=$(nproc 2>/dev/null || echo 4)}"
: "${DRY_RUN:=0}"
: "${BACKUP:=0}"
: "${KEEP_MTIME:=1}"
: "${BACKUP_DIR:=${HOME}/.cache/media-opt/backups/$(date +%Y%m%d_%H%M%S)}"
: "${TMP_DIR:=$(mktemp -d)}"
# Optimization Levels
: "${LOSSLESS:=1}"        # 1=Lossless/High-Efficiency (default), 0=Lossy/Fast
: "${QUALITY:=100}"       # 1-100. 100=Best/Lossless.
: "${VIDEO_CRF:=24}"      # Video Quality (Lower=Better). 
                          # AV1: 20-30, x265: 20-28, x264: 18-24.
# Codecs
: "${VIDEO_CODEC:=libsvtav1}" # Options: libsvtav1, libaom-av1, libvpx-vp9, libx265, libx264
: "${AUDIO_CODEC:=libopus}"   # Default Audio Codec
: "${AUDIO_BR:=128k}"         # Audio Bitrate
# Colors
R=$'\e[31m' G=$'\e[32m' Y=$'\e[33m' B=$'\e[34m' X=$'\e[0m'

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================
cleanup(){ rm -rf "$TMP_DIR"; }
trap cleanup EXIT INT TERM
log(){ printf "${B}[%(%H:%M:%S)T]${X} %s\n" -1 "$*"; }
warn(){ printf "${Y}[WARN]${X} %s\n" "$*"; }
err(){ printf "${R}[ERR]${X} %s\n" "$*" >&2; }
has(){ command -v "$1" &>/dev/null; }

usage(){
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [PATH...]

Ultra-optimized media compressor.
Prioritizes: rimage, image-optimizer, ffzap.
Deep optimization enabled for ffmpeg fallback.

Configuration Flags:
  -j, --jobs N        Parallel jobs (Default: $JOBS)
  -l, --lossy         Enable lossy mode (Default: Lossless/High-Efficiency)
  -q, --quality N     Target Quality 1-100 (Default: $QUALITY)
  --crf N             Video CRF for ffmpeg fallback (Default: $VIDEO_CRF)
  --vcodec STR        Video Codec: libsvtav1, libaom-av1, libvpx-vp9, libx265 (Default: $VIDEO_CODEC)
  --acodec STR        Audio Codec (Default: $AUDIO_CODEC)
  --backup            Backup original files to ~/.cache/media-opt
  --dry-run           Simulate execution
  -h, --help          Show this help

Supported Formats:
  Img: jpg, png, webp, avif, jxl, bmp, svg, gif
  Vid: mp4, mkv, mov, webm, avi
EOF
  exit 0
}

# ==============================================================================
# CORE OPTIMIZATION LOGIC
# ==============================================================================
optimize_file(){
  local file="$1"; local ext="${file##*.}"; local lc_ext="${ext,,}"
  local tmp_out="${TMP_DIR}/$(basename "$file")" cmd=() tool=""
  # 1. Determine Tool & Command
  case "$lc_ext" in
    # --- RASTER IMAGES (Priority: rimage > image-optimizer > fallbacks) ---
    jpg|jpeg|mjpg|png|webp|avif|jxl|bmp)
      # 1. rimage (https://crates.io/crates/rimage)
      if has rimage; then
        tool="rimage"
        # rimage optimizations in place or to separate dir. We copy to tmp first.
        cp "$file" "$tmp_out"
        if [[ "$LOSSLESS" -eq 1 ]]; then
          cmd=(rimage "$tmp_out" --quality 100)
        else
          cmd=(rimage "$tmp_out" --quality "$QUALITY")
        fi
      # 2. image-optimizer (https://crates.io/crates/image-optimizer)
      elif has image-optimizer && [[ "$lc_ext" =~ ^(jpg|jpeg|png|webp)$ ]]; then
        tool="image-optimizer"
        cmd=(image-optimizer "$file" "$tmp_out")
        
      # 3. Standard Fallbacks
      else
        case "$lc_ext" in
          jpg|jpeg|mjpg)
            if has jpegoptim; then
              tool="jpegoptim"
              local qual_arg=()
              [[ "$LOSSLESS" -eq 0 ]] && qual_arg=(-m"$QUALITY")
              cmd=(jpegoptim --strip-all --all-progressive "${qual_arg[@]}" --stdout "$file")
            elif has mozjpeg; then
              tool="mozjpeg"
              cmd=(mozjpeg -quality "${QUALITY}" -progressive "$file")
            fi ;;
          png)
            if has oxipng; then
              tool="oxipng"
              cmd=(oxipng -o 4 --strip safe -i 0 --out - "$file")
            elif has optipng; then
              tool="optipng"
              cmd=(optipng -o5 -strip all -out "$tmp_out" "$file")
            fi ;;
          webp)
            if has cwebp; then
              tool="cwebp"
              local args=()
              if [[ "$LOSSLESS" -eq 1 ]]; then args=(-lossless -z 9); else args=(-q "$QUALITY" -m 6); fi
              cmd=(cwebp "${args[@]}" -mt -quiet "$file" -o -)
            fi ;;
        esac
      fi ;;
    # --- VECTOR IMAGES (SVG) ---
    svg)
      if has image-optimizer; then
        tool="image-optimizer"
        cmd=(image-optimizer "$file" "$tmp_out")
      elif has svgcleaner; then
        tool="svgcleaner"
        cmd=(svgcleaner "$file" "$tmp_out")
      elif has scour; then
        tool="scour"
        cmd=(scour -i "$file" -o "$tmp_out" --enable-viewboxing --enable-id-stripping --shorten-ids --indent=none)
      elif has minify; then
        tool="minify"
        cmd=(minify -o "$tmp_out" "$file")
      elif has svgo; then
        tool="svgo"
        cmd=(svgo -i "$file" -o - --multipass)
      fi ;;
    # --- ANIMATIONS (GIF) ---
    gif)
      if has gifsicle; then
        tool="gifsicle"
        local args=(-O3 --careful)
        [[ "$LOSSLESS" -eq 0 ]] && args=(-O3 --lossy=80)
        cmd=(gifsicle "${args[@]}" "$file")
      fi ;;
    # --- VIDEO / AUDIO (Priority: ffzap > ffmpeg with Deep Flags) ---
    mp4|mkv|mov|avi|webm)
      local a_args=(-c:a "$AUDIO_CODEC" -b:a "$AUDIO_BR")
      [[ "$AUDIO_CODEC" == "copy" ]] && a_args=(-c:a copy)
      # 1. ffzap (Smart VMAF/SSim wrapper)
      if has ffzap; then
        tool="ffzap"; cmd=(ffzap -i "$file" -o "$tmp_out")
      # 2. ffmpeg (Deep Configuration)
      elif has ffmpeg; then
        tool="ffmpeg"
        local v_args=()
        # Apply deep codec-specific flags for efficiency
        case "$VIDEO_CODEC" in
          libsvtav1)
            # Preset: 0-13 (Lower=Slower/Better). 
            if [[ "$LOSSLESS" -eq 1 ]]; then
              # High Efficiency: Preset 4 is efficient/dense. tune=0 (Visual).
              v_args=(-c:v "$VIDEO_CODEC" -preset 4 -crf "$VIDEO_CRF" -svtav1-params "tune=0:enable-overlays=1:scd=1")
            else
              # Fast/Lossy: Preset 8.
              v_args=(-c:v "$VIDEO_CODEC" -preset 8 -crf "$((VIDEO_CRF + 6))" -svtav1-params "tune=0:scd=1")
            fi ;;
          libaom-av1)
            # cpu-used: 0-8 (Lower=Slower/Better). usage=good/realtime.
            if [[ "$LOSSLESS" -eq 1 ]]; then
              # Deep compression
              v_args=(-c:v "$VIDEO_CODEC" -cpu-used 3 -usage good -row-mt 1 -crf "$VIDEO_CRF" -b:v 0)
            else
              # Faster
              v_args=(-c:v "$VIDEO_CODEC" -cpu-used 6 -usage good -row-mt 1 -crf "$((VIDEO_CRF + 6))" -b:v 0)
            fi ;;
          libvpx-vp9)
             # cpu-used: 0-5. deadline: best/good.
             if [[ "$LOSSLESS" -eq 1 ]]; then
               v_args=(-c:v "$VIDEO_CODEC" -cpu-used 1 -row-mt 1 -deadline best -crf "$VIDEO_CRF" -b:v 0)
             else
               v_args=(-c:v "$VIDEO_CODEC" -cpu-used 3 -row-mt 1 -deadline good -crf "$((VIDEO_CRF + 6))" -b:v 0)
             fi ;;
          libx265)
             # HEVC: preset (veryslow..ultrafast)
             if [[ "$LOSSLESS" -eq 1 ]]; then
               v_args=(-c:v "$VIDEO_CODEC" -preset slower -crf "$VIDEO_CRF" -x265-params "sao=1:strong-intra-smoothing=1")
             else
               v_args=(-c:v "$VIDEO_CODEC" -preset medium -crf "$((VIDEO_CRF + 4))")
             fi ;;
          libx264)
             # H.264
             if [[ "$LOSSLESS" -eq 1 ]]; then
               v_args=(-c:v "$VIDEO_CODEC" -preset veryslow -tune film -crf "$VIDEO_CRF")
             else
               v_args=(-c:v "$VIDEO_CODEC" -preset medium -tune film -crf "$((VIDEO_CRF + 4))")
             fi ;;
          *) v_args=(-c:v "$VIDEO_CODEC" -crf "$VIDEO_CRF") ;; # Generic Fallback
        esac
        cmd=(ffmpeg -y -v error -i "$file" "${v_args[@]}" "${a_args[@]}" -movflags +faststart "$tmp_out")
      fi ;;
    *) return 0 ;;
  esac
  # 2. Execution Wrapper
  [[ -z "$tool" ]] && return 0
  local original_size=$(stat -c%s "$file")
  # Dry Run
  [[ "$DRY_RUN" -eq 1 ]] && { printf "${B}[DRY]${X} %-12s %s\n" "$tool" "$file"; return 0; }
  # Run optimization
  local success=0
  if [[ "$tool" == "rimage" ]]; then
    if "${cmd[@]}" &>/dev/null; then success=1; fi
  elif [[ "$tool" == "image-optimizer" ]] || [[ "$tool" == "svgcleaner" ]] || [[ "$tool" == "scour" ]] || [[ "$tool" == "optipng" ]] || [[ "$tool" == "ffmpeg" ]] || [[ "$tool" == "ffzap" ]] || [[ "$tool" == "minify" ]]; then
    if "${cmd[@]}" &>/dev/null; then success=1; fi
  else
    # Tools writing to stdout
    if "${cmd[@]}" > "$tmp_out" 2>/dev/null; then success=1; fi
  fi
  [[ $success -eq 0 ]] && { rm -f "$tmp_out"; return 1; }
  # 3. Size Guard & Atomic Replace
  if [[ -f "$tmp_out" ]]; then
    local new_size=$(stat -c%s "$tmp_out")
    if [[ $new_size -gt 0 ]] && [[ $new_size -lt $original_size ]]; then
      local diff=$((original_size - new_size))
      local percent=$((diff * 100 / original_size))
      if [[ "$BACKUP" -eq 1 ]]; then
        local backup_path="${BACKUP_DIR}/${file#.}"
        mkdir -p "$(dirname "$backup_path")"
        cp -p "$file" "$backup_path"
      fi
      mv "$tmp_out" "$file"
      if [[ "$KEEP_MTIME" -eq 1 ]]; then touch -r "$file" "$file"; fi
      printf "${G}[OK]${X}  %-25s %-10s -%d%% (%s saved)\n" "$(basename "$file")" "[$tool]" "$percent" "$(numfmt --to=iec $diff)"
    else
      printf "${Y}[SKIP]${X} %-25s %-10s (No savings)\n" "$(basename "$file")" "[$tool]"
      rm -f "$tmp_out"
    fi
  fi
}
export -f optimize_file has err
export JOBS QUALITY LOSSLESS VIDEO_CODEC VIDEO_CRF AUDIO_CODEC AUDIO_BR
export DRY_RUN BACKUP BACKUP_DIR KEEP_MTIME TMP_DIR B G Y R X

# ==============================================================================
# MAIN
# ==============================================================================
INPUT_PATHS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -j|--jobs)      JOBS="$2"; shift 2 ;;
    -l|--lossy)     LOSSLESS=0; shift ;;
    -q|--quality)   QUALITY="$2"; shift 2 ;;
    --crf)          VIDEO_CRF="$2"; shift 2 ;;
    --vcodec)       VIDEO_CODEC="$2"; shift 2 ;;
    --acodec)       AUDIO_CODEC="$2"; shift 2 ;;
    --backup)       BACKUP=1; shift ;;
    --dry-run)      DRY_RUN=1; shift ;;
    -h|--help)      usage ;;
    *)              INPUT_PATHS+=("$1"); shift ;;
  esac
done

[[ ${#INPUT_PATHS[@]} -eq 0 ]] && INPUT_PATHS=("(current dir)") && set -- "." 
[[ ${#INPUT_PATHS[@]} -gt 0 ]] && set -- "${INPUT_PATHS[@]}"
if [[ "$BACKUP" -eq 1 ]]; then
  mkdir -p "$BACKUP_DIR"
  log "Backup: $BACKUP_DIR"
fi
log "Starting... (Jobs: $JOBS | Lossless: $LOSSLESS | Video: $VIDEO_CODEC)"
TOOLS_FOUND=""
for t in rimage image-optimizer ffzap ffmpeg svgcleaner scour minify gifsicle; do
  if has "$t"; then TOOLS_FOUND+="$t "; fi
done
log "Active Tools: ${TOOLS_FOUND:-None}"
EXT_REGEX=".*\.\(jpg\|jpeg\|png\|webp\|svg\|gif\|avif\|jxl\|bmp\|mp4\|mkv\|mov\|webm\|avi\)$"
FIND_CMD="find \"$@\" -type f -iregex \"$EXT_REGEX\" -not -path '*/.*'"

if has rust-parallel; then
  eval "$FIND_CMD" | rust-parallel -j "$JOBS" -- 'optimize_file {}'
elif has parallel; then
  eval "$FIND_CMD" | parallel -j "$JOBS" --no-notice "optimize_file {}"
else
  eval "$FIND_CMD -print0" | xargs -0 -P "$JOBS" -I {} bash -c 'optimize_file "$@"' _ {}
fi
log "Done."
