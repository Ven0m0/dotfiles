#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t'; export LC_ALL=C

has(){ command -v -- "$1" &>/dev/null; }
msg(){ printf '%s\n' "$@"; }
log(){ printf '%s\n' "$@" >&2; }
die(){ printf '%s\n' "$1" >&2; exit "${2:-1}"; }
readonly RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' DEF=$'\e[0m'
clog(){ printf '%b%s%b\n' "$GRN" "$*" "$DEF" >&2; }
cwarn(){ printf '%b%s%b\n' "$YLW" "$*" "$DEF" >&2; }
cerr(){ printf '%b%s%b\n' "$RED" "$*" "$DEF" >&2; }

usage(){
  cat <<'EOF'
Usage: shopt [-rfmscCh] [-o FILE] [-p PERM] [-e EXT] [-V VARIANT] <file_or_dir>
Mode:       -c,--compile (concat+preprocess) -C,--concat (concat only)
Processing: -r,--recursive -f,--format -m,--minify -s,--strip -v,--variants
Output:     -o,--output -p,--permission -F,--force -d,--debug
Filter:     -e,--extensions -w,--whitelist -x,--regex
Examples: 
  shopt script.sh
  shopt -m script.sh
  shopt -c -o build/app -V bash,zsh src/
EOF
  exit 0
}

declare -a files variants=() extensions=() whitelist=()
recursive=0 format=1 minify=0 strip=0 force=0 compile=0 concat=0 debug=0
output="" perm="u+x" regex=""
[[ $# -eq 0 ]] && usage

while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--recursive) recursive=1;;
    -f|--format) format=1;;
    -m|--minify) minify=1 format=1;;
    -s|--strip) strip=1;;
    -c|--compile) compile=1;;
    -C|--concat) concat=1;;
    -d|--debug) debug=1;;
    -o|--output) output="$2"; shift;;
    -p|--permission) perm="$2"; shift;;
    -e|--extensions) IFS=',' read -ra extensions <<<"$2"; shift;;
    -w|--whitelist) IFS=',' read -ra whitelist <<<"$2"; shift;;
    -x|--regex) regex="$2"; shift;;
    -V|--variants) IFS=',' read -ra variants <<<"$2"; shift;;
    -F|--force) force=1;;
    -h|--help) usage;;
    -*) die "Unknown option: $1";;
    *) break;;
  esac
  shift
done

