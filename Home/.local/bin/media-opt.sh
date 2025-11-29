#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$' \n\t'
export LC_ALL=C LANG=C HOME="/home/${SUDO_USER:-$USER}"
# ==============================================================================
# CONFIGURATION
# ==============================================================================
: "${JOBS:=$(nproc 2>/dev/null || echo 4)}" "${DRY_RUN:=0}" "${BACKUP:=0}" "${KEEP_MTIME:=1}"
: "${BACKUP_DIR:=${HOME}/.cache/media-opt/backups/$(printf '%(%Y%m%d_%H%M%S)T' -1)}"
# Optimization: 1=Lossless/Best, 0=Lossy
: "${LOSSLESS:=1}" "${QUALITY:=100}" "${VIDEO_CRF:=24}"
# Codecs: libsvtav1, libaom-av1, libx265, libx264, libvpx-vp9
: "${VIDEO_CODEC:=libsvtav1}" "${AUDIO_CODEC:=libopus}" "${AUDIO_BR:=128k}"

# Colors & Helpers
R=$'\e[31m' G=$'\e[32m' Y=$'\e[33m' B=$'\e[34m' X=$'\e[0m'
log() { printf "${B}[%(%H:%M:%S)T]${X} %s\n" -1 "$*"; }
err() { printf "${R}[ERR]${X} %s\n" "$*" >&2; }
has() { command -v "$1" >/dev/null 2>&1; }
usage() {
	cat <<EOF
Usage: $(basename "$0") [OPTIONS] [PATH...]
  -j N        Jobs (Default: $JOBS)
  -l          Lossy Mode (Default: Lossless)
  -q N        Quality 1-100 (Default: $QUALITY)
  --crf N     Video CRF (Default: $VIDEO_CRF)
  --vcodec S  Video Codec (Default: $VIDEO_CODEC)
  --acodec S  Audio Codec (Default: $AUDIO_CODEC)
  --backup    Enable Backup
  --dry-run   Simulate
EOF
	exit 0
}

# ==============================================================================
# WRAPPERS
# ==============================================================================
opt_img() {
	local f="$1" out="$2"
	local ext="${f##*.}"
	local l_ext="${ext,,}"
	# 1. rimage (Best general purpose)
	if has rimage; then
		tool="rimage"
		cp "$f" "$out"
		[[ $LOSSLESS -eq 1 ]] && cmd=(rimage "$out" -q 100) || cmd=(rimage "$out" -q "$QUALITY")
	# 2. image-optimizer (Rust wrapper)
	elif has image-optimizer && [[ "$l_ext" =~ ^(jpg|jpeg|png|webp)$ ]]; then
		tool="image-optimizer"
		cmd=(image-optimizer "$f" "$out")
	# 3. Fallbacks
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

# ==============================================================================
# CORE
# ==============================================================================
optimize_file() {
	local f="$1"
	[[ ! -f "$f" ]] && return 0
	local ext="${f##*.}"
	local tmp="${f}.opt.tmp.${ext}"
	local tool="" cmd=()

	case "${ext,,}" in
	jpg | jpeg | mjpg | png | webp | avif | jxl | bmp) opt_img "$f" "$tmp" ;;
	svg) opt_svg "$f" "$tmp" ;;
	gif) has gifsicle && {
		tool="gifsicle"
		cmd=(gifsicle "$f")
		[[ $LOSSLESS -eq 1 ]] && cmd+=(-O3 --careful) || cmd+=(-O3 --lossy=80)
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

	# Execute
	local ok=0
	# Handle stdout tools vs file output tools
	if [[ "$tool" =~ ^(oxipng|cwebp|svgo|jpegoptim)$ ]] && [[ "${cmd[*]}" =~ --stdout|--out\ -|-o\ - ]]; then
		if "${cmd[@]}" >"$tmp" 2>/dev/null; then ok=1; fi
	else
		if "${cmd[@]}" >/dev/null 2>&1; then ok=1; fi
	fi

	# Size Guard & Replace
	if [[ $ok -eq 1 ]] && [[ -f "$tmp" ]]; then
		local old_sz
		local new_sz
		old_sz=$(stat -c%s "$f")
		new_sz=$(stat -c%s "$tmp")
		if [[ $new_sz -gt 0 ]] && [[ $new_sz -lt $old_sz ]]; then
			local diff=$((old_sz - new_sz))
			local pct=$((diff * 100 / old_sz))
			if [[ "$BACKUP" -eq 1 ]]; then
				local bp="${BACKUP_DIR}/${f#.}"
				mkdir -p "$(dirname "$bp")"
				cp -p "$f" "$bp"
			fi
			mv "$tmp" "$f"
			[[ "$KEEP_MTIME" -eq 1 ]] && touch -r "$f" "$f"
			printf "${G}[OK]${X}  %-25s %-8s -%d%% (%s)\n" "$(basename "$f")" "[$tool]" "$pct" "$(numfmt --to=iec "$diff")"
		else
			rm -f "$tmp"
		fi
	else
		[[ -f "$tmp" ]] && rm -f "$tmp"
	fi
}
export -f optimize_file opt_img opt_svg opt_vid has err
export JOBS QUALITY LOSSLESS VIDEO_CODEC VIDEO_CRF AUDIO_CODEC AUDIO_BR DRY_RUN BACKUP BACKUP_DIR KEEP_MTIME B G Y R X

# ==============================================================================
# MAIN
# ==============================================================================
INPUTS=()
while [[ $# -gt 0 ]]; do case $1 in
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
	*)
		INPUTS+=("$1")
		shift
		;;
	esac done

[[ ${#INPUTS[@]} -eq 0 ]] && INPUTS=("(current dir)") && set -- "." || set -- "${INPUTS[@]}"
[[ "$BACKUP" -eq 1 ]] && {
	mkdir -p "$BACKUP_DIR"
	log "Backup: $BACKUP_DIR"
}

log "Starting ($JOBS jobs, $VIDEO_CODEC)..."
EXTS="jpg,jpeg,mjpg,png,webp,svg,gif,avif,jxl,bmp,mp4,mkv,mov,webm,avi"

if has fd; then
	FIND="fd -t f -H -E .git $(printf -- "-e %s " "${EXTS//,/ }") . \"$*\""
elif has fdfind; then
	FIND="fdfind -t f -H -E .git $(printf -- "-e %s " "${EXTS//,/ }") . \"$*\""
else FIND="find \"$*\" -type f -iregex \".*\.\(${EXTS//,/\|}\)$\" -not -path '*/.*'"; fi

if has rust-parallel; then
	eval "$FIND" | rust-parallel -j "$JOBS" -- 'optimize_file {}'
elif has parallel; then
	eval "$FIND" | parallel -j "$JOBS" --no-notice "optimize_file {}"
else
	eval "$FIND -print0" | xargs -0 -P "$JOBS" -I {} bash -c 'optimize_file "$@"' _ {}
fi
log "Done."
