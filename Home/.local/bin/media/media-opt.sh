#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'
export LC_ALL=C LANG=C HOME="/home/${SUDO_USER:-$USER}"
# ==============================================================================
# CONFIGURATION
# ==============================================================================
: "${JOBS:=$(nproc 2>/dev/null || echo 4)}" "${DRY_RUN:=0}" "${BACKUP:=0}" "${KEEP_MTIME:=1}"
: "${BACKUP_DIR:=${HOME}/.cache/media-opt/backups/$(printf '%(%Y%m%d_%H%M%S)T' -1)}"
: "${LOSSLESS:=1}" "${QUALITY:=95}" "${VIDEO_CRF:=24}"
: "${VIDEO_CODEC:=libsvtav1}" "${AUDIO_CODEC:=libopus}" "${AUDIO_BR:=128k}"

R=$'\e[31m' G=$'\e[32m' Y=$'\e[33m' B=$'\e[34m' X=$'\e[0m'
log() { printf "${B}[%(%H:%M:%S)T]${X} %s\n" -1 "$*"; }
err() { printf "${R}[ERR]${X} %s\n" "$*" >&2; }
has() { command -v "$1" &>/dev/null; }
usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [PATH...]
Batch Mode:
  -j, --jobs N      Jobs (Default: $JOBS)
  -l, --lossy       Lossy Mode (Default: Lossless)
  -q, --quality N   Quality 1-100 (Default: $QUALITY)
  --crf N           Video CRF (Default: $VIDEO_CRF)
  --vcodec CODEC    Video Codec (Default: $VIDEO_CODEC)
  --acodec CODEC    Audio Codec (Default: $AUDIO_CODEC)
  --backup          Enable Backup
  --dry-run         Simulate
  -h, --help        Show this help message
Interactive Mode:
  -i, --interactive  Interactive conversion menu
EOF
  exit 0
}

# ==============================================================================
# INTERACTIVE MODE (yor-mc-lite integration)
# ==============================================================================
interactive_mode() {
  has ffmpeg || {
    err "ffmpeg required for interactive mode"
    exit 1
  }
  local input_path
  while :; do
    clear
    log "Media Conversion Tool"
    read -r -p "Input file (or drag & drop, q to quit): " input_path
    [[ "$input_path" == "q" ]] && break
    input_path="${input_path//\'/}"                             # Remove single quotes
    input_path="${input_path#\'}" input_path="${input_path%\'}" # Trim quotes
    input_path="${input_path#\"}" input_path="${input_path%\"}"
    [[ -f "$input_path" ]] || {
      err "File not found"
      sleep 2
      continue
    }

    local input_file="${input_path##*/}"
    local ext="${input_file##*.}"
    local convert_ext=""
    local -a vf_opts=()

    # Target format menu
    local -a targets
    case "${ext,,}" in
    gif) targets=("mkv" "mp4" "webm" "webp" "Format only" "Back") ;;
    mp4 | mkv | webm | webp) targets=("gif" "mkv" "mp4" "webm" "webp" "Format only" "Back") ;;
    *)
      err "Unsupported input format: $ext"
      sleep 2
      continue
      ;;
    esac

    PS3=$'\n'"${B}Convert ${input_file} to?${X} "
    select choice in "${targets[@]}"; do
      case "$choice" in
      "Back") break ;;
      "Format only")
        convert_ext="$ext"
        break
        ;;
      "")
        err "Invalid choice"
        continue
        ;;
      *)
        convert_ext="$choice"
        break
        ;;
      esac
    done
    [[ "$choice" == "Back" ]] && continue

    # Options menu
    local -a options=("True size" "50%" "75%" "Square (500px)" "HQ Lanczos" "Rotate 90° CW" "Rotate 90° CCW" "Vertical Flip" "Done")
    while :; do
      clear
      log "Options for: ${input_file} -> ${convert_ext}"
      printf "${Y}Selected Filters: %s${X}\n" "${vf_opts[*]:-(none)}"
      PS3=$'\n'"${B}Add filter?${X} "
      select opt in "${options[@]}"; do
        case "$opt" in
        "True size") vf_opts+=("scale=iw:ih") ;;
        "50%") vf_opts+=("scale=iw/2:ih/2") ;;
        "75%") vf_opts+=("scale=iw*0.75:ih*0.75") ;;
        "Square (500px)") vf_opts+=("scale=500:500") ;;
        "HQ Lanczos") vf_opts+=("flags=lanczos") ;;
        "Rotate 90° CW") vf_opts+=("transpose=1") ;;
        "Rotate 90° CCW") vf_opts+=("transpose=2") ;;
        "Vertical Flip") vf_opts+=("vflip") ;;
        "Done") break 2 ;;
        *) err "Invalid choice" ;;
        esac
        break
      done
    done

    # Perform conversion
    local out_dir="${input_path%/*}"
    local out_file="${out_dir}/${input_file%.*}-mc.${convert_ext}"
    local vf_flags
    IFS=, vf_flags="${vf_opts[*]}"

    log "Converting..."
    local -a cmd=(ffmpeg -y -hide_banner -i "$input_path")

    if [[ "${ext,,}" == "gif" && "$convert_ext" != "gif" ]]; then
      local palette="${out_dir}/palette.png"
      ffmpeg -i "$input_path" -vf "palettegen" -y "$palette" &>/dev/null
      cmd+=(-i "$palette" -lavfi "${vf_flags:+$vf_flags,}paletteuse")
    else
      [[ "$convert_ext" == "gif" ]] && vf_flags="fps=30${vf_flags:+,${vf_flags}}"
      [[ -n "$vf_flags" ]] && cmd+=(-vf "$vf_flags")
    fi

    cmd+=("$out_file")
    "${cmd[@]}"

    [[ -f "${palette:-}" ]] && rm -f "$palette"
    log "Done: $out_file"
    read -r -p "Press ENTER to continue..."
  done
}

