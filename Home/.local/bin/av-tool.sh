#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C

has(){ command -v -- "$1" &>/dev/null; }
die(){ printf '\033[1;31m[ERR]\033[0m %s\n' "$1" >&2; exit "${2:-1}"; }
msg(){ printf '\033[1;34m[INFO]\033[0m %s\n' "$@"; }
wrn(){ printf '\033[1;33m[WARN]\033[0m %s\n' "$@" >&2; }

usage_main(){
  cat <<'EOF'
Usage: av-tool <command> [options]
Commands:
  gif          Convert video to GIF
  frame        Extract single frame
  combine      Mux audio with video/image
  trim         Trim video/audio
  norm         Normalize audio (optionally fade)
  fade         Fade in/out audio+video
  silence      Add silent audio to video
  cd-optimize  Prep audio for Red Book CD (16/44.1kHz+dither)
EOF
}

check_deps(){
  local -a req=(ffmpeg ffprobe file) m=()
  local t
  for t in "${req[@]}"; do has "$t" || m+=("$t"); done
  ((${#m[@]})) && die "Missing deps: ${m[*]}"
}

aac_codec(){
  ffmpeg -hide_banner -h encoder=libfdk_aac &>/dev/null && printf 'libfdk_aac' || printf 'aac'
}

sub_float(){ awk -v a="$1" -v b="$2" 'BEGIN{printf "%.6f",a-b}'; }

cmd_gif(){
  local width=320 fps=15 infile= outfile=
  while getopts ":i:w:f: o:h" opt; do
    case $opt in
      i) infile=$OPTARG ;;
      w) width=$OPTARG ;;
      f) fps=$OPTARG ;;
      o) outfile=$OPTARG ;;
      h) printf 'Usage: av-tool gif -i input [-w width] [-f fps] [-o output]\n'; return 0 ;;
      *) die "Invalid option:  -$OPTARG" ;;
    esac
  done
  [[ -z $infile ]] && die "Input (-i) required"
  outfile=${outfile:-${infile%.*}.gif}
  ffmpeg -hide_banner -loglevel error -stats -i "$infile" \
    -filter_complex "[0:v]fps=$fps,scale=$width:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse" \
    "$outfile"
}

