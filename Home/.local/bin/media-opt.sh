#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar
IFS=$' \n\t'; export LC_ALL=C LANG=C HOME="/home/${SUDO_USER:-$USER}"
# ==============================================================================
# MEDIA OPTIMIZER (Universal)
# ==============================================================================
# Features:
# - No global tmp dir (In-place atomic temp files)
# - FD/Find Discovery (Fastest available)
# - Native Rust Tool Priority
# - Deep Codec Optimization (AV1/HEVC/VP9)
# ==============================================================================
# CONFIGURATION
# ==============================================================================
: "${VERSION:=7.1.0}"
: "${JOBS:=$(nproc 2>/dev/null || echo 4)}"
: "${DRY_RUN:=0}"
: "${BACKUP:=0}"
: "${KEEP_MTIME:=1}"
# Optimized date generation using printf instead of external date binary
: "${BACKUP_DIR:=${HOME}/.cache/media-opt/backups/$(printf '%(%Y%m%d_%H%M%S)T' -1)}"
# Optimization Levels
: "${LOSSLESS:=1}"        # 1=Lossless (default), 0=Lossy
: "${QUALITY:=100}"       # 1-100 (100 implies lossless/best)
: "${VIDEO_CRF:=24}"      # Video Quality (Lower=Better, 20-30 range)
# Codecs
: "${VIDEO_CODEC:=libsvtav1}" # libsvtav1, libaom-av1, libvpx-vp9, libx265
: "${AUDIO_CODEC:=libopus}"
: "${AUDIO_BR:=128k}"
# Colors
R=$'\e[31m' G=$'\e[32m' Y=$'\e[33m' B=$'\e[34m' X=$'\e[0m'

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================
trap 'exit' EXIT INT TERM
log(){ printf "${B}[%(%H:%M:%S)T]${X} %s\n" -1 "$*"; }
warn(){ printf "${Y}[WARN]${X} %s\n" "$*"; }
err(){ printf "${R}[ERR]${X} %s\n" "$*" >&2; }
has(){ command -v "$1" >/dev/null 2>&1; }
usage(){
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [PATH...]

Ultra-optimized media compressor.
Prioritizes: fd > find, rimage/image-optimizer > parallel dispatch.
Avoids mktemp; uses atomic in-place temp files.

Options:
  -j, --jobs N        Parallel jobs (Default: $JOBS)
  -l, --lossy         Enable lossy mode (Default: Lossless)
  -q, --quality N     Target Quality 1-100 (Default: $QUALITY)
  --crf N             Video CRF (Default: $VIDEO_CRF)
  --vcodec STR        Video Codec (Default: $VIDEO_CODEC)
  --acodec STR        Audio Codec (Default: $AUDIO_CODEC)
  --backup            Backup original files
  --dry-run           Simulate execution
  -h, --help          Show this help
EOF
  exit 0
}