# ==============================================================================
# BATCH OPTIMIZATION
# ==============================================================================
opt_img() {
  local f="$1" out="$2" ext="${f##*.}" l_ext="${ext,,}"
  if has rimage; then
    tool="rimage"
    cp "$f" "$out"
    [[ $LOSSLESS -eq 1 ]] && cmd=(rimage "$out" -q 100) || cmd=(rimage "$out" -q "$QUALITY")
  elif has image-optimizer && [[ "$l_ext" =~ ^(jpg|jpeg|png|webp)$ ]]; then
    tool="image-optimizer"
    cmd=(image-optimizer "$f" "$out")
  else
    case "$l_ext" in
    jpg | jpeg | mjpg) has jpegoptim && {
      tool="jpegoptim"
      cmd=(jpegoptim --strip-all --all-progressive --stdout "$f")
      [[ $LOSSLESS -eq 0 ]] && cmd+=(-m"$QUALITY")
    } ;;
    png) has oxipng && {
      tool="oxipng"
      cmd=(oxipng -o 4 --strip safe -i 0 --out - "$f")
    } ;;
    webp) has cwebp && {
      tool="cwebp"
      cmd=(cwebp -mt -quiet "$f" -o -)
      [[ $LOSSLESS -eq 1 ]] && cmd+=(-lossless -z 9) || cmd+=(-q "$QUALITY" -m 6)
    } ;;
    esac
  fi
}

opt_svg() {
  local f="$1" out="$2"
  if has image-optimizer; then
    tool="image-optimizer"
    cmd=(image-optimizer "$f" "$out")
  elif has svgcleaner; then
    tool="svgcleaner"
    cmd=(svgcleaner "$f" "$out")
  elif has scour; then
    tool="scour"
    cmd=(scour -i "$f" -o "$out" --enable-viewboxing --enable-id-stripping --shorten-ids --indent=none)
  elif has minify; then
    tool="minify"
    cmd=(minify -o "$out" "$f")
  elif has svgo; then
    tool="svgo"
    cmd=(svgo -i "$f" -o - --multipass)
  fi
}

opt_vid() {
  local f="$1" out="$2"
  local a_args=(-c:a "$AUDIO_CODEC" -b:a "$AUDIO_BR")
  [[ "$AUDIO_CODEC" == "copy" ]] && a_args=(-c:a copy)
  if has ffzap; then
    tool="ffzap"
    cmd=(ffzap -i "$f" -o "$out")
  elif has ffmpeg; then
    tool="ffmpeg"
    local v_args=()
    case "$VIDEO_CODEC" in
    libsvtav1) [[ $LOSSLESS -eq 1 ]] && v_args=(-preset 4 -crf "$VIDEO_CRF" -svtav1-params "tune=0:enable-overlays=1:scd=1") || v_args=(-preset 8 -crf "$((VIDEO_CRF + 6))" -svtav1-params "tune=0:scd=1") ;;
    libaom-av1) [[ $LOSSLESS -eq 1 ]] && v_args=(-cpu-used 3 -usage good -row-mt 1 -crf "$VIDEO_CRF" -b:v 0) || v_args=(-cpu-used 6 -usage good -row-mt 1 -crf "$((VIDEO_CRF + 6))" -b:v 0) ;;
    libx265) [[ $LOSSLESS -eq 1 ]] && v_args=(-preset slower -crf "$VIDEO_CRF" -x265-params "sao=1") || v_args=(-preset medium -crf "$((VIDEO_CRF + 4))") ;;
    *) v_args=(-crf "$VIDEO_CRF") ;;
    esac
    cmd=(ffmpeg -y -v error -i "$f" -c:v "$VIDEO_CODEC" "${v_args[@]}" "${a_args[@]}" -movflags +faststart "$out")
  fi
}

