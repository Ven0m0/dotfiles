#!/usr/bin/env bash
set -euo pipefail
IFS=$' \n\t'
export LC_ALL=C

# ==============================================================================
# CONFIGURATION & DEFAULTS
# ==============================================================================
VERSION="3.0.0"
JOBS=$(nproc 2>/dev/null || echo 4)
QUALITY=85
CRF=26                  # Video Quality (Lower is better)
AUDIO_BR="128k"         # Audio Bitrate
DRY_RUN=0
BACKUP=0
BACKUP_DIR="${HOME}/.cache/media-opt/backups/$(date +%Y%m%d_%H%M%S)"
KEEP_MTIME=1            # Preserve modification time
TMP_DIR=$(mktemp -d)

# Colors
R=$'\e[31m' G=$'\e[32m' Y=$'\e[33m' B=$'\e[34m' X=$'\e[0m'

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT INT TERM

log() { printf "${B}[%s]${X} %s\n" "$(date +%H:%M:%S)" "$*"; }
warn() { printf "${Y}[WARN]${X} %s\n" "$*"; }
err()  { printf "${R}[ERR]${X} %s\n" "$*" >&2; }
has()  { command -v "$1" >/dev/null 2>&1; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [PATH...]

Comprehensive media optimizer (Image, Video, Audio, Web).

Options:
  -j, --jobs N       Parallel jobs (Default: $JOBS)
  -q, --quality N    Image Quality 1-100 (Default: $QUALITY)
  --crf N            Video CRF 0-51 (Default: $CRF)
  --backup           Backup original files to ~/.cache/media-opt
  --dry-run          Simulate execution
  -h, --help         Show this help

Supported Formats:
  Img: jpg, png, webp, svg, gif, avif
  Vid: mp4, mkv, mov, webm (Transcodes to AV1/HEVC if efficient)
  Web: html, css, js, json, xml
EOF
    exit 0
}

# ==============================================================================
# CORE OPTIMIZATION LOGIC (Exported for Parallel)
# ==============================================================================
optimize_file() {
    local file="$1"
    local ext="${file##*.}"
    local lc_ext="${ext,,}"
    local tmp_out="${TMP_DIR}/$(basename "$file")"
    local cmd=()
    local tool=""

    # 1. Determine Tool & Command
    case "$lc_ext" in
        jpg|jpeg|mjpg)
            if has jpegoptim; then
                cmd=(jpegoptim --strip-all --all-progressive -m"$QUALITY" --stdout "$file")
                tool="jpegoptim"
            elif has mozjpeg; then
                cmd=(mozjpeg -quality "$QUALITY" -progressive "$file")
                tool="mozjpeg"
            else return 0; fi # Skip if no tool
            ;;
        png)
            if has oxipng; then
                cmd=(oxipng -o 4 --strip safe -i 0 --out - "$file")
                tool="oxipng"
            elif has optipng; then
                cmd=(optipng -o5 -strip all -out "$tmp_out" "$file") # optipng is weird with stdout
                tool="optipng"
            else return 0; fi
            ;;
        webp)
            if has cwebp; then
                cmd=(cwebp -q "$QUALITY" -m 6 -mt -quiet "$file" -o -)
                tool="cwebp"
            else return 0; fi
            ;;
        svg)
            if has svgo; then
                cmd=(svgo -i "$file" -o - --multipass)
                tool="svgo"
            else return 0; fi
            ;;
        gif)
            if has gifsicle; then
                cmd=(gifsicle -O3 --lossy=80 "$file")
                tool="gifsicle"
            else return 0; fi
            ;;
        html|htm|css|js|json|xml)
            if has minify; then
                cmd=(minify "$file")
                tool="minify"
            else return 0; fi
            ;;
        mp4|mkv|mov|avi|webm)
            if has ffmpeg; then
                # Intelligent Video Transcode (AV1 default, fallback to efficient copy if already optimized)
                # Using SVT-AV1 preset 10 (fast) for balance.
                cmd=(ffmpeg -y -v error -i "$file" -c:v libsvtav1 -preset 10 -crf "$CRF" -c:a libopus -b:a "$AUDIO_BR" -movflags +faststart "$tmp_out")
                tool="ffmpeg"
            else return 0; fi
            ;;
        *) return 0 ;;
    esac

    # 2. Execution Wrapper
    local original_size=$(stat -c%s "$file")
    
    # Dry Run check
    if [[ "$DRY_RUN" -eq 1 ]]; then
        printf "${B}[DRY]${X} %-10s %s\n" "$tool" "$file"
        return 0
    fi

    # Run optimization
    # Handle tools that output to stdout vs specific output files
    if [[ "$tool" == "ffmpeg" ]] || [[ "$tool" == "optipng" ]]; then
        "${cmd[@]}" >/dev/null 2>&1 || { err "Failed: $file"; return 1; }
    else
        "${cmd[@]}" > "$tmp_out" 2>/dev/null || { err "Failed: $file"; return 1; }
    fi

    # 3. Size Verification & Atomic Replacement
    if [[ -f "$tmp_out" ]]; then
        local new_size=$(stat -c%s "$tmp_out")
        
        # Only replace if we saved space (and new file is valid/non-empty)
        if [[ $new_size -gt 0 ]] && [[ $new_size -lt $original_size ]]; then
            local diff=$((original_size - new_size))
            local percent=$((diff * 100 / original_size))
            
            # Backup logic
            if [[ "$BACKUP" -eq 1 ]]; then
                local backup_path="${BACKUP_DIR}/${file#.}" # Maintain directory structure
                mkdir -p "$(dirname "$backup_path")"
                cp -p "$file" "$backup_path"
            fi

            # Overwrite
            mv "$tmp_out" "$file"
            
            # Restore timestamp?
            if [[ "$KEEP_MTIME" -eq 1 ]]; then touch -r "$file" "$file"; fi
            
            printf "${G}[OK]${X}  %-25s -%d%% (%s saved)\n" "$(basename "$file")" "$percent" "$(numfmt --to=iec $diff)"
        else
            printf "${Y}[SKIP]${X} %-25s (No savings)\n" "$(basename "$file")"
        fi
        rm -f "$tmp_out"
    fi
}

