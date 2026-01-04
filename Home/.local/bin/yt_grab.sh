#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C

has(){ command -v -- "$1" &>/dev/null; }
die(){ printf '%s\n' "$1" >&2; exit "${2:-1}"; }

[[ $# -ge 1 ]] || die "usage: $0 URL [URL...]"

OUTDIR="${XDG_VIDEOS_DIR:-$HOME/Videos}"
mkdir -p -- "$OUTDIR"

fmt_video='bv*[height>=1080][fps>=60]'
fmt_audio='ba[acodec=opus][abr<=130]/ba[acodec=opus]/ba'
format="${fmt_video}+${fmt_audio}/${fmt_video}+ba/b"

reencode_args=(
  --reencode-video mkv
  --postprocessor-args "Reencoder:-c:v libsvtav1 -preset 6 -crf 28 -c:a copy"
)

downloader_args=()
if has aria2c; then
  downloader_args=(
    --downloader aria2c
    --downloader-args "aria2c: --file-allocation=falloc --enable-http-keep-alive=true --enable-http-pipelining=true --max-connection-per-server=8 --min-split-size=5M --split=8 --disk-cache=64M --summary-interval=0 --console-log-level=error"
  )
fi

yt-dlp \
  -o "${OUTDIR}/%(title)s.%(ext)s" \
  --cookies-from-browser "${BROWSER:-firefox}" \
  --restrict-filenames \
  --windows-filenames \
  --trim-filenames 75 \
  --sponsorblock-remove all \
  --mtime \
  --progress \
  --yes-playlist \
  --lazy-playlist \
  --buffer-size 16M \
  --concurrent-fragments 8 \
  --fragment-retries 5 \
  --retries 5 \
  --file-access-retries 10 \
  --retry-sleep 1,2,4,8,16 \
  --hls-use-mpegts \
  --no-check-certificates \
  --format "$format" \
  -S "vcodec: av01,vcodec:vp9,vcodec:hevc,res,fps,proto,filesize,br" \
  --merge-output-format mkv \
  "${reencode_args[@]}" \
  --embed-thumbnail \
  --convert-thumbnails webp \
  --embed-metadata \
  --embed-chapters \
  --parse-metadata "title: %(artist)s - %(title)s" \
  --replace-in-metadata title "[ _]" "-" \
  --extractor-args "youtube: player_client=default,tv_embedded,web_creator,player_skip=webpage,skip=translated_subs,comment_sort=top,fetch_pot=auto,use_ad_playback_context=true;youtubetab: skip" \
  "${downloader_args[@]}" \
  -- "$@"
