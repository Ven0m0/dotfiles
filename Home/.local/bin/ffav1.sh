#!/usr/bin/env bash
#
# SVT-AV1 Smart Encoder
# Logic: Scan -> Filter (Skip AV1) -> Encode (ffzap or ffmpeg)
#
# Usage: ./encode.sh [path]

set -euo pipefail
shopt -s nullglob globstar

# --- Configuration ---
readonly MAX_JOBS=1 # For fallback mode (Preset 3 is heavy)
readonly OUT_SUFFIX="_av1"
readonly TARGET_EXT="mkv"

# --- Dependencies ---
export LC_ALL=C
export IFS=$'\n\t'

has(){ command -v -- "$1" &>/dev/null; }

# --- Logging ---
log(){ printf '[%s] %s\n' "$(date +'%H:%M:%S')" "$*"; }
err(){ printf '[%s] [ERR] %s\n' "$(date +'%H:%M:%S')" "$*" >&2; }

# --- Helpers ---
is_av1(){
  local src="$1"
  local codec
  codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$src" || echo "err")
  [[ "$codec" == "av1" ]]
}

# --- Engines ---
run_ffzap(){
  local list_file="$1"
  local ffmpeg_args="$2"
  
  # ffzap template: {{dir}} preserves relative path, {{name}} is filename no ext
  # Note: verify your ffzap version supports {{dir}}. If not, this puts files in CWD.
  log "Engine: ffzap detected. Batch processing..."
  
  # We pass the complex args. ffzap expects them as a single string.
  # The filter string inside ffmpeg_args is already quoted for bash.
  ffzap \
    --file-list "$list_file" \
    --overwrite \
    -f "$ffmpeg_args" \
    -o "{{dir}}/{{name}}${OUT_SUFFIX}.${TARGET_EXT}"
}

run_ffmpeg_loop(){
  local -n targets=$1
  local ffmpeg_args="$2"
  local active_jobs=0

  log "Engine: ffmpeg fallback. Starting job queue (Max: $MAX_JOBS)..."

  for src in "${targets[@]}"; do
    local dir base out
    dir="$(dirname "$src")"
    base="$(basename "$src")"
    base="${base%.*}"
    out="${dir}/${base}${OUT_SUFFIX}.${TARGET_EXT}"

    log "Encoding: $src"
    
    # Run in background
    (
      # shellcheck disable=SC2086
      if ffmpeg -v error -stats -hide_banner -nostdin -y -i "$src" $ffmpeg_args "$out"; then
        log "Done: $out"
      else
        err "Failed: $src"
        [[ -f "$out" ]] && rm -f "$out"
      fi
    ) &
    
    ((active_jobs++))
    if ((active_jobs >= MAX_JOBS)); then
      wait -n
      ((active_jobs--))
    fi
  done
  wait
}

main(){
  local target="${1:-.}"
  
  if ! has ffmpeg || ! has ffprobe; then
    err "Missing ffmpeg or ffprobe."
    exit 1
  fi

  # 1. Scan
  log "Scanning for video files in: $target"
  local candidates=()
  if has fd; then
    mapfile -t candidates < <(fd -t f -e mkv -e mp4 -e mov -e avi -e webm . "$target")
  else
    while IFS= read -r f; do candidates+=("$f"); done < <(find "$target" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.mov" -o -name "*.avi" -o -name "*.webm" \))
  fi

  if [[ ${#candidates[@]} -eq 0 ]]; then
    err "No files found."
    exit 0
  fi

  # 2. Filter (Skip AV1 & Existing)
  local valid_targets=()
  for f in "${candidates[@]}"; do
    # Skip if output file
    if [[ "$f" == *"${OUT_SUFFIX}.${TARGET_EXT}" ]]; then continue; fi
    
    # Check output existence
    local base="${f%.*}"
    local out="${base}${OUT_SUFFIX}.${TARGET_EXT}"
    if [[ -f "$out" ]]; then
      # log "Skip (Exists): $f"
      continue
    fi

    # Check Codec
    if is_av1 "$f"; then
      log "Skip (Already AV1): $f"
      continue
    fi

    valid_targets+=("$f")
  done

  if [[ ${#valid_targets[@]} -eq 0 ]]; then
    log "All files processed or skipped."
    exit 0
  fi

  log "Queued ${#valid_targets[@]} files."

  # 3. Define Flags (Shared)
  # Quoting: We store complex filter in a variable to keep it safe.
  # NOTE: The filter string is complex. 'scale=...' has single quotes.
  # We wrap the whole filter arg in double quotes for the command line.
  local filter_complex="scale='if(gt(iw,ih),min(1920,iw),-2)':'if(gt(iw,ih),-2,min(1920,ih))',deband"
  
  # Construct argument string. 
  # For run_ffmpeg_loop: We rely on word splitting for flags, but quote the filter.
  # For run_ffzap: It takes one string.
  
  local args="-c:v libsvtav1 -preset 3 -crf 32 -g 600 -pix_fmt yuv420p10le -svtav1-params film-grain=8:enable-qm=1:qm-min=0 -vf \"$filter_complex\" -c:a libopus -b:a 96k -ac 2 -rematrix_maxval 1.0 -map_metadata 0 -f mkv"

  # 4. Execute
  if has ffzap; then
    # Write targets to temp file for ffzap
    local list_file
    list_file=$(mktemp)
    printf '%s\n' "${valid_targets[@]}" > "$list_file"
    
    run_ffzap "$list_file" "$args"
    rm -f "$list_file"
  else
    # Fallback
    run_ffmpeg_loop valid_targets "$args"
  fi
}

main "$@"
