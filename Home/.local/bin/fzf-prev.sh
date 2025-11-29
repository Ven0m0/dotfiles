#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C LANG=C
# fzf-tools preview: unified file previewer for fzf
# Usage:
#   fzf-tools preview <PATH or PATH:LINE>
# Env:
#   FZF_PREVIEW_IMAGE_HANDLER=kitty|sixel|symbols (default auto)
#   BAT_STYLE (e.g. "numbers,changes")

have() { command -v "$1" &>/dev/null; }
batcmd() { if have batcat; then printf '%s' batcat; elif have bat; then printf '%s' bat; else printf '%s' cat; fi; }
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/fzf"
mkdir -p "$cache_dir" || :
mime_of() { file --mime-type -b -- "$1"; }
ext_of() {
	local b="${1##*/}"
	b="${b##*.}"
	printf '%s' "${b,,}"
}
abspath() { readlink -f -- "$1"; }
sha256_of() { sha256sum <<<"$1" | awk '{print $1}'; }

dim_cols="${FZF_PREVIEW_COLUMNS:-}"
dim_lines="${FZF_PREVIEW_LINES:-}"
term_dim() {
	local cols="$dim_cols" lines="$dim_lines"
	if [[ -z "$cols" || -z "$lines" ]]; then
		read -r lines cols < <(stty size </dev/tty 2>/dev/null || printf '40 120\n')
	fi
	# avoid bottom-touch scroll issue
	if [[ -n "${FZF_PREVIEW_TOP:-}" && -n "$dim_lines" ]]; then
		local t="${FZF_PREVIEW_TOP:-0}"
		local tty_lines
		tty_lines="$(stty size </dev/tty 2>/dev/null | awk '{print $1}')" || tty_lines="$lines"
		((t + lines == tty_lines)) && lines=$((lines - 1 > 1 ? lines - 1 : lines))
	fi
	printf '%sx%s' "$cols" "$lines"
}

preview_text() {
	local file="$1" center="${2:-0}" ext
	ext="$(ext_of "$file")"
	case "$ext" in
	md) have glow && {
		glow --style=auto -- "$file"
		return
	} ;;
	htm | html) have w3m && {
		w3m -T text/html -dump -- "$file"
		return
	} ;;
	esac
	local b
	b="$(batcmd)"
	if [[ "$b" == "cat" ]]; then
		sed -n '1,400p' -- "$file"
	else
		"$b" --style="${BAT_STYLE:-numbers}" --color=always --pager=never --highlight-line="${center:-0}" -- "$file"
	fi
}

preview_symlink() {
	local loc="$1" target
	target="$(readlink -- "$loc" || printf '')"
	[[ -z "$target" ]] && {
		printf 'symlink (unreadable)\n'
		return
	}
	printf 'symlink → %s\n' "$target"
}

preview_image_backend() {
	local img="$1" dim
	dim="$(term_dim)"
	local handler="${FZF_PREVIEW_IMAGE_HANDLER:-auto}"
	if [[ "$handler" == "kitty" ]] || { [[ "$handler" == "auto" && (-n "${KITTY_WINDOW_ID:-}" || -n "${GHOSTTY_RESOURCES_DIR:-}") ]] && have kitten; }; then
		kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="$dim@0x0" -- "$img" | sed '$d' | sed $'$s/$/\e[m/'
		have mediainfo && mediainfo -- "$img" || :
		return
	fi
	if [[ "$handler" == "sixel" || "$handler" == "auto" ]]; then
		if have chafa; then
			chafa -f "${handler/auto/sixel}" -s "$dim" --animate false -- "$img"
			have mediainfo && mediainfo -- "$img" || :
			return
		fi
	fi
	if [[ "$handler" == "symbols" ]] && have chafa; then
		chafa -f symbols -s "$dim" --animate false -- "$img"
		have mediainfo && mediainfo -- "$img" || :
		return
	fi
	file --brief --dereference --mime -- "$img"
}

preview_archive() {
	local f="$1" ext
	ext="$(ext_of "$f")"
	case "$ext" in
	7z) have 7z && {
		7z l -p -- "$f" || :
		return
	} ;;
	a | ace | alz | arc | arj | bz | bz2 | cab | cpio | deb | gz | jar | lha | lz | lzh | lzma | lzo | rpm | rz | t7z | tar | tbz | tbz2 | tgz | tlz | txz | tZ | tzo | war | xpi | xz | Z | zip | rar)
		have atool && {
			atool --list -- "$f" || :
			return
		}
		;;
	esac
	file --brief --dereference --mime -- "$f"
}

