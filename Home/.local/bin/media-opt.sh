#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'
export LC_ALL=C LANG=C HOME="/home/${SUDO_USER:-$USER}"
: "${JOBS:=$(nproc 2>/dev/null || printf 4)}" "${DRY:=0}" "${BACKUP:=0}" "${MTIME:=1}"
: "${BACKUP_DIR:=${HOME}/.cache/media-opt/$(printf '%(%Y%m%d_%H%M%S)T' -1)}"
: "${LOSSLESS:=1}" "${QUAL:=95}" "${VCRF:=24}" "${VCODEC:=libsvtav1}"
R=$'\e[31m' G=$'\e[32m' Y=$'\e[33m' B=$'\e[34m' X=$'\e[0m'
log(){ printf "${B}[%(%H:%M:%S)T]${X} %s\n" -1 "$*"; }
err(){ printf "${R}[ERR]${X} %s\n" "$*" >&2; }
die(){
  err "$@"
  exit 1
}
has(){ command -v "$1" &>/dev/null; }
declare -A TC
cache_tools(){
  local t
  for t in rimage jpegoptim oxipng cwebp gifsicle ffmpeg; do has "$t" && TC[$t]=1 || TC[$t]=0; done
}
hc(){ [[ ${TC[$1]:-0} -eq 1 ]]; }
opt_img(){
  local f=$1 o=$2 t c=() x="${f##*.}" lx="${x,,}"
  if hc rimage; then
    t=rimage
    cp "$f" "$o"
    [[ $LOSSLESS -eq 1 ]] && c=(rimage "$o" -q 100) || c=(rimage "$o" -q "$QUAL")
  else
    case "$lx" in
      jpg | jpeg | mjpg)
        hc jpegoptim && {
          t=jpegoptim
          c=(jpegoptim --strip-all --all-progressive --stdout "$f")
          [[ $LOSSLESS -eq 0 ]] && c+=(-m"$QUAL")
        }
        ;;
      png) hc oxipng && {
        t=oxipng
        c=(oxipng -o4 --strip safe -i0 --out - "$f")
      } ;;
      webp)
        hc cwebp && {
          t=cwebp
          c=(cwebp -mt -quiet "$f" -o -)
          [[ $LOSSLESS -eq 1 ]] && c+=(-lossless -z9) || c+=(-q "$QUAL" -m6)
        }
        ;;
    esac
  fi
  [[ -n $t ]] && printf '%s:%s\n' "$t" "${c[*]}"
}
opt_vid(){
  local f=$1 o=$2 t c=() va=()
  hc ffmpeg || return 0
  t=ffmpeg
  case "$VCODEC" in
    libsvtav1) [[ $LOSSLESS -eq 1 ]] && va=(-preset 4 -crf "$VCRF" -svtav1-params tune=0:scd=1) || va=(-preset 8 -crf $((VCRF + 6))) ;;
    libaom-av1) [[ $LOSSLESS -eq 1 ]] && va=(-cpu-used 3 -crf "$VCRF" -b:v 0) || va=(-cpu-used 6 -crf $((VCRF + 6)) -b:v 0) ;;
    libx265) [[ $LOSSLESS -eq 1 ]] && va=(-preset slower -crf "$VCRF") || va=(-preset medium -crf $((VCRF + 4))) ;;
    libvpx-vp9) va=(-b:v 0 -crf $((VCRF + 8)) -cpu-used 3 -row-mt 1) ;;
  esac
  c=(ffmpeg -y -v error -i "$f" -c:v "$VCODEC" "${va[@]}" -c:a libopus -b:a 128k -movflags +faststart "$o")
  printf '%s:%s\n' "$t" "${c[*]}"
}
optimize(){
  local f=$1
  [[ ! -f $f ]] && return 0
  local x="${f##*.}" lx="${x,,}" tmp="${f}.tmp.${x}" res t c=()
  case "$lx" in
    jpg | jpeg | mjpg | png | webp | avif | jxl | bmp) res=$(opt_img "$f" "$tmp") ;;
    gif) hc gifsicle && {
      t=gifsicle
      [[ $LOSSLESS -eq 1 ]] && c=(gifsicle "$f" -O3 --careful) || c=(gifsicle "$f" -O3 --lossy=80)
      res="${t}:${c[*]}"
    } ;;
    mp4 | mkv | mov | avi | webm) res=$(opt_vid "$f" "$tmp") ;;
    svg) hc cwebp && {
      t=cwebp
      c=(cwebp -mt -quiet "$f" -o -)
      res="${t}:${c[*]}"
    } ;;
    *) return 0 ;;
  esac
  [[ -z $res ]] && {
    [[ -f $tmp ]] && rm -f "$tmp"
    return 0
  }
  t="${res%%:*}"
  IFS=: read -r _ cmdstr <<<"$res"
  read -ra c <<<"$cmdstr"
  [[ $DRY -eq 1 ]] && {
    printf "${B}[DRY]${X} %-10s %s\n" "$t" "$f"
    [[ -f $tmp ]] && rm -f "$tmp"
    return 0
  }
  local ok=0
  if [[ $t =~ ^(oxipng|cwebp|jpegoptim)$ ]] && [[ ${c[*]} =~ (--stdout|--out.*-|-o.*-) ]]; then
    "${c[@]}" >"$tmp" 2>/dev/null && ok=1
  else
    "${c[@]}" &>/dev/null && ok=1
  fi
  if [[ $ok -eq 1 && -f $tmp ]]; then
    local os ns d p
    os=$(stat -c%s "$f")
    ns=$(stat -c%s "$tmp")
    if [[ $ns -gt 0 && $ns -lt $os ]]; then
      d=$((os - ns))
      p=$((d * 100 / os))
      [[ $BACKUP -eq 1 ]] && {
        local bp="${BACKUP_DIR}/${f#.}"
        mkdir -p "$(dirname "$bp")"
        cp -p "$f" "$bp"
      }
      mv "$tmp" "$f"
      [[ $MTIME -eq 1 ]] && touch -r "$f" "$f"
      printf "${G}[OK]${X} %-25s %-12s -%d%% (%s)\n" "$(basename "$f")" "[$t]" "$p" "$(numfmt --to=iec "$d")"
    else
      rm -f "$tmp"
    fi
  else
    [[ -f $tmp ]] && rm -f "$tmp"
  fi
}
export -f optimize opt_img opt_vid hc err log
export TC LOSSLESS QUAL VCRF VCODEC DRY BACKUP BACKUP_DIR MTIME B G Y R X
interactive(){
  has ffmpeg || die "ffmpeg required for interactive mode"
  local inp
  while :; do
    clear
    log "Media Conversion Tool"
    read -rp "Input file (q=quit): " inp
    [[ $inp == q ]] && break
    inp="${inp//\'/}"
    inp="${inp#[\'\"]}"
    inp="${inp%[\'\"]}"
    [[ -f $inp ]] || {
      err "File not found"
      sleep 2
      continue
    }
    local fn="${inp##*/}" ext="${fn##*.}" lext="${ext,,}" cext="" vf=()
    case "$lext" in
      gif) local -a tgts=(mkv mp4 webm webp "Format only" Back) ;;
      mp4 | mkv | webm | webp) local -a tgts=(gif mkv mp4 webm webp "Format only" Back) ;;
      *)
        err "Unsupported: $ext"
        sleep 2
        continue
        ;;
    esac
    PS3=$'\n'"${B}Convert ${fn} to?${X} "
    select ch in "${tgts[@]}"; do
      case "$ch" in
        Back) break ;;
        "Format only")
          cext=$ext
          break
          ;;
        "")
          err "Invalid"
          continue
          ;;
        *)
          cext=$ch
          break
          ;;
      esac
    done
    [[ $ch == Back ]] && continue
    local -a opts=("True size" "50%" "75%" "Square 500" "HQ Lanczos" "Rotate 90° CW" "Rotate 90° CCW" "Vflip" Done)
    while :; do
      clear
      log "Options: ${fn} -> ${cext}"
      printf "${Y}Filters: %s${X}\n" "${vf[*]:-(none)}"
      PS3=$'\n'"${B}Add filter?${X} "
      select o in "${opts[@]}"; do
        case "$o" in
          "True size") vf+=(scale=iw:ih) ;;
          "50%") vf+=(scale=iw/2:ih/2) ;;
          "75%") vf+=(scale=iw*0.75:ih*0.75) ;;
          "Square 500") vf+=(scale=500:500) ;;
          "HQ Lanczos") vf+=(flags=lanczos) ;;
          "Rotate 90° CW") vf+=(transpose=1) ;;
          "Rotate 90° CCW") vf+=(transpose=2) ;;
          Vflip) vf+=(vflip) ;;
          Done) break 2 ;;
          *) err "Invalid" ;;
        esac
        break
      done
    done
    local od="${inp%/*}" of="${od}/${fn%.*}-mc.${cext}" vff
    IFS=, vff="${vf[*]}"
    log "Converting..."
    local -a cmd=(ffmpeg -y -hide_banner -i "$inp")
    if [[ $lext == gif && $cext != gif ]]; then
      local pal="${od}/pal.png"
      ffmpeg -i "$inp" -vf palettegen -y "$pal" &>/dev/null
      cmd+=(-i "$pal" -lavfi "${vff:+$vff,}paletteuse")
    else
      [[ $cext == gif ]] && vff="fps=30${vff:+,${vff}}"
      [[ -n $vff ]] && cmd+=(-vf "$vff")
    fi
    cmd+=("$of")
    "${cmd[@]}"
    [[ -f ${pal:-} ]] && rm -f "$pal"
    log "Done: $of"
    read -rp "Press ENTER..."
  done
}
batch(){
  local dir=${1:-.} exts=".*\.(jpg|jpeg|mjpg|png|webp|svg|gif|avif|jxl|bmp|mp4|mkv|mov|webm|avi)\$"
  local -a fc files
  has fd && fc=(fd -tf --hidden --no-ignore --regex "$exts" . "$dir") || fc=(find "$dir" -type f -iregex "$exts")
  mapfile -t files < <("${fc[@]}")
  [[ ${#files[@]} -eq 0 ]] && die "no media files in $dir"
  printf '%s\n' "${files[@]}" | xargs -P"$JOBS" -I{} bash -c 'optimize "$@"' _ {}
}
usage(){
  cat <<'EOF'
media-opt.sh - Batch media optimization
USAGE: media-opt.sh [OPTIONS] [PATH...]
OPTIONS:
  -j N          Jobs (default: auto)
  -l            Lossy mode (default: lossless)
  -q N          Quality 1-100 (default: 95)
  --crf N       Video CRF (default: 24)
  --vcodec C    Video codec (default: libsvtav1)
  -i            Interactive conversion
  --backup      Enable backups
  --dry-run     Simulate
  -h            Help
EXAMPLES:
  media-opt.sh -l -q 85 ~/Pictures
  media-opt.sh --vcodec libvpx-vp9 --crf 28 ~/Videos
  media-opt.sh -i
EOF
}
main(){
  local -a inputs=()
  while [[ $# -gt 0 ]]; do
    case $1 in
      -i | --interactive)
        interactive
        exit 0
        ;;
      -j | --jobs)
        JOBS=$2
        shift 2
        ;;
      -l | --lossy)
        LOSSLESS=0
        shift
        ;;
      -q | --quality)
        QUAL=$2
        shift 2
        ;;
      --crf)
        VCRF=$2
        shift 2
        ;;
      --vcodec)
        VCODEC=$2
        shift 2
        ;;
      --backup)
        BACKUP=1
        shift
        ;;
      --dry-run)
        DRY=1
        shift
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      -*) die "Unknown: $1" ;;
      *)
        inputs+=("$1")
        shift
        ;;
    esac
  done
  [[ ${#inputs[@]} -eq 0 ]] && inputs=(.)
  [[ $BACKUP -eq 1 ]] && {
    mkdir -p "$BACKUP_DIR"
    log "Backups: $BACKUP_DIR"
  }
  cache_tools
  log "Optimizing ($JOBS jobs, $VCODEC)..."
  for i in "${inputs[@]}"; do batch "$i"; done
  log "Done."
}
main "$@"
