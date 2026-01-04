#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' ; export LC_ALL=C
readonly RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' DEF=$'\e[0m'
has(){ command -v -- "$1" &>/dev/null; }
die(){ printf '%b%s%b\n' "$RED" "$*" "$DEF" >&2; exit 1; }
log(){ printf '%b%s%b\n' "$GRN" "$*" "$DEF"; }
warn(){ printf '%b%s%b\n' "$YLW" "$*" "$DEF"; }

usage(){
  cat <<'EOF'
Usage: shopt [-rfmscCvh] [-o FILE] [-p PERM] [-e EXT] [-V VARIANT] <file_or_dir>
Mode:  -c,--compile (concat+preprocess) -C,--concat (concat only)
Processing: -r,--recursive -f,--format -m,--minify -s,--strip -v,--variants
Output: -o,--output -p,--permission -F,--force -d,--debug
Filter: -e,--extensions -w,--whitelist -x,--regex
Examples: 
  shopt script.sh
  shopt -m script.sh
  shopt -c -o build/app src/
EOF
  exit 0
}

declare -a files variants=() extensions=() whitelist=()
recursive=0 format=1 minify=0 strip=0 force=0 compile=0 concat=0 debug=0 output="" perm="u+x" regex=""
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
    -F|--force) force=1;;
    -h|--help) usage;;
    -*) die "Unknown option: $1";;
    *) break;;
  esac
  shift
done