preview_misc_by_ext() {
	local f="$1" ext
	ext="$(ext_of "$f")"
	case "$ext" in
	o) have nm && {
		nm -- "$f"
		return
	} ;;
	iso) have iso-info && {
		iso-info --no-header -l -- "$f"
		return
	} ;;
	odt | ods | odp | sxw) have odt2txt && {
		odt2txt -- "$f"
		return
	} ;;
	doc) have catdoc && {
		catdoc -- "$f"
		return
	} ;;
	docx) have docx2txt && {
		docx2txt -- "$f" -
		return
	} ;;
	xls | xlsx) if have ssconvert && have bat; then
		ssconvert --export-type=Gnumeric_stf:stf_csv -- "$f" "fd://1" | bat --language=csv
		return
	fi ;;
	wav | mp3 | flac | m4a | wma | ape | ac3 | og[agx] | spx | opus | as[fx] | mka) have exiftool && {
		exiftool -- "$f"
		return
	} ;;
	esac
	file --brief --dereference --mime -- "$f"
}

preview_file() {
	local loc="$1" center="${2:-0}"
	local mime
	mime="$(mime_of "$loc" || printf '')"
	case "$mime" in
	text/*) preview_text "$loc" "$center" ;;
	application/json) if have jq; then "$(batcmd)" -p --color=always -- "$loc" | jq .; else preview_text "$loc" "$center"; fi ;;
	inode/directory) if have eza; then eza -T -L 2 -- "$loc"; else find -- "$loc" -maxdepth 2 -printf '%y %p\n'; fi ;;
	inode/symlink) preview_symlink "$loc" ;;
	application/x-executable | application/x-pie-executable | application/x-sharedlib) have readelf && readelf --wide --demangle=auto --all -- "$loc" || file -- "$loc" ;;
	application/x-x509-ca-cert) have openssl && openssl x509 -text -noout -in "$loc" || file -- "$loc" ;;
	image/*) preview_image_backend "$loc" ;;
	video/*)
		local base hash out
		base="$(abspath "$loc")"
		hash="$(sha256_of "$base")"
		out="${cache_dir}/thumb-${hash}.jpg"
		if ! [[ -s "$out" ]]; then have ffmpegthumbnailer && ffmpegthumbnailer -i "$loc" -o "$out" -s 1200 || :; fi
		[[ -s "$out" ]] && preview_image_backend "$out" || file -- "$loc"
		;;
	application/pdf)
		local base hash out
		base="$(abspath "$loc")"
		hash="$(sha256_of "$base")"
		out="${cache_dir}/pdf-${hash}.jpg"
		if ! [[ -s "$out" ]]; then have pdftoppm && pdftoppm -jpeg -f 1 -singlefile -- "$loc" "${cache_dir}/pdf-${hash}" || :; fi
		[[ -s "$out" ]] && preview_image_backend "$out" || file -- "$loc"
		;;
	*) preview_archive "$loc" || preview_misc_by_ext "$loc" ;;
	esac
}
parse_arg() {
	local in="$1" file="$1" center=0
	if [[ ! -r "$file" ]]; then
		if [[ "$file" =~ ^(.+):([0-9]+)\ *$ ]] && [[ -r "${BASH_REMATCH[1]}" ]]; then
			file="${BASH_REMATCH[1]}"
			center="${BASH_REMATCH[2]}"
		elif [[ "$file" =~ ^(.+):([0-9]+):[0-9]+\ *$ ]] && [[ -r "${BASH_REMATCH[1]}" ]]; then
			file="${BASH_REMATCH[1]}"
			center="${BASH_REMATCH[2]}"
		fi
	fi
	printf '%s\n%s\n' "${file/#\~\//$HOME/}" "$center"
}
usage() { printf 'usage: %s preview <PATH|PATH:LINE>\n' "${0##*/}"; }
cmd_preview() {
	[[ $# -ge 1 ]] || {
		usage
		return 1
	}
	local file center
	read -r file center < <(parse_arg "$1")
	[[ -r "$file" ]] || {
		printf 'not readable: %s\n' "$file" >&2
		return 2
	}
	preview_file "$file" "$center"
}
main() {
	local cmd="${1:-}"
	shift || :
	case "${cmd:-}" in
	preview) cmd_preview "$@" ;;
	"" | -h | --help | help) usage ;;
	*)
		printf 'unknown: %s\n' "$cmd" >&2
		usage
		return 2
		;;
	esac
}
main "$@"