# ==============================================================================
# FILE OPTIMIZER (Single File)
# ==============================================================================
optimize_file(){
  local file="$1" cmd=() tool=""
  [[ ! -f "$file" ]] && return 0
  local ext="${file##*.}"; local lc_ext="${ext,,}"
  # Atomic temp file alongside original
  local tmp_out="${file}.opt.tmp.${ext}"
  # 1. Select Tool
  case "$lc_ext" in
    # Raster Images
    jpg|jpeg|mjpg|png|webp|avif|jxl|bmp)
      if has rimage; then
        tool="rimage"
        cp "$file" "$tmp_out"
        [[ "$LOSSLESS" -eq 1 ]] && cmd=(rimage "$tmp_out" --quality 100) || cmd=(rimage "$tmp_out" --quality "$QUALITY")
      elif has image-optimizer && [[ "$lc_ext" =~ ^(jpg|jpeg|png|webp)$ ]]; then
        tool="image-optimizer"
        cmd=(image-optimizer "$file" "$tmp_out")
      else
        # Fallbacks
        case "$lc_ext" in
          jpg|jpeg|mjpg)
            if has jpegoptim; then
              tool="jpegoptim"
              local args=(--strip-all --all-progressive --stdout)
              [[ "$LOSSLESS" -eq 0 ]] && args+=(-m"$QUALITY")
              cmd=(jpegoptim "${args[@]}" "$file")
            elif has mozjpeg; then
              tool="mozjpeg"
              cmd=(mozjpeg -quality "$QUALITY" -progressive "$file")
            fi
            ;;
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
              [[ "$LOSSLESS" -eq 1 ]] && args=(-lossless -z 9) || args=(-q "$QUALITY" -m 6)
              cmd=(cwebp "${args[@]}" -mt -quiet "$file" -o -)
            fi ;;
        esac
      fi ;;
    # Vector (SVG)
    svg)
      if has image-optimizer; then
        tool="image-optimizer"; cmd=(image-optimizer "$file" "$tmp_out")
      elif has svgcleaner; then
        tool="svgcleaner"; cmd=(svgcleaner "$file" "$tmp_out")
      elif has scour; then
        tool="scour"; cmd=(scour -i "$file" -o "$tmp_out" --enable-viewboxing --enable-id-stripping --shorten-ids --indent=none)
      elif has minify; then
        tool="minify"; cmd=(minify -o "$tmp_out" "$file")
      elif has svgo; then
        tool="svgo"; cmd=(svgo -i "$file" -o - --multipass)
      fi
      ;;

    # GIF
    gif)
      if has gifsicle; then
        tool="gifsicle"
        local args=(-O3 --careful)
        [[ "$LOSSLESS" -eq 0 ]] && args=(-O3 --lossy=80)
        cmd=(gifsicle "${args[@]}" "$file")
      fi
      ;;

    # Video/Audio
    mp4|mkv|mov|avi|webm)
      local a_args=(-c:a "$AUDIO_CODEC" -b:a "$AUDIO_BR")
      [[ "$AUDIO_CODEC" == "copy" ]] && a_args=(-c:a copy)

      if has ffzap; then
        tool="ffzap"
        cmd=(ffzap -i "$file" -o "$tmp_out")
      elif has ffmpeg; then
        tool="ffmpeg"
        local v_args=()
        case "$VIDEO_CODEC" in
          libsvtav1)
            [[ "$LOSSLESS" -eq 1 ]] && v_args=(-c:v "$VIDEO_CODEC" -preset 4 -crf "$VIDEO_CRF" -svtav1-params "tune=0:enable-overlays=1:scd=1") || v_args=(-c:v "$VIDEO_CODEC" -preset 8 -crf "$((VIDEO_CRF + 6))" -svtav1-params "tune=0:scd=1")
            ;;
          libaom-av1)
            [[ "$LOSSLESS" -eq 1 ]] && v_args=(-c:v "$VIDEO_CODEC" -cpu-used 3 -usage good -row-mt 1 -crf "$VIDEO_CRF" -b:v 0) || v_args=(-c:v "$VIDEO_CODEC" -cpu-used 6 -usage good -row-mt 1 -crf "$((VIDEO_CRF + 6))" -b:v 0)
            ;;
          libvpx-vp9)
             [[ "$LOSSLESS" -eq 1 ]] && v_args=(-c:v "$VIDEO_CODEC" -cpu-used 1 -row-mt 1 -deadline best -crf "$VIDEO_CRF" -b:v 0) || v_args=(-c:v "$VIDEO_CODEC" -cpu-used 3 -row-mt 1 -deadline good -crf "$((VIDEO_CRF + 6))" -b:v 0)
             ;;
          libx265)
             [[ "$LOSSLESS" -eq 1 ]] && v_args=(-c:v "$VIDEO_CODEC" -preset slower -crf "$VIDEO_CRF" -x265-params "sao=1:strong-intra-smoothing=1") || v_args=(-c:v "$VIDEO_CODEC" -preset medium -crf "$((VIDEO_CRF + 4))")
             ;;
          *) v_args=(-c:v "$VIDEO_CODEC" -crf "$VIDEO_CRF") ;;
        esac
        cmd=(ffmpeg -y -v error -i "$file" "${v_args[@]}" "${a_args[@]}" -movflags +faststart "$tmp_out")
      fi
      ;;
    *) return 0 ;;
  esac

  # 2. Execute
  if [[ -z "$tool" ]]; then
    [[ -f "$tmp_out" ]] && rm -f "$tmp_out"
    return 0
  fi

  local original_size=$(stat -c%s "$file")

  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf "${B}[DRY]${X} %-12s %s\n" "$tool" "$file"
    [[ -f "$tmp_out" ]] && rm -f "$tmp_out"
    return 0
  fi

  local success=0
  if [[ "$tool" == "rimage" ]]; then
    if "${cmd[@]}" >/dev/null 2>&1; then success=1; fi
  elif [[ "$tool" == "image-optimizer" || "$tool" == "svgcleaner" || "$tool" == "scour" || "$tool" == "optipng" || "$tool" == "ffmpeg" || "$tool" == "ffzap" || "$tool" == "minify" ]]; then
    if "${cmd[@]}" >/dev/null 2>&1; then success=1; fi
  else
    if "${cmd[@]}" > "$tmp_out" 2>/dev/null; then success=1; fi
  fi

  if [[ $success -eq 0 ]]; then
    rm -f "$tmp_out"
    return 1
  fi

  # 3. Size Guard & Atomic Replace
  if [[ -f "$tmp_out" ]]; then
    local new_size=$(stat -c%s "$tmp_out")
    if [[ $new_size -gt 0 && $new_size -lt $original_size ]]; then
      local diff=$((original_size - new_size))
      local percent=$((diff * 100 / original_size))
      
      if [[ "$BACKUP" -eq 1 ]]; then
        local bp="${BACKUP_DIR}/${file#.}"
        mkdir -p "$(dirname "$bp")"
        cp -p "$file" "$bp"
      fi

      mv "$tmp_out" "$file"
      [[ "$KEEP_MTIME" -eq 1 ]] && touch -r "$file" "$file"
      printf "${G}[OK]${X}  %-25s %-10s -%d%% (%s saved)\n" "$(basename "$file")" "[$tool]" "$percent" "$(numfmt --to=iec "$diff")"
    else
      rm -f "$tmp_out"
    fi
  else
    rm -f "$tmp_out"
  fi
}

