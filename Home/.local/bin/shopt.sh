#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'
export LC_ALL=C LANG=C
# Bash Script Optimizer, Minifier & Compiler
# Formats, hardens, lints, minifies, and compiles shell scripts
# Supports single files, directories, stdout output, and multi-variant compilation
#──────────── Colors ────────────
RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' DEF=$'\e[0m'
has(){ command -v "$1" &>/dev/null; }
die(){ printf '%b%s%b\n' "$RED" "$*" "$DEF" >&2; exit 1; }
log(){ printf '%b%s%b\n' "$GRN" "$*" "$DEF"; }
warn(){ printf '%b%s%b\n' "$YLW" "$*" "$DEF"; }
usage(){
  cat <<'EOF'
Usage: shopt [-rfmscCvh] [-o FILE] [-p PERM] [-e EXT] [-V VARIANT] <file_or_dir>

Mode Options:
  -c, --compile     Compile mode: concatenate + preprocess multi-variant scripts
  -C, --concat      Concatenate files only (no preprocessing)

Processing Options:
  -r, --recursive   Process directory recursively
  -f, --format      Apply shfmt formatting (default: on)
  -m, --minify      Minify with shfmt -mn (implies -f)
  -s, --strip       Strip comments and headers
  -v, --variants    Compile variants (comma-sep: bash,zsh; default: bash,zsh)

Output Options:
  -o, --output      Output file (stdout if -, overwrite if same as input)
  -p, --permission  Set chmod mode on output (default: u+x)
  -F, --force       Overwrite existing files without prompt
  -d, --debug       Save debug files (.debug extension)

Filter Options (compile mode):
  -e, --extensions  File extensions (comma-sep: sh,bash; default: sh,bash)
  -w, --whitelist   Directory names to include (comma-sep)
  -x, --regex       Regex to match directories/files

  -h, --help        Show this help

Examples:
  shopt script.sh                    # Optimize single file
  shopt -m script.sh                 # Minify single file
  shopt -r -o out.sh src/            # Recursive optimize directory
  shopt -c -o build/app src/         # Compile multi-variant from src/
  shopt -c -v bash -o app.sh src/    # Compile bash variant only
EOF
  exit 0
}
#──────────── Args ────────────
declare -a files variants=() extensions=() whitelist=()
recursive=0 format=1 minify=0 strip=0 force=0 compile=0 concat=0 debug=0
output="" perm="u+x" regex=""
[[ $# -eq 0 ]] && usage
while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--recursive) recursive=1; shift ;;
    -f|--format) format=1; shift ;;
    -m|--minify) minify=1; format=1; shift ;;
    -s|--strip) strip=1; shift ;;
    -c|--compile) compile=1; shift ;;
    -C|--concat) concat=1; shift ;;
    -d|--debug) debug=1; shift ;;
    -F|--force) force=1; shift ;;
    -o|--output) output="${2:?output requires arg}"; shift 2 ;;
    -p|--permission) perm="${2:?perm requires arg}"; shift 2 ;;
    -e|--extensions) IFS=',' read -ra extensions <<<"${2:?extensions requires arg}"; shift 2 ;;
    -w|--whitelist) IFS=',' read -ra whitelist <<<"${2:?whitelist requires arg}"; shift 2 ;;
    -x|--regex) regex="${2:?regex requires arg}"; shift 2 ;;
    -v|--variants) IFS=',' read -ra variants <<<"${2:?variants requires arg}"; shift 2 ;;
    -h|--help) usage ;;
    -*) die "Unknown option: $1" ;;
    *) break ;;
  esac