target="${1:?No file/dir specified}"
[[ ${#extensions[@]} -eq 0 ]] && extensions=(sh bash)
[[ ${#variants[@]} -eq 0 ]] && variants=(bash)

for cmd in shfmt shellharden shellcheck awk; do
  has "$cmd" || die "Missing: $cmd"
done
if ((compile || concat)); then
  [[ ! -d $target ]] && die "Compile/concat mode needs directory"
  files=()
elif [[ -d $target ]]; then
  ((recursive == 0)) && die "Use -r for directories"
  mapfile -d '' files < <(find "$target" -type f \( -name '*.sh' -o -name '*.bash' \) -print0)
else
  files=("$target")
fi
((${#files[@]} == 0 && !compile && !concat)) && { clog "No scripts found"; exit 0; }
[[ ${#files[@]} -gt 1 && -n $output && $output != - ]] && ((!  compile && !concat)) && die "Multiple files require -c/--compile"

# AWK script:  strip comments/blank lines, keep shebang
read -r -d '' AWK_STRIP <<'AWK' || :
NR==1 && /^#!/ { print; next }
!/^#/ { hdr=1 }
! hdr { next }
/^[[:space:]]*#/ { next }
{ gsub(/[[:space:]]+#.*/, ""); gsub(/^[[:space:]]+|[[:space:]]+$/, ""); if(length) print }
AWK

# Pure bash preprocessor: handles #ifdef SHELL_IS_<VARIANT>
# Syntax: #ifdef VAR / #ifndef VAR / #else / #endif
preprocess_shell(){
  local in="$1" out="$2" def="$3"
  local -a stack=() line
  local active=1 depth=0
  :  >"$out"
  while IFS= read -r line; do
    if [[ $line =~ ^[[:space:]]*#ifdef[[:space:]]+(.+)$ ]]; then
      local var="${BASH_REMATCH[1]}"
      stack+=("$active")
      ((depth++))
      ((active == 1 && var == "$def")) && active=1 || active=0
    elif [[ $line =~ ^[[:space:]]*#ifndef[[:space:]]+(.+)$ ]]; then
      local var="${BASH_REMATCH[1]}"
      stack+=("$active")
      ((depth++))
      ((active == 1 && var != "$def")) && active=1 || active=0
    elif [[ $line =~ ^[[:space:]]*#else[[:space:]]*$ ]]; then
      ((depth > 0 && ${stack[-1]})) && ((active = ! active))
    elif [[ $line =~ ^[[:space:]]*#endif[[:space:]]*$ ]]; then
      ((depth > 0)) && { active="${stack[-1]}"; stack=("${stack[@]:0:${#stack[@]}-1}"); ((depth--)); }
    else
      ((active == 1)) && printf '%s\n' "$line" >>"$out"
    fi
  done <"$in"
}

# Minify: strip comments (except copyright/license in first 10 lines), normalize function syntax
minify_enhanced(){
  local in="$1" out="$2"
  : >"$out"
  while IFS= read -r line; do
    [[ $line =~ ^#!  ]] && continue
    if [[ $line =~ ^[[:space:]]*# ]]; then
      ((NR <= 10)) && [[ $line =~ Copyright|License ]] && { printf '%s\n' "$line" >>"$out"; continue; }
      continue
    fi
    line=$(sed -E 's/^[[:space:]]*function[[:space:]]+([a-zA-Z0-9_]+)[[:space:]]*\{/\1(){/g' <<<"$line")
    local stripped
    stripped=$(sed -E 's/[[:space:]]+#[[:space:]]*[a-zA-Z0-9 ]*$//; s/^[[:space:]]+//; s/[[:space:]]+$//' <<<"$line")
    [[ -n $stripped ]] && printf '%s\n' "$stripped" >>"$out"
  done <"$in"
  sed -i -e '/^:[[:space:]]*'"'"'/,/^'"'"'/d' -e '/^#[[:space:]]*[-─]{5,}/d' "$out" 2>/dev/null || : 
}

# Concatenate files from base directory, respecting whitelist/exclusions
concat_files(){
  local base="$1" out="$2" rx="$5"
  local -n exts="$3" wlist="$4"
  : >"$out"
  for dirpath in "$base"/*/; do
    dirpath="${dirpath%/}"
    local dname="${dirpath##*/}"
    [[ $dname == *__* ]] && continue
    if [[ ${#wlist[@]} -gt 0 ]]; then
      local found=0
      for w in "${wlist[@]}"; do
        [[ $dname == "$w" ]] && { found=1; break; }
      done
      ((found == 0)) && continue
    fi
    [[ -n $rx && !  $dirpath =~ $rx ]] && continue
    clog "Concat: $dname"
    local -a excl_args=()
    [[ -f $dirpath/__EXCLUDE_FILES ]] && while IFS= read -r xf; do
      [[ -n $xf ]] && excl_args+=("!" "-path" "$xf")
    done <"$dirpath/__EXCLUDE_FILES"
    for ext in "${exts[@]}"; do
      find "$dirpath" -type f "${excl_args[@]}" \
        ! -path "*__*" ! -path "*_PLACEHOLDER*" \
        -name "*.$ext" -print0 2>/dev/null | \
        xargs -0 -r cat -- >>"$out"
    done
  done
}

# Optimize single file: normalize, format, lint
optimize(){
  local f="$1" content out_target="$f"
  [[ -n $output ]] && {
    [[ $output == - ]] && out_target="" || out_target="$output"
    [[ -f $out_target && $force -eq 0 && $out_target != "$f" ]] && {
      read -rp "Overwrite $out_target? [y/N] " ans
      [[ ${ans,,} != y* ]] && return 0
    }
  }
  content=$(<"$f")
  ((strip)) && content=$(awk "$AWK_STRIP" <<<"$content")
  # Normalize patterns with sed (combined for efficiency)
  content=$(sed -E '
    s/\|\| true/|| :/g
    s/[[:space:]]*\(\)[[:space:]]*\{/(){/g
    s/>\/dev\/null[[:space:]]+2>&1/\&>\/dev\/null/g
    s/>\/dev\/null[[:space:]]+2>\&1/\&>\/dev\/null/g
  ' <<<"$content")

  # Format with shfmt
  if ((format)); then
    local -a opts=(-ln bash -bn -i 2 -s)
    ((minify)) && opts+=(-mn)
    content=$(shfmt "${opts[@]}" <<<"$content")
  fi

  [[ -z $out_target ]] && { printf '%s' "$content"; return 0; }

  # Apply shellharden + shellcheck
  local tmp
  tmp=$(mktemp)
  trap 'rm -f "$tmp"' RETURN
  printf '%s' "$content" >"$tmp"
  shellharden --replace "$tmp" &>/dev/null || :
  shellcheck -a -x -s bash -f diff "$tmp" 2>/dev/null | patch -Np1 "$tmp" &>/dev/null || :
  cat "$tmp" >"$out_target"
  chmod "$perm" "$out_target"
  clog "✓ $out_target"
}

# Compile variants: concat → preprocess → minify
compile_variants(){
  local base="$target"
  [[ -z $output ]] && die "Compile mode requires -o/--output"
  local out_base="${output%. sh}"
  out_base="${out_base%.bash}"
  local tmp_concat
  tmp_concat=$(mktemp)
  trap 'rm -f "$tmp_concat"' RETURN
  clog "Concatenating files from $base"
  concat_files "$base" "$tmp_concat" extensions whitelist "$regex"
  for var in "${variants[@]}"; do
    local VAR="${var^^}" var_lo="${var,,}"
    clog "Compiling variant: $VAR"
    local tmp_proc tmp_mini
    tmp_proc=$(mktemp)
    tmp_mini=$(mktemp)
    trap 'rm -f "$tmp_proc" "$tmp_mini"' RETURN
    preprocess_shell "$tmp_concat" "$tmp_proc" "SHELL_IS_${VAR}"
    minify_enhanced "$tmp_proc" "$tmp_mini"
    local final="${out_base}.${var_lo}"
    mv "$tmp_mini" "$final"
    chmod "$perm" "$final"
    clog "✓ $final"
    ((debug)) && {
      cp "$tmp_concat" "${final}.debug"
      clog "Debug: ${final}.debug"
    }
  done
}

# Main logic
if ((compile)); then
  compile_variants
elif ((concat)); then
  [[ -z $output ]] && die "Concat mode requires -o/--output"
  clog "Concatenating files from $target"
  concat_files "$target" "$output" extensions whitelist "$regex"
  clog "✓ $output"
else
  for f in "${files[@]}"; do
    optimize "$f"
  done
fi