cmd_frame(){
  local infile= time=00:00:00 ext=png outfile=
  while getopts ":i:t:f:o:h" opt; do
    case $opt in
      i) infile=$OPTARG ;;
      t) time=$OPTARG ;;
      f) ext=$OPTARG ;;
      o) outfile=$OPTARG ;;
      h) printf 'Usage: av-tool frame -i input [-t timestamp] [-f png|jpg] [-o output]\n'; return 0 ;;
      *) die "Invalid option: -$OPTARG" ;;
    esac
  done
  [[ -z $infile ]] && die "Input (-i) required"
  outfile=${outfile:-${infile%.*}-${time//:/-}.$ext}
  ffmpeg -hide_banner -loglevel error -stats -ss "$time" -i "$infile" -vframes 1 -q:v 2 "$outfile"
}

cmd_combine(){
  local infile= audio= outfile=
  while getopts ":i: a:o:h" opt; do
    case $opt in
      i) infile=$OPTARG ;;
      a) audio=$OPTARG ;;
      o) outfile=$OPTARG ;;
      h) printf 'Usage: av-tool combine -i video_or_img -a audio -o output\n'; return 0 ;;
      *) die "Invalid option: -$OPTARG" ;;
    esac
  done
  [[ -z $infile || -z $audio ]] && die "Inputs -i and -a required"
  outfile=${outfile:-${infile%.*}-combined.mp4}
  local mime; mime=$(file --mime-type -b "$infile")
  case $mime in
    image/*)
      ffmpeg -hide_banner -loglevel error -stats -loop 1 -i "$infile" -i "$audio" \
        -c:v libx264 -tune stillimage -c:a "$(aac_codec)" -b:a 192k -pix_fmt yuv420p -shortest "$outfile"
      ;;
    video/*)
      ffmpeg -hide_banner -loglevel error -stats -i "$infile" -i "$audio" \
        -c:v copy -c:a "$(aac_codec)" -map 0:v:0 -map 1:a:0 -shortest "$outfile"
      ;;
    *) die "Unknown file type: $mime" ;;
  esac
}

cmd_trim(){
  local infile= start=00:00:00 end= duration= outfile= mode=duration
  while getopts ":i:s: e:t:o:h" opt; do
    case $opt in
      i) infile=$OPTARG ;;
      s) start=$OPTARG ;;
      e) end=$OPTARG; mode=timestamp ;;
      t) duration=$OPTARG; mode=duration ;;
      o) outfile=$OPTARG ;;
      h) printf 'Usage: av-tool trim -i input -s 00:00:00 [-t duration | -e end_time] [-o output]\n'; return 0 ;;
      *) die "Invalid option: -$OPTARG" ;;
    esac
  done
  [[ -z $infile ]] && die "Input (-i) required"
  local trim_flag suffix
  if [[ $mode == timestamp ]]; then
    [[ -z $end ]] && die "End time (-e) required"
    trim_flag=(-to "$end"); suffix="trimmed-to-$end"
  else
    [[ -z $duration ]] && die "Duration (-t) required"
    trim_flag=(-t "$duration"); suffix="trimmed-$duration"
  fi
  outfile=${outfile:-${infile%.*}-${suffix}.${infile##*.}}
  ffmpeg -hide_banner -loglevel error -stats -ss "$start" -i "$infile" \
    "${trim_flag[@]}" -c:v libx264 -profile:v high -pix_fmt yuv420p -c:a "$(aac_codec)" -movflags +faststart "$outfile"
}

cmd_norm(){
  local infile= fade_len=0 outfile=
  while getopts ":i:f:o: h" opt; do
    case $opt in
      i) infile=$OPTARG ;;
      f) fade_len=$OPTARG ;;
      o) outfile=$OPTARG ;;
      h) printf 'Usage: av-tool norm -i input [-f fade_seconds] [-o output]\n'; return 0 ;;
      *) die "Invalid option: -$OPTARG" ;;
    esac
  done
  [[ -z $infile ]] && die "Input (-i) required"
  outfile=${outfile:-${infile%.*}-normalized.mp4}
  local stats; stats=$(ffmpeg -hide_banner -loglevel error -i "$infile" -af "loudnorm=I=-16:TP=-1.5:LRA=11:print_format=summary" -f null - 2>&1 | tail -n 12)
  local meas_I meas_TP meas_LRA meas_thresh offset
  meas_I=$(awk '/Input Integrated:/{print $3}' <<<"$stats")
  meas_TP=$(awk '/Input True Peak:/{print $4}' <<<"$stats")
  meas_LRA=$(awk '/Input LRA:/{print $3}' <<<"$stats")
  meas_thresh=$(awk '/Input Threshold:/{print $3}' <<<"$stats")
  offset=$(awk '/Target Offset:/{print $3}' <<<"$stats")
  local loudnorm_filter="loudnorm=I=-16:TP=-1.5:LRA=11:measured_I=$meas_I:measured_LRA=$meas_LRA:measured_TP=$meas_TP:measured_thresh=$meas_thresh:offset=$offset:linear=true"
  if [[ $fade_len != 0 && $fade_len != 0.0 ]]; then
    local dur; dur=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$infile")
    local fade_out_st; fade_out_st=$(sub_float "$dur" "$fade_len")
    local audio_filter="afade=t=in:st=0:d=$fade_len,afade=t=out:st=$fade_out_st:d=$fade_len,$loudnorm_filter"
    local video_filter="fade=t=in:st=0:d=$fade_len,fade=t=out:st=$fade_out_st:d=$fade_len"
    ffmpeg -hide_banner -loglevel error -stats -i "$infile" \
      -filter_complex "[0:v]$video_filter[v];[0:a]$audio_filter[a]" \
      -map "[v]" -map "[a]" -c:v libx264 -preset fast -crf 18 -c:a "$(aac_codec)" "$outfile"
  else
    ffmpeg -hide_banner -loglevel error -stats -i "$infile" \
      -af "$loudnorm_filter" -c:v copy -c:a "$(aac_codec)" "$outfile"
  fi
}

cmd_fade(){
  local infile= dur=0.5 outfile=
  while getopts ":i:d:o:h" opt; do
    case $opt in
      i) infile=$OPTARG ;;
      d) dur=$OPTARG ;;
      o) outfile=$OPTARG ;;
      h) printf 'Usage: av-tool fade -i input [-d duration] [-o output]\n'; return 0 ;;
      *) die "Invalid option: -$OPTARG" ;;
    esac
  done
  [[ -z $infile ]] && die "Input (-i) required"
  outfile=${outfile:-${infile%.*}-fade.mp4}
  local video_len; video_len=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$infile")
  local fade_out_start; fade_out_start=$(sub_float "$video_len" "$dur")
  ffmpeg -hide_banner -loglevel error -stats -i "$infile" \
    -filter_complex "[0:v]fade=t=in:st=0:d=$dur,fade=t=out:st=$fade_out_start: d=$dur[v];[0:a]afade=t=in:st=0:d=$dur,afade=t=out: st=$fade_out_start: d=$dur[a]" \
    -map "[v]" -map "[a]" -c:v libx264 -crf 18 -pix_fmt yuv420p -c: a "$(aac_codec)" "$outfile"
}

cmd_silence(){
  local infile= outfile=
  while getopts ":i:o: h" opt; do
    case $opt in
      i) infile=$OPTARG ;;
      o) outfile=$OPTARG ;;
      h) printf 'Usage: av-tool silence -i input -o output\n'; return 0 ;;
      *) die "Invalid option:  -$OPTARG" ;;
    esac
  done
  [[ -z $infile ]] && die "Input (-i) required"
  outfile=${outfile:-${infile%.*}-silence.mp4}
  ffmpeg -hide_banner -loglevel error -stats \
    -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -i "$infile" \
    -shortest -c:v copy -c:a "$(aac_codec)" -map 0:a -map 1:v "$outfile"
}

cmd_cd_optimize(){
  local input_dir="${1:-.}" output_dir="cd_master_ready"
  has ffmpeg || die "Missing ffmpeg"
  [[ -d "$input_dir" ]] || die "Input directory not found: $input_dir"
  mkdir -p "$output_dir"
  msg "Source:  $input_dir"
  msg "Target: $output_dir"
  msg "Mode:    Red Book (44.1kHz/16-bit/Stereo) + Triangular Dither"
  local count=0 lossy_count=0
  while IFS= read -r file; do
    local ext="${file##*.}" base
    base=$(basename "$file")
    base="${base%.*}"
    [[ "$ext" =~ ^(mp3|m4a|aac|ogg)$ ]] && { wrn "Processing lossy source: $base.$ext (Suboptimal for CD)"; ((lossy_count++)); }
    ffmpeg -y -v error -i "$file" \
      -af "aresample=44100:resampler=soxr: precision=28: dither_method=triangular" \
      -c:a pcm_s16le "$output_dir/$base.wav"
    printf "."
    ((count++))
  done < <(find "$input_dir" -maxdepth 1 -type f -regextype posix-extended -regex ".*\.(flac|wav|mp3|m4a|aac|ogg|alac|aiff)$")
  printf "\n"
  ((count > 0)) || die "No audio files found in $input_dir"
  msg "Processed $count files."
  ((lossy_count > 0)) && wrn "Detected $lossy_count lossy input files.  Quality compromised." || msg "All inputs lossless.  Quality optimized."
  cat <<EOF
---------------------------------------------------------------------
   🔥 BURN INSTRUCTIONS (CRITICAL)
---------------------------------------------------------------------
1.  MEDIA :  Verbatim AZO (Blue) or Taiyo Yuden (Green/Blue).
2. SPEED : 16x or 24x.  DO NOT use Max/52x (High Jitter) or 1x. 
3. MODE  :  Disc-At-Once (DAO) / Gapless (2-second gap standard).
---------------------------------------------------------------------
Files ready in: $output_dir/
EOF
}

main(){
  check_deps
  [[ $# -eq 0 ]] && { usage_main; exit 1; }
  local sub=$1; shift || true
  case $sub in
    gif) cmd_gif "$@" ;;
    frame) cmd_frame "$@" ;;
    combine) cmd_combine "$@" ;;
    trim) cmd_trim "$@" ;;
    norm) cmd_norm "$@" ;;
    fade) cmd_fade "$@" ;;
    silence) cmd_silence "$@" ;;
    cd-optimize) cmd_cd_optimize "$@" ;;
    *) die "Unknown command: $sub" ;;
  esac
}
main "$@"
