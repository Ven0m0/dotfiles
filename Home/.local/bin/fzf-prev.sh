#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'
export LC_ALL=C LANG=C
# fzf-tools preview: unified file previewer for fzf
# Usage:
#   fzf-tools preview <PATH or PATH:LINE>
# Env:
#   FZF_PREVIEW_IMAGE_HANDLER=kitty|ueberzug|sixel|symbols (default auto)
#   BAT_STYLE (e.g. "numbers,changes")

have(){ command -v "$1" &>/dev/null; }
batcmd(){ if have batcat; then printf '%s' batcat; elif have bat; then printf '%s' bat; else printf '%s' cat; fi; }

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/fzf"
mkdir -p "$cache_dir" || :

ueberzug_fifo="${cache_dir}/ueberzug-${PPID:-$$}.fifo"

mime_of(){ file --mime-type -b -- "$1"; }
ext_of(){
  local b="${1##*/}"
  b="${b##*.}"
  printf '%s' "${b,,}"
}
abspath(){ readlink -f -- "$1"; }
sha256_of(){ sha256sum <<<"$1" | awk '{print $1}'; }

dim_cols="${FZF_PREVIEW_COLUMNS:-}"
dim_lines="${FZF_PREVIEW_LINES:-}"
term_dim(){
  local cols="$dim_cols" lines="$dim_lines"
  if [[ -z $cols || -z $lines ]]; then
    read -r lines cols < <(stty size </dev/tty 2>/dev/null || printf '40 120\n')
  fi
  if [[ -n ${FZF_PREVIEW_TOP:-} && -n $dim_lines ]]; then
    local t="${FZF_PREVIEW_TOP:-0}"
    local tty_lines
    tty_lines="$(stty size </dev/tty 2>/dev/null | awk '{print $1}')" || tty_lines="$lines"
    ((t + lines == tty_lines)) && lines=$((lines - 1 > 1 ? lines - 1 : lines))
  fi
  printf '%sx%s' "$cols" "$lines"
}

get_file_size(){
  if stat --version &>/dev/null; then
    stat -c%s "$1"
  else
    stat -f%z "$1"
  fi
}

get_cache_key(){
  local f="$1" mtime size
  if [[ $OSTYPE == darwin* ]]; then
    mtime="$(stat -f '%m' "$f")"
    size="$(stat -f '%z' "$f")"
  else
    mtime="$(stat -c '%Y' "$f")"
    size="$(stat -c '%s' "$f")"
  fi
  printf '%s_%s' "$mtime" "$size"
}

get_cached_image(){
  local f="$1" key cache_file
  key="$(get_cache_key "$f")"
  cache_file="${cache_dir}/img-${key}.jpg"
  [[ -s $cache_file ]] || return 1
  touch "$cache_file" 2>/dev/null || :
  printf '%s' "$cache_file"
}

cache_image(){
  local src="$1" f="$2" key cache_file
  key="$(get_cache_key "$f")"
  cache_file="${cache_dir}/img-${key}.jpg"
  [[ -s $src ]] && cp "$src" "$cache_file" 2>/dev/null || return 1
  printf '%s' "$cache_file"
}

cmd_e(){
  if "$@" 2>/dev/null; then
    return 0
  else
    if !  have "$1"; then
      {
        printf 'Preview unavailable: install %s\n\n' "$1"
        file -- "${FILE:-}"
      } | fold -sw "$((${FZF_PREVIEW_COLUMNS:-80} - 1))"
    fi
    return 1
  fi
}

preview_text(){
  local file="$1" center="${2:-0}" ext
  ext="$(ext_of "$file")"
  case "$ext" in
<<<<<<< Updated upstream
    md) have glow && {
      glow --style=auto --width "$((${FZF_PREVIEW_COLUMNS:-80} - 1))" -- "$file"
      return
    } ;;
    htm | html) have w3m && {
      w3m -T text/html -dump -- "$file"
      return
    } ;;
||||||| Stash base
    md) have glow && {
      glow --style=auto -- "$file"
      return
    } ;;
    htm | html) have w3m && {
      w3m -T text/html -dump -- "$file"
      return
    } ;;
=======
  md) have glow && {
    glow --style=auto -- "$file"
    return
  } ;;
  htm | html) have w3m && {
    w3m -T text/html -dump -- "$file"
    return
  } ;;
>>>>>>> Stashed changes
  esac
  local b
  b="$(batcmd)"
  if [[ $b == "cat" ]]; then
    sed -n '1,400p' -- "$file"
  else
    "$b" --style="${BAT_STYLE:-numbers}" --color=always --pager=never --highlight-line="${center:-0}" -- "$file"
  fi
}