export -f optimize_file has err
export JOBS QUALITY LOSSLESS VIDEO_CODEC VIDEO_CRF AUDIO_CODEC AUDIO_BR
export DRY_RUN BACKUP BACKUP_DIR KEEP_MTIME B G Y R X

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

# --- FILE DISCOVERY (FD > FIND) ---
EXTS="jpg,jpeg,mjpg,png,webp,svg,gif,avif,jxl,bmp,mp4,mkv,mov,webm,avi"

if has fd; then
  FD_ARGS=()
  IFS=',' read -ra E_ARR <<< "$EXTS"
  for e in "${E_ARR[@]}"; do FD_ARGS+=("-e" "$e"); done
  FIND_CMD="fd --type f --follow --hidden --exclude .git ${FD_ARGS[@]} . \"$@\""
elif has fdfind; then
  FD_ARGS=()
  IFS=',' read -ra E_ARR <<< "$EXTS"
  for e in "${E_ARR[@]}"; do FD_ARGS+=("-e" "$e"); done
  FIND_CMD="fdfind --type f --follow --hidden --exclude .git ${FD_ARGS[@]} . \"$@\""
else
  REGEX=".*\.\(${EXTS//,/\|}\)$"
  FIND_CMD="find \"$@\" -type f -iregex \"$REGEX\" -not -path '*/.*'"
fi

# --- EXECUTION ---
if has rust-parallel; then
  eval "$FIND_CMD" | rust-parallel -j "$JOBS" -- 'optimize_file {}'
elif has parallel; then
  eval "$FIND_CMD" | parallel -j "$JOBS" --no-notice "optimize_file {}"
else
  eval "$FIND_CMD -print0" | xargs -0 -P "$JOBS" -I {} bash -c 'optimize_file "$@"' _ {}
fi

log "Done."