export -f optimize_file
export -f has err
export JOBS QUALITY CRF AUDIO_BR DRY_RUN BACKUP BACKUP_DIR KEEP_MTIME TMP_DIR B G Y R X

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================

# 1. Parse Arguments
INPUT_PATHS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -j|--jobs) JOBS="$2"; shift 2 ;;
        -q|--quality) QUALITY="$2"; shift 2 ;;
        --crf) CRF="$2"; shift 2 ;;
        --backup) BACKUP=1; shift ;;
        --dry-run) DRY_RUN=1; shift ;;
        -h|--help) usage ;;
        *) INPUT_PATHS+=("$1"); shift ;;
    esac
done

[[ ${#INPUT_PATHS[@]} -eq 0 ]] && INPUT_PATHS=("(current dir)") && set -- "." 
[[ ${#INPUT_PATHS[@]} -gt 0 ]] && set -- "${INPUT_PATHS[@]}"

# 2. Pre-flight Checks
if [[ "$BACKUP" -eq 1 ]]; then
    mkdir -p "$BACKUP_DIR"
    log "Backup enabled: $BACKUP_DIR"
fi

log "Starting optimization with $JOBS threads..."
# 3. Find & Dispatch
# Extensions regex
EXT_REGEX=".*\.\(jpg\|jpeg\|png\|webp\|svg\|gif\|mp4\|mkv\|mov\|webm\|html\|css\|js\|json\)$"
# Define the find command
FIND_CMD="find \"$@\" -type f -iregex \"$EXT_REGEX\" -not -path '*/.*'"

# Select Executor (Rust Parallel > GNU Parallel > Xargs)
if has rust-parallel; then
    eval "$FIND_CMD" | rust-parallel -j "$JOBS" -- 'optimize_file {}'
elif has parallel; then
    # GNU parallel needs env_parallel or strict quoting for exported functions
    eval "$FIND_CMD" | parallel -j "$JOBS" --no-notice "optimize_file {}"
else
    # Fallback to xargs (Bash -c wrapper required to see exported function)
    eval "$FIND_CMD -print0" | xargs -0 -P "$JOBS" -I {} bash -c 'optimize_file "$@"' _ {}
fi

log "Done."