done
target="${1:?No file/dir specified}"
# Defaults
[[ ${#extensions[@]} -eq 0 ]] && extensions=(sh bash)
[[ ${#variants[@]} -eq 0 ]] && variants=(bash zsh)
#──────────── Deps ────────────
for cmd in shfmt shellharden shellcheck awk; do has "$cmd" || die "Missing: $cmd"; done
readonly HAS_SD=$(has sd && echo 1 || echo 0)
readonly HAS_PREPROCESS=$(has preprocess && echo 1 || echo 0)
readonly HAS_BEAUTYSH=$(has beautysh && echo 1 || echo 0)
((compile && !HAS_PREPROCESS)) && die "Compile mode needs 'preprocess' (pip install preprocess)"
#──────────── File Collection ────────────
if ((compile || concat)); then
  [[ ! -d $target ]] && die "Compile/concat mode needs directory"
  files=()
elif [[ -d $target ]]; then
  ((recursive == 0)) && die "Use -r for directories"
  mapfile -d '' files < <(find "$target" -type f \( -name '*.sh' -o -name '*.bash' \) -print0)
elif [[ -f $target ]]; then
  files=("$target")
else
  die "Not found: $target"
fi
((${#files[@]} == 0 && !compile && !concat)) && { log "No scripts found"; exit 0; }
[[ ${#files[@]} -gt 1 && -n $output && $output != - ]] && ((!compile && !concat)) \
  && die "Multiple files with single output unsupported (use -c/--compile)"
#──────────── Comment Strip AWK (Enhanced) ────────────
read -r -d '' AWK_STRIP <<'AWK' || :
NR==1 && /^#!/ { print; next }
!/^#/ { hdr=1 }
!hdr { next }
/^[[:space:]]*#/ { next }
{ gsub(/[[:space:]]+#.*/, ""); gsub(/^[[:space:]]+|[[:space:]]+$/, ""); if(length) print }
AWK
#──────────── Function Normalizer ────────────
normalize_functions(){ sed -E 's/^[[:space:]]*function[[:space:]]+([a-zA-Z0-9_]+)[[:space:]]*\{/\1(){\n/g'; }
#──────────── Preprocessor Prep ────────────
prep_preprocess(){
  local in="$1" out="$2"
  : >"$out"
  while IFS= read -r line; do
    [[ ! $line =~ ^[[:space:]]*#[[:space:]]*if[[:space:]]+ ]] && printf '%s\n' "$line" >>"$out"
  done <"$in"
}
#──────────── Enhanced Minifier ────────────
minify_enhanced(){
  local in="$1" out="$2"
  : >"$out"
  while IFS= read -r line; do
    # Keep preprocessor directives (# # define, # # ifdef, etc.)
    if [[ $line =~ ^#[[:space:]]*#[[:space:]]*(define|undef|ifdef|ifndef|if|elif|else|endif|error|include) ]]; then
      printf '%s\n' "$line" >>"$out"; continue
    fi
    # Skip shebang (already handled)
    [[ $line =~ ^#! ]] && continue
    # Skip comment-only lines (but preserve copyright if in first 10 lines)
    if [[ $line =~ ^[[:space:]]*# ]]; then
      if ((NR <= 10)) && [[ $line =~ Copyright|License ]]; then
        printf '%s\n' "$line" >>"$out"; continue
      fi; continue
    fi
    # Normalize function declarations
    line=$(sed -E 's/^[[:space:]]*function[[:space:]]+([a-zA-Z0-9_]+)[[:space:]]*\{/\1(){/g' <<<"$line")
    # Strip inline comments & whitespace
    local stripped=$(sed -E 's/[[:space:]]+#[[:space:]]*[a-zA-Z0-9 ]*$//; s/^[[:space:]]+//; s/[[:space:]]+$//' <<<"$line")
    [[ -n $stripped ]] && printf '%s\n' "$stripped" >>"$out"
  done <"$in"
  # Remove multiline comments & separator lines
  sed -i -e '/^:[[:space:]]*'"'"'/,/^'"'"'/d' -e '/^#[[:space:]]*[-─]{5,}/d' "$out" 2>/dev/null || :
}
#──────────── Concatenate Files ────────────
concat_files(){
  local base="$1" out="$2" rx="$5"; local -n exts="$3" wlist="$4"
  : >"$out"
  for dirpath in "$base"/*/; do
    dirpath="${dirpath%/}"
    local dname="${dirpath##*/}"
    # Skip __* directories
    [[ $dname == *__* ]] && continue
    # Check whitelist
    if [[ ${#wlist[@]} -gt 0 ]]; then
      local found=0
      for w in "${wlist[@]}"; do
        [[ $dname == "$w" ]] && { found=1; break; }
      done
      ((found == 0)) && continue
    fi
    # Check regex
    [[ -n $rx && ! $dirpath =~ $rx ]] && continue
    log "Concat: $dname"
    # Build exclude array if __EXCLUDE_FILES exists
    local -a excl_args=()
    if [[ -f $dirpath/__EXCLUDE_FILES ]]; then
      while IFS= read -r xf; do
        [[ -n $xf ]] && excl_args+=("!" "-path" "$xf")
      done <"$dirpath/__EXCLUDE_FILES"
    fi
    # Process extensions
    for ext in "${exts[@]}"; do
      while IFS= read -r -d '' lf; do
        [[ $lf == *__* || $lf == *_PLACEHOLDER* ]] && continue
        [[ $lf == *."$ext" ]] && cat "$lf" >>"$out"
      done < <(find "$dirpath" -type f "${excl_args[@]}" -print0 2>/dev/null)
    done
  done
}
#──────────── Optimizer (Standard Mode) ────────────
optimize(){
  local f="$1" content; local out_target="$f"
  # Handle output
  if [[ -n $output ]]; then
    [[ $output == - ]] && out_target="" || out_target="$output"
    [[ -f $out_target && $force -eq 0 && $out_target != "$f" ]] && {
      read -rp "Overwrite $out_target? [y/N] " ans
      [[ ${ans,,} != y ]] && return 0
    }
  fi
  content=$(<"$f")
  # Strip comments/headers
  ((strip)) && content=$(awk "$AWK_STRIP" <<<"$content")
  # Normalize bashisms
  if ((HAS_SD)); then
    content=$(sd '\|\| true' '|| :' <<<"$content")
    content=$(sd '\s*\(\)\s*\{' '(){' <<<"$content")
    content=$(sd '>\/dev\/null 2>&1' '&>/dev/null' <<<"$content")
  else
    content=$(sed -e 's/|| true/|| :/g' -e 's/[[:space:]]*()[[:space:]]*{/(){/g' \
      -e 's|&>/dev/null|&>/dev/null|g' <<<"$content")
  fi
  # Optional beautysh before formatting
  if ((HAS_BEAUTYSH && format && !minify)); then
    content=$(beautysh -i 2 -s paronly --variable-style braces - <<<"$content" 2>/dev/null || echo "$content")
  fi
  # Format/Minify
  if ((format)); then
    local -a opts=(-ln bash -bn -i 2 -s)
    ((minify)) && opts+=(-mn)
    content=$(shfmt "${opts[@]}" <<<"$content")
  fi
  # Output
  [[ -z $out_target ]] && {
    printf '%s' "$content"; return 0; }
  local tmp=$(mktemp)
  trap 'rm -f "$tmp"' RETURN
  printf '%s' "$content" >"$tmp"
  # Harden & lint
  shellharden --replace "$tmp" &>/dev/null || :
  shellcheck -a -x -s bash -f diff "$tmp" 2>/dev/null|patch -Np1 "$tmp" &>/dev/null || :
  cat "$tmp" >"$out_target"; chmod "$perm" "$out_target"
  log "✓ $out_target"
}
#──────────── Compiler (Multi-Variant Mode) ────────────
compile_variants(){
  local base="$target"
  [[ -z $output ]] && die "Compile mode requires -o/--output"
  # Remove extension from output base
  local out_base="${output%.sh}"
  out_base="${out_base%.bash}"
  # Concatenate all files
  local tmp_concat=$(mktemp)
  trap 'rm -f "$tmp_concat"' RETURN
  log "Concatenating files from $base"
  concat_files "$base" "$tmp_concat" extensions whitelist "$regex"
  # Process each variant
  for var in "${variants[@]}"; do
    local VAR="${var^^}"; local var_lo="${var,,}"
    log "Compiling variant: $VAR"
    local tmp_prep tmp_proc tmp_mini
    tmp_prep=$(mktemp); tmp_proc=$(mktemp); tmp_mini=$(mktemp)
    trap 'rm -f "$tmp_prep" "$tmp_proc" "$tmp_mini"' RETURN
    # Prepare for preprocessor
    prep_preprocess "$tmp_concat" "$tmp_prep"
    # Run preprocessor
    if ((HAS_PREPROCESS)); then
      preprocess -D "SHELL_IS_${VAR}=true" -f -o "$tmp_proc" "$tmp_prep" \
        || die "Preprocessor failed for $VAR"
    else
      cp "$tmp_prep" "$tmp_proc"
    fi
    # Minify
    minify_enhanced "$tmp_proc" "$tmp_mini"
    # Final output
    local final="${out_base}.${var_lo}"
    mv "$tmp_mini" "$final"; chmod "$perm" "$final"
    log "✓ $final"
    # Debug output
    ((debug)) && { cp "$tmp_concat" "${final}.debug"; log "Debug: ${final}.debug"; }
  done
}
#──────────── Main ────────────
if ((compile)); then
  compile_variants
elif ((concat)); then
  [[ -z $output ]] && die "Concat mode requires -o/--output"
  log "Concatenating files from $target"
  concat_files "$target" "$output" extensions whitelist "$regex"
  chmod "$perm" "$output"; log "✓ $output"
else
  for f in "${files[@]}"; do optimize "$f"; done
  [[ -z $output ]] && log "Done: ${#files[@]} file(s)"
fi