optimize_file() {
  local f="$1"
  [[ ! -f "$f" ]] && return 0
  local ext="${f##*.}" tmp="${f}.opt.tmp.${ext}" tool="" cmd=()
  case "${ext,,}" in
  jpg | jpeg | mjpg | png | webp | avif | jxl | bmp) opt_img "$f" "$tmp" ;;
  svg) opt_svg "$f" "$tmp" ;;
  gif) has gifsicle && {
    tool="gifsicle"
    cmd=(gifsicle "$f")
    [[ $LOSSLESS -eq 1 ]] && cmd+=(-O3 --no-comments --no-names --no-extensions --careful) || cmd+=(-O3 --lossy=80)
  } ;;
  mp4 | mkv | mov | avi | webm) opt_vid "$f" "$tmp" ;;
  *) return 0 ;;
  esac
  [[ -z "$tool" ]] && {
    [[ -f "$tmp" ]] && rm -f "$tmp"
    return 0
  }
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf "${B}[DRY]${X} %-10s %s\n" "$tool" "$f"
    [[ -f "$tmp" ]] && rm -f "$tmp"
    return 0
  fi
  local ok=0
  if [[ "$tool" =~ ^(oxipng|cwebp|svgo|jpegoptim)$ ]] && [[ "${cmd[*]}" =~ (--stdout|--out\ -|-o\ -) ]]; then
    "${cmd[@]}" >"$tmp" 2>/dev/null && ok=1
  else
    "${cmd[@]}" >/dev/null 2>&1 && ok=1
  fi
  if [[ $ok -eq 1 ]] && [[ -f "$tmp" ]]; then
    local old_sz new_sz
    old_sz=$(stat -c%s "$f")
    new_sz=$(stat -c%s "$tmp")
    if [[ $new_sz -gt 0 ]] && [[ $new_sz -lt $old_sz ]]; then
      local diff=$((old_sz - new_sz)) pct=$((diff * 100 / old_sz))
      if [[ "$BACKUP" -eq 1 ]]; then
        local bp="${BACKUP_DIR}/${f#.}"
        mkdir -p "$(dirname "$bp")"
        cp -p "$f" "$bp"
      fi
      mv "$tmp" "$f"
      [[ "$KEEP_MTIME" -eq 1 ]] && touch -r "$f" "$f"
      printf "${G}[OK]${X} %-25s %-12s -%d%% (%s)\n" "$(basename "$f")" "[$tool]" "$pct" "$(numfmt --to=iec "$diff")"
    else
      rm -f "$tmp"
    fi
  else
    [[ -f "$tmp" ]] && rm -f "$tmp"
  fi
}
export -f optimize_file opt_img opt_svg opt_vid has err log
export JOBS QUALITY LOSSLESS VIDEO_CODEC VIDEO_CRF AUDIO_CODEC AUDIO_BR DRY_RUN BACKUP BACKUP_DIR KEEP_MTIME B G Y R X

# ==============================================================================
# MAIN
# ==============================================================================
main() {
  local -a inputs=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -i | --interactive)
      interactive_mode
      exit 0
      ;;
    -j | --jobs)
      JOBS="$2"
      shift 2
      ;;
    -l | --lossy)
      LOSSLESS=0
      shift
      ;;
    -q | --quality)
      QUALITY="$2"
      shift 2
      ;;
    --crf)
      VIDEO_CRF="$2"
      shift 2
      ;;
    --vcodec)
      VIDEO_CODEC="$2"
      shift 2
      ;;
    --acodec)
      AUDIO_CODEC="$2"
      shift 2
      ;;
    --backup)
      BACKUP=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h | --help) usage ;;
    -*)
      err "Unknown option: $1"
      usage
      ;;
    *)
      inputs+=("$1")
      shift
      ;;
    esac
  done

  if [[ ${#inputs[@]} -eq 0 ]]; then
    inputs=(".")
  fi

  if [[ "$BACKUP" -eq 1 ]]; then
    mkdir -p "$BACKUP_DIR"
    log "Backups enabled: $BACKUP_DIR"
  fi

  log "Starting optimization ($JOBS jobs, Video Codec: $VIDEO_CODEC)..."

  local -a find_cmd
  local exts_regex=".*\.(jpg|jpeg|mjpg|png|webp|svg|gif|avif|jxl|bmp|mp4|mkv|mov|webm|avi)$"

  if has fd; then
    find_cmd=(fd --type f --hidden --no-ignore --regex "$exts_regex" -- . "${inputs[@]}")
  else
    find_cmd=(find "${inputs[@]}" -type f -iregex "$exts_regex")
  fi

  local -a parallel_cmd
  if has rust-parallel; then
    parallel_cmd=(rust-parallel -j "$JOBS" -- 'optimize_file {}')
  elif has parallel; then
    parallel_cmd=(parallel -j "$JOBS" --no-notice "optimize_file {}")
  else
    parallel_cmd=(xargs -0 -P "$JOBS" -I {} bash -c 'optimize_file "$@"' _ {})
    # Adjust find command for xargs -0
    if has fd; then
      find_cmd+=(--print0)
    else
      find_cmd+=(-print0)
    fi
  fi

  "${find_cmd[@]}" | "${parallel_cmd[@]}"

  log "Done."
}

main "$@"