preview_symlink(){
  local loc="$1" target
  target="$(readlink -- "$loc" || printf '')"
  [[ -z $target ]] && {
    printf 'symlink (unreadable)\n'
    return
  }
  printf 'symlink → %s\n' "$target"
}

init_ueberzug(){
  [[ -p $ueberzug_fifo ]] && return 0
  rm -f "$ueberzug_fifo" 2>/dev/null || :
  mkfifo "$ueberzug_fifo" || return 1
  if have ueberzugpp; then
    tail -f --pid=$$ "$ueberzug_fifo" 2>/dev/null | ueberzugpp layer --silent &
  elif have ueberzug; then
    tail -f --pid=$$ "$ueberzug_fifo" 2>/dev/null | ueberzug layer --silent &
  else
    rm -f "$ueberzug_fifo"
    return 1
  fi
}

cleanup_ueberzug(){
  [[ -p $ueberzug_fifo ]] || return 0
  printf '{"action": "remove", "identifier": "fzf"}\n' >>"$ueberzug_fifo" 2>/dev/null || :
  rm -f "$ueberzug_fifo" 2>/dev/null || :
}

preview_image_backend(){
  local img="$1" dim
  dim="$(term_dim)"
  local handler="${FZF_PREVIEW_IMAGE_HANDLER:-auto}"

  if [[ $handler == "ueberzug" ]] || { [[ $handler == "auto" ]] && { have ueberzugpp || have ueberzug; }; }; then
    init_ueberzug && {
      printf '{"action": "add", "identifier": "fzf", "x": %d, "y": %d, "max_width": %d, "max_height": %d, "path": "%s"}\n' \
        "${FZF_PREVIEW_LEFT:-0}" "${FZF_PREVIEW_TOP:-0}" "${FZF_PREVIEW_COLUMNS:-80}" "${FZF_PREVIEW_LINES:-40}" "$img" >>"$ueberzug_fifo"
      return
    }
  fi

  if [[ $handler == "kitty" ]] || { [[ $handler == "auto" && (-n ${KITTY_WINDOW_ID:-} || -n ${GHOSTTY_RESOURCES_DIR:-}) ]] && have kitten; }; then
    kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="$dim@0x0" -- "$img" | sed '$d' | sed $'$s/$/\e[m/'
    have mediainfo && mediainfo -- "$img" || :
    return
  fi

  if [[ $handler == "sixel" || $handler == "auto" ]]; then
    if have chafa; then
      chafa -f "${handler/auto/sixel}" -s "$dim" --animate false -- "$img"
      have mediainfo && mediainfo -- "$img" || :
      return
    fi
  fi

  if [[ $handler == "symbols" ]] && have chafa; then
    chafa -f symbols -s "$dim" --animate false -- "$img"
    have mediainfo && mediainfo -- "$img" || :
    return
  fi

  file --brief --dereference --mime -- "$img"
}

preview_archive(){
  local f="$1" ext size max_size=$((100 * 1024 * 1024))
  ext="$(ext_of "$f")"
  size="$(get_file_size "$f" 2>/dev/null || printf '0')"

  case "$ext" in
<<<<<<< Updated upstream
    zip) have unzip && {
      file --brief --dereference --mime -- "$f"
      ((size < max_size)) && {
        unzip -l -- "$f" 2>/dev/null || :
        printf '\n'
        unzip -p -- "$f" 2>/dev/null | head -c 10000 || :
      }
||||||| Stash base
    7z) have 7z && {
      7z l -p -- "$f" || :
=======
  7z) have 7z && {
    7z l -p -- "$f" || :
    return
  } ;;
  a | ace | alz | arc | arj | bz | bz2 | cab | cpio | deb | gz | jar | lha | lz | lzh | lzma | lzo | rpm | rz | t7z | tar | tbz | tbz2 | tgz | tlz | txz | tZ | tzo | war | xpi | xz | Z | zip | rar)
    have atool && {
      atool --list -- "$f" || :
>>>>>>> Stashed changes
      return
<<<<<<< Updated upstream
    } ;;
    gz) have zcat && {
      file --brief --dereference --mime -- "$f"
      ((size < max_size)) && {
        zcat -l -- "$f" 2>/dev/null || :
        printf '\n'
        zcat -- "$f" 2>/dev/null | head -c 10000 || :
      }
      return
    } ;;
    bz2) have bzcat && {
      file --brief --dereference --mime -- "$f"
      ((size < max_size)) && bzcat -- "$f" 2>/dev/null | head -c 10000 || :
      return
    } ;;
    xz) have xzcat && {
      file --brief --dereference --mime -- "$f"
      ((size < max_size)) && {
        xz -l -- "$f" 2>/dev/null || :
        printf '\n'
        xzcat -- "$f" 2>/dev/null | head -c 10000 || :
      }
      return
    } ;;
    7z) have 7z && {
      7z l -p -- "$f" 2>/dev/null || :
      return
    } ;;
    a | ace | alz | arc | arj | bz | cab | cpio | deb | jar | lha | lz | lzh | lzma | lzo | rpm | rz | t7z | tar | tbz | tbz2 | tgz | tlz | txz | tZ | tzo | war | xpi | Z | rar)
      have atool && {
        atool --list -- "$f" 2>/dev/null || :
        return
      }
      ;;