target="${1:? No file/dir specified}"
[[ ${#extensions[@]} -eq 0 ]] && extensions=(sh bash)
[[ ${#variants[@]} -eq 0 ]] && variants=(bash zsh)

for cmd in shfmt shellharden shellcheck awk; do
  has "$cmd" || die "Missing:  $cmd"
done

readonly HAS_SD=$(has sd && echo 1 || echo 0)
readonly HAS_PREPROCESS=$(has preprocess && echo 1 || echo 0)
readonly HAS_BEAUTYSH=$(has beautysh && echo 1 || echo 0)

((compile && ! HAS_PREPROCESS)) && die "Compile mode needs 'preprocess' (pip install preprocess)"

if ((compile || concat)); then
  [[ !  -d $target ]] && die "Compile/concat mode needs directory"
  files=()
elif [[ -d $target ]]; then
  ((recursive == 0)) && die "Use -r for directories"
  mapfile -d '' files < <(find "$target" -type f -name '*.sh' -o -name '*.bash' -print0)
else
  files=("$target")
fi

((${#files[@]} == 0 && !compile && !concat)) && { log "No scripts found"; exit 0; }
[[ ${#files[@]} -gt 1 && -n $output && $output != - ]] && ((! compile && !concat)) && die "Multiple files with single output unsupported (use -c/--compile)"

read -r -d '' AWK_STRIP <<'AWK' || : 
NR==1 && /^#!/ { print; next }
!/^#/ { hdr=1 }
! hdr { next }
/^[[:space:]]*#/ { next }
{ gsub(/[[:space:]]+#.*/, ""); gsub(/^[[:space:]]+|[[:space:]]+$/, ""); if(length) print }
AWK

prep_preprocess(){
  local in="$1" out="$2"
  :  >"$out"
  while IFS= read -r line; do
    [[ !  $line =~ ^[[:space:]]*#[[:space:]]*if[[:space: ]]+ ]] && printf '%s\n' "$line" >>"$out"
  done <"$in"
}

minify_enhanced(){
  local in="$1" out="$2"
  : >"$out"
  while IFS= read -r line; do
    [[ $line =~ ^#[[:space:]]*#[[:space: ]]*(define|undef|ifdef|ifndef|if|elif|else|endif|error|include) ]] && {
      printf '%s\n' "$line" >>"$out"
      continue
    }
    [[ $line =~ ^#!  ]] && continue
    if [[ $line =~ ^[[:space:]]*# ]]; then
      ((NR <= 10)) && [[ $line =~ Copyright|License ]] && {
        printf '%s\n' "$line" >>"$out"
        continue
      }
      continue
    fi
    line=$(sed -E 's/^[[:space:]]*function[[:space:]]+([a-zA-Z0-9_]+)[[:space:]]*\{/\1(){/g' <<<"$line")
    local stripped
    stripped=$(sed -E 's/[[:space:]]+#[[:space:]]*[a-zA-Z0-9 ]*$//; s/^[[:space:]]+//; s/[[:space:]]+$//' <<<"$line")
    [[ -n $stripped ]] && printf '%s\n' "$stripped" >>"$out"
  done <"$in"
  sed -i -e '/^:[[:space:]]*'"'"'/,/^'"'"'/d' -e '/^#[[:space:]]*[-─]{5,}/d' "$out" 2>/dev/null || : 
}

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
    log "Concat: $dname"
    local -a excl_args=()
    [[ -f $dirpath/__EXCLUDE_FILES ]] && while IFS= read -r xf; do
      [[ -n $xf ]] && excl_args+=("!" "-path" "$xf")
    done <"$dirpath/__EXCLUDE_FILES"
    for ext in "${exts[@]}"; do
      while IFS= read -r -d '' lf; do
        [[ $lf == *__* || $lf == *_PLACEHOLDER* ]] && continue
        [[ $lf == *."$ext" ]] && cat "$lf" >>"$out"
      done < <(find "$dirpath" -type f "${excl_args[@]}" -print0)
    done
  done
}

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
  if ((HAS_SD)); then
    content=$(sd '\|\| true' '|| :' <<<"$content")
    content=$(sd '\s*\(\)\s*\{' '(){' <<<"$content")
    content=$(sd '>\/dev\/null 2>&1' '&>/dev/null' <<<"$content")
  else
    content=$(sed -e 's/|| true/|| :/g' -e 's/\s*(\)\s*{/(){/g' -e 's/>\/dev\/null 2>&1/\&>\/dev\/null/g' <<<"$content")
  fi
  ((HAS_BEAUTYSH && format && ! minify)) && content=$(beautysh -i 2 -s paronly --variable-style braces - <<<"$content" 2>/dev/null || echo "$content")
  if ((format)); then
    local -a opts=(-ln bash -bn -i 2 -s)
    ((minify)) && opts+=(-mn)
    content=$(shfmt "${opts[@]}" <<<"$content")
  fi
  [[ -z $out_target ]] && { printf '%s' "$content"; return 0; }
  local tmp
  tmp=$(mktemp)
  trap 'rm -f "$tmp"' RETURN
  printf '%s' "$content" >"$tmp"
  shellharden --replace "$tmp" &>/dev/null || :
  shellcheck -a -x -s bash -f diff "$tmp" 2>/dev/null | patch -Np1 "$tmp" &>/dev/null || :
  cat "$tmp" >"$out_target"
  chmod "$perm" "$out_target"
  log "✓ $out_target"
}

compile_variants(){
  local base="$target"
  [[ -z $output ]] && die "Compile mode requires -o/--output"
  local out_base="${output%. sh}"
  out_base="${out_base%.bash}"
  local tmp_concat
  tmp_concat=$(mktemp)
  trap 'rm -f "$tmp_concat"' RETURN
  log "Concatenating files from $base"
  concat_files "$base" "$tmp_concat" extensions whitelist "$regex"
  for var in "${variants[@]}"; do
    local VAR="${var^^}" var_lo="${var,,}"
    log "Compiling variant:  $VAR"
    local tmp_prep tmp_proc tmp_mini
    tmp_prep=$(mktemp)
    tmp_proc=$(mktemp)
    tmp_mini=$(mktemp)
    trap 'rm -f "$tmp_prep" "$tmp_proc" "$tmp_mini"' RETURN
    prep_preprocess "$tmp_concat" "$tmp_prep"
    if ((HAS_PREPROCESS)); then
      preprocess -D "SHELL_IS_${VAR}=true" -f -o "$tmp_proc" "$tmp_prep" || die "Preprocessor failed for $VAR"
    else
      cp "$tmp_prep" "$tmp_proc"
    fi
    minify_enhanced "$tmp_proc" "$tmp_mini"
    local final="${out_base}.${var_lo}"
    mv "$tmp_mini" "$final"
    chmod "$perm" "$final"
    log "✓ $final"
    ((debug)) && {
      cp "$tmp_concat" "${final}. debug"
      log "Debug:  ${final}.debug"
    }
  done
}
if ((compile)); then
  compile_variants
elif ((concat)); then
  [[ -z $output ]] && die "Concat mode requires -o/--output"
  log "Concatenating files from $target"
  concat_files "$target" "$output" extensions whitelist "$regex"
  log "✓ $output"
else
  for f in "${files[@]}"; do
    optimize "$f"
  done
fi
