#!/usr/bin/env bash
# av-tool.sh - Optimized FFmpeg Wrapper
set -euo pipefail; shopt -s nullglob globstar; IFS=$'\n\t'
export LC_ALL=C LANG=C

# --- Helpers ---
export R=$'\e[31m' G=$'\e[32m' B=$'\e[34m' Y=$'\e[33m' X=$'\e[0m'
log() { printf "%b[+]%b %s\n" "$B" "$X" "$*"; }
die() { printf "%b[!]%b %s\n" "$R" "$X" "$*" >&2; exit "${2:-1}"; }
warn() { printf "%b[WARN]%b %s\n" "$Y" "$X" "$*" >&2; }
req() { command -v "$1" >/dev/null || die "Missing dependency: $1"; }

export -f log die warn

# --- Commands ---
cmd_gif() {
  [[ $# -lt 2 ]] && die "Usage: gif <input> <output.gif> [scale_width]"
  local in=$1 out=$2 width=${3:-480}
  log "Generating GIF ($width px wide)..."
  ffmpeg -y -v warning -i "$in" -vf "fps=15,scale=$width:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -c:v gif "$out"
}

cmd_frame() {
  [[ $# -lt 3 ]] && die "Usage: frame <input> <time_hh:mm:ss> <output.jpg>"
  log "Extracting frame at $2..."
  ffmpeg -y -v warning -ss "$2" -i "$1" -frames:v 1 -q:v 2 "$3"
}

cmd_combine() {
  [[ $# -lt 3 ]] && die "Usage: combine <video/img> <audio> <output>"
  log "Muxing $1 + $2..."
  ffmpeg -y -v warning -i "$1" -i "$2" -c:v copy -c:a aac -b:a 192k -shortest "$3"
}

cmd_trim() {
  [[ $# -lt 4 ]] && die "Usage: trim <input> <start> <end> <output>"
  log "Trimming $1 ($2 to $3)..."
  ffmpeg -y -v warning -ss "$2" -to "$3" -i "$1" -c copy "$4"
}

cmd_norm() {
  [[ $# -lt 2 ]] && die "Usage: norm <input> <output>"
  log "Normalizing audio (loudnorm)..."
  ffmpeg -y -v warning -i "$1" -af loudnorm=I=-16:TP=-1.5:LRA=11 -c:v copy -c:a aac -b:a 192k "$2"
}

cmd_fade() {
  [[ $# -lt 3 ]] && die "Usage: fade <input> <duration> <output>"
  local d=$2
  log "Fading in/out ($d sec)..."
  ffmpeg -y -v warning -i "$1" \
    -vf "fade=t=in:st=0:d=$d" \
    -af "afade=t=in:st=0:d=$d" \
    -c:v libx264 -preset fast -c:a aac -b:a 192k "$3"
}

cmd_silence() {
  [[ $# -lt 2 ]] && die "Usage: silence <video> <output>"
  log "Adding silent audio track..."
  ffmpeg -y -v warning -i "$1" -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
    -c:v copy -c:a aac -shortest "$2"
}

_cdopt_worker() {
  local file=$1 out_dir=$2
  local base; base=$(basename "${file%.*}")
  local fmt; fmt=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$file" < /dev/null)

  if [[ $fmt =~ mp3|aac|ogg|wma ]]; then
     warn "Lossy source ($fmt): $base"
     echo "STATUS:LOSSY"
  fi

  # High-quality Resampling (SOXR) + Dither (Triangular)
  ffmpeg -nostdin -y -v error -i "$file" \
      -af "aresample=44100:resampler=soxr:precision=28:dither_method=triangular" \
      -c:a pcm_s16le "$out_dir/$base.wav" && echo "STATUS:DONE"
}
export -f _cdopt_worker

cmd_cdopt() {
  [[ $# -lt 2 ]] && die "Usage: cd-optimize <input_dir> <output_dir>"
  local in_dir=$1 out_dir=$2 count=0 lossy=0
  [[ -d $in_dir ]] || die "Input dir not found: $in_dir"
  mkdir -p "$out_dir"
  
  log "Optimizing for Red Book CD (16-bit/44.1kHz)..."

  local jobs
  if command -v nproc >/dev/null; then
      jobs=$(nproc)
  else
      jobs=4
  fi

  # Use process substitution to avoid subshell issues with counters?
  # Actually pipe output to while loop in current shell

  while read -r line; do
      case "$line" in
          STATUS:LOSSY) ((lossy++)) || true ;;
          STATUS:DONE)  ((count++)) || true; printf ".";;
      esac
  done < <(find "$in_dir" -maxdepth 1 -type f -regextype posix-extended -iregex ".*\.(flac|wav|mp3|m4a|aac|ogg|alac|aiff)$" -print0 | xargs -0 -P "$jobs" -I {} bash -c '_cdopt_worker "$@"' _ "{}" "$out_dir")
  
  echo
  ((count)) || die "No audio files found."
  log "Processed $count files ($lossy lossy sources)."
  
  cat <<EOF
${Y}---------------------------------------------------------------------
   🔥 BURN INSTRUCTIONS (Red Book)
---------------------------------------------------------------------${X}
1. MEDIA: Verbatim AZO (Blue) or Taiyo Yuden.
2. SPEED: 16x or 24x (Avoid Max/52x).
3. MODE : Disc-At-Once (DAO) / Gapless (2s gap is standard).
   Files: $out_dir/
EOF
}

usage() {
  cat <<EOF
av-tool - FFmpeg Automation
Usage: ${0##*/} [COMMAND] [ARGS]
Commands:
  gif <in> <out> [w]     Video to high-quality GIF
  frame <in> <t> <out>   Extract frame at HH:MM:SS
  combine <v> <a> <out>  Mux video + audio
  trim <in> <s > <e> <o> Trim video (copy mode)
  norm <in> <out>        Normalize audio (Loudnorm)
  fade <in> <dur> <out>  Fade in/out (Video+Audio)
  silence <in> <out>     Add silent audio track
  cd-optimize <in> <out> Prep for Audio CD burning
EOF
  exit 1
}

# --- Main ---
req ffmpeg; req ffprobe
[[ $# -eq 0 ]] && usage
CMD="$1"; shift
case "$CMD" in
  gif|frame|combine|trim|norm|fade|silence) "cmd_$CMD" "$@" ;;
  cd-optimize|cdopt) cmd_cdopt "$@" ;;
  -h|--help) usage ;;
  *) die "Unknown command: $CMD" ;;
esac