||||||| Stash base
    } ;;
    a | ace | alz | arc | arj | bz | bz2 | cab | cpio | deb | gz | jar | lha | lz | lzh | lzma | lzo | rpm | rz | t7z | tar | tbz | tbz2 | tgz | tlz | txz | tZ | tzo | war | xpi | xz | Z | zip | rar)
      have atool && {
        atool --list -- "$f" || :
        return
      }
      ;;
=======
    }
    ;;
>>>>>>> Stashed changes
  esac
  file --brief --dereference --mime -- "$f"
}

preview_misc_by_ext(){
  local f="$1" ext
  ext="$(ext_of "$f")"
  case "$ext" in
<<<<<<< Updated upstream
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
      ssconvert --export-type=Gnumeric_stf:stf_csv -- "$f" "fd://1" 2>/dev/null | bat --language=csv
      return
    fi ;;
    wav | mp3 | flac | m4a | wma | ape | ac3 | og[agx] | spx | opus | as[fx] | mka) have exiftool && {
      exiftool -- "$f"
      return
    } ;;
||||||| Stash base
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
=======
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
>>>>>>> Stashed changes
  esac
  file --brief --dereference --mime -- "$f"
}

preview_file(){
  local loc="$1" center="${2:-0}" mime tmp_img cached_img
  tmp_img="${cache_dir}/tmp-${PPID:-$$}. jpg"
  FILE="$loc"

  if cached_img="$(get_cached_image "$loc")"; then
    preview_image_backend "$cached_img"
    return
  fi

  mime="$(mime_of "$loc" || printf '')"
  case "$mime" in
<<<<<<< Updated upstream
    text/*) preview_text "$loc" "$center" ;;
    application/json) if have jq; then "$(batcmd)" -p --color=always -- "$loc" | jq .; else preview_text "$loc" "$center"; fi ;;
    inode/directory) if have eza; then eza -T -L 2 -- "$loc"; else find -- "$loc" -maxdepth 2 -printf '%y %p\n'; fi ;;
    inode/symlink) preview_symlink "$loc" ;;
    application/x-executable | application/x-pie-executable | application/x-sharedlib | application/x-object) have readelf && readelf --wide --demangle=auto --all -- "$loc" || file -- "$loc" ;;
    application/x-x509-ca-cert) have openssl && openssl x509 -text -noout -in "$loc" || file -- "$loc" ;;

    image/*)
      if [[ $mime == "image/vnd.djvu" ]]; then
        if cmd_e ddjvu -format=tiff -size=1920x1080 -page=1 "$loc" "$tmp_img"; then
          cached_img="$(cache_image "$tmp_img" "$loc")"
          preview_image_backend "$cached_img"
        fi
      elif have magick; then
        if magick "$loc" -auto-orient -resize x1080 "$tmp_img" 2>/dev/null; then
          cached_img="$(cache_image "$tmp_img" "$loc")"
          preview_image_backend "$cached_img"
        else
          preview_image_backend "$loc"
        fi
      else
        preview_image_backend "$loc"
      fi
      ;;

    audio/*)
      if cmd_e ffmpeg -y -i "$loc" -an -c:v copy "${tmp_img}. jpg"; then
        mv "${tmp_img}.jpg" "$tmp_img"
        cached_img="$(cache_image "$tmp_img" "$loc")"
        preview_image_backend "$cached_img"
      else
        cmd_e exiftool "$loc"
      fi
      ;;

    video/*)
      if cmd_e ffmpegthumbnailer -i "$loc" -o "$tmp_img" -s 1080 -m; then
        cached_img="$(cache_image "$tmp_img" "$loc")"
        preview_image_backend "$cached_img"
      fi
      ;;

    application/pdf)
      if cmd_e pdftoppm -singlefile -jpeg "$loc" "$tmp_img"; then
        mv "${tmp_img}.jpg" "$tmp_img"
        cached_img="$(cache_image "$tmp_img" "$loc")"
        preview_image_backend "$cached_img"
      fi
      ;;

    application/epub+zip)
      if cmd_e epub-thumbnailer "$loc" "$tmp_img" 1080; then
        cached_img="$(cache_image "$tmp_img" "$loc")"
        preview_image_backend "$cached_img"
      fi
      ;;

    *officedocument.wordprocessingml.document*)
      cmd_e docx2txt "$loc" - || preview_misc_by_ext "$loc"
      ;;

    *vnd.oasis.opendocument.text*)
      cmd_e odt2txt "$loc" || preview_misc_by_ext "$loc"
      ;;

    message/rfc822)
      cmd_e mu view "$loc" || file -- "$loc"
      ;;

    application/zip | application/gzip | application/x-bzip2 | application/x-xz)
      preview_archive "$loc"
      ;;

    *) preview_archive "$loc" || preview_misc_by_ext "$loc" ;;
||||||| Stash base
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
      if ! [[ -s $out ]]; then have ffmpegthumbnailer && ffmpegthumbnailer -i "$loc" -o "$out" -s 1200 || :; fi
      [[ -s $out ]] && preview_image_backend "$out" || file -- "$loc"
      ;;
    application/pdf)
      local base hash out
      base="$(abspath "$loc")"
      hash="$(sha256_of "$base")"
      out="${cache_dir}/pdf-${hash}.jpg"
      if ! [[ -s $out ]]; then have pdftoppm && pdftoppm -jpeg -f 1 -singlefile -- "$loc" "${cache_dir}/pdf-${hash}" || :; fi
      [[ -s $out ]] && preview_image_backend "$out" || file -- "$loc"
      ;;
    *) preview_archive "$loc" || preview_misc_by_ext "$loc" ;;
=======
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
    if ! [[ -s $out ]]; then have ffmpegthumbnailer && ffmpegthumbnailer -i "$loc" -o "$out" -s 1200 || :; fi
    [[ -s $out ]] && preview_image_backend "$out" || file -- "$loc"
    ;;
  application/pdf)
    local base hash out
    base="$(abspath "$loc")"
    hash="$(sha256_of "$base")"
    out="${cache_dir}/pdf-${hash}.jpg"
    if ! [[ -s $out ]]; then have pdftoppm && pdftoppm -jpeg -f 1 -singlefile -- "$loc" "${cache_dir}/pdf-${hash}" || :; fi
    [[ -s $out ]] && preview_image_backend "$out" || file -- "$loc"
    ;;
  *) preview_archive "$loc" || preview_misc_by_ext "$loc" ;;
>>>>>>> Stashed changes
  esac

  rm -f "$tmp_img" "${tmp_img}.jpg" 2>/dev/null || :
}

parse_arg(){
  local in="$1" file="$1" center=0
  if [[ !  -r $file ]]; then
    if [[ $file =~ ^(. +):([0-9]+)\ *$ ]] && [[ -r ${BASH_REMATCH[1]} ]]; then
      file="${BASH_REMATCH[1]}"
      center="${BASH_REMATCH[2]}"
    elif [[ $file =~ ^(. +):([0-9]+):[0-9]+\ *$ ]] && [[ -r ${BASH_REMATCH[1]} ]]; then
      file="${BASH_REMATCH[1]}"
      center="${BASH_REMATCH[2]}"
    fi
  fi
  printf '%s\n%s\n' "${file/#\~\//$HOME/}" "$center"
}

usage(){ printf 'usage: %s preview <PATH|PATH:LINE>\n' "${0##*/}"; }

cmd_preview(){
  [[ $# -ge 1 ]] || {
    usage
    return 1
  }
  local file center
  read -r file center < <(parse_arg "$1")
  [[ -r $file ]] || {
    printf 'not readable: %s\n' "$file" >&2
    return 2
  }
  preview_file "$file" "$center"
}

cleanup(){
  cleanup_ueberzug
  find "$cache_dir" -maxdepth 1 -type f -printf '%T@\t%p\n' 2>/dev/null | sort -rn | tail -n +201 | cut -f2- | while IFS= read -r f; do rm -f "$f"; done || :
}

trap cleanup HUP INT TERM QUIT EXIT

main(){
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
