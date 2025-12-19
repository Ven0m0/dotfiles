#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C
has(){ command -v -- "$1" &>/dev/null; }
msg(){ printf '%s\n' "$@"; }
log(){ printf '%s\n' "$@" >&2; }
die(){ printf '%s\n' "$1" >&2; exit "${2:-1}"; }

usage(){
  msg "Usage: lint-all.sh [--path DIR] [--jobs N] [--lint-only|--minify-only] [--dry-run] [--stdin-format N] [--help]"
  msg "  --path|-p DIR     Target root (default: \$PWD)"
  msg "  --jobs|-j N       Parallel jobs (default: nproc or 4)"
  msg "  --lint-only       Run lint/format only"
  msg "  --minify-only     Run minify/compact only"
  msg "  --dry-run         Skip mutating format/minify; still lint"
  msg "  --stdin-format N  Read stdin, replace tabs with N spaces, squeeze blank runs, then exit"
  msg "  --help            Show this help"
}

root=$PWD
jobs=$(nproc 2>/dev/null||printf 4)
do_lint=true
do_minify=true
dry_run=false
stdin_indent=

while (($#)); do
  case $1 in
    -p|--path) shift; root=${1:-$root} ;;
    -j|--jobs) shift; jobs=${1:-$jobs} ;;
    --lint-only) do_minify=false ;;
    --minify-only) do_lint=false ;;
    --dry-run) dry_run=true ;;
    --stdin-format) shift; stdin_indent=${1:-} ;;
    --help) usage; exit 0 ;;
    *) die "Unknown arg: $1" ;;
  esac
  shift || break
done

# Resolve script dir for relative configs
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"

has_parallel(){ has parallel || has xargs; }

run_parallel(){
  local fn=$1; shift
  (($#==0)) && return 0
  if has parallel; then
    printf '%s\n' "$@" | parallel -j"$jobs" "$fn" {} || :
  elif has xargs; then
    printf '%s\n' "$@" | xargs -r -P"$jobs" -I{} bash -c "$fn \"\$@\"" _ {} || :
  else
    local f; for f in "$@"; do "$fn" "$f" || :; done
  fi
}

check_deps(){
  local -a miss=() opt=()
  if $do_lint; then
    local -a req=(shfmt shellcheck yamlfmt yamllint ruff markdownlint)
    local -a maybe=(taplo stylua selene actionlint biome)
    local t
    for t in "${req[@]}"; do has "$t" || miss+=("$t"); done
    for t in "${maybe[@]}"; do has "$t" || opt+=("$t"); done
  fi
  if ((${#miss[@]})); then
    die "Missing required tools: ${miss[*]}"
  fi
  ((${#opt[@]})) && log "Optional missing: ${opt[*]}"
}

format_stdin(){
  local indent=${1:-2}
  [[ $indent =~ ^[0-9]+$ ]] || die "indent must be numeric"
  local spaces; spaces=$(printf "%${indent}s" "")
  local empty_seen=0 line
  while IFS= read -r line || [[ -n $line ]]; do
    line="${line//$'\t'/$spaces}"
    if [[ -z $line ]]; then
      empty_seen=1
    else
      ((empty_seen)) && printf '\n'
      printf '%s\n' "$line"
      empty_seen=0
    fi
  done
}

if [[ -n ${stdin_indent:-} ]]; then
  format_stdin "$stdin_indent"
  exit 0
fi

# discovery
excludes=(-E .git -E node_modules -E dist -E build -E target -E .cache -E __pycache__ -E .venv -E vendor -E .npm)
find_fd(){
  local -a exts=("$@")
  if has fd; then
    fd -H -t f "${excludes[@]}" "${exts[@]/#/-e}" . "$root" 2>/dev/null || true
  else
    local -a find_ex=()
    for p in .git node_modules dist build target .cache __pycache__ .venv vendor .npm; do
      find_ex+=(! -path "*/$p/*")
    done
    local first=1 args=()
    for ext in "${exts[@]}"; do
      if ((first)); then args=(-name "*.${ext}"); first=0; else args+=(-o -name "*.${ext}"); fi
    done
    find "$root" -type f \( "${args[@]}" \) "${find_ex[@]}" 2>/dev/null || true
  fi
}

lint_errors=0

fmt_shell(){ $dry_run || shfmt -w "$1"; shellcheck "$1"; }
fmt_yaml(){
  local cfg=".yamlfmt"
  [[ ! -f $cfg ]] && cfg=".qlty/configs/.yamlfmt.yaml"
  $dry_run || yamlfmt -conf "$cfg" "$1"
  yamllint -c ".qlty/configs/.yamllint.yaml" -f parsable "$1"
}
fmt_python(){ $dry_run || ruff format "$1"; ruff check "$1"; }
fmt_markdown(){ markdownlint "$1"; }
fmt_toml(){ has taplo && { $dry_run || taplo fmt "$1"; }; }
fmt_lua(){ has stylua && { $dry_run || stylua "$1"; }; has selene && selene "$1"; }
fmt_actions(){ has actionlint && actionlint -ignore SC2086 -shellcheck-shell=bash -oneline "$1"; }

lint_stage(){
  local -a sh yaml py md toml lua act
  mapfile -t sh < <(find_fd sh bash zsh)
  mapfile -t yaml < <(find_fd yml yaml)
  mapfile -t py < <(find_fd py)
  mapfile -t md < <(find_fd md markdown)
  mapfile -t toml < <(find_fd toml)
  mapfile -t lua < <(find_fd lua)
  mapfile -t act < <(find_fd yml yaml | grep -E '/\.github/workflows/[^/]+\.ya?ml$' || true)
  run_parallel fmt_shell "${sh[@]}" || ((lint_errors++))
  run_parallel fmt_yaml "${yaml[@]}" || ((lint_errors++))
  run_parallel fmt_python "${py[@]}" || ((lint_errors++))
  run_parallel fmt_markdown "${md[@]}" || ((lint_errors++))
  run_parallel fmt_toml "${toml[@]}" || :
  run_parallel fmt_lua "${lua[@]}" || :
  run_parallel fmt_actions "${act[@]}" || ((lint_errors++))
}

ok(){ printf 'v %s (%d -> %d%s)\n' "${1##*/}" "$2" "$3" "${4:+, $4}"; }
skip(){ printf 'o %s (%s)\n' "${1##*/}" "$2"; }
fail(){ printf 'x %s (%s)\n' "${1##*/}" "$2" >&2; return 1; }

min_css(){
  local f=$1 tmp out in
  [[ $f =~ \.min\.css$ ]] && return 0
  in=$(wc -c <"$f"); tmp=$(mktemp)
  if has minify; then minify --type css -o "$tmp" "$f" &>/dev/null || { rm -f "$tmp"; return 1; }
  elif has bunx; then bunx --bun lightningcss --minify "$f" -o "$tmp" &>/dev/null || { rm -f "$tmp"; return 1; }
  elif has npx; then npx -y lightningcss --minify "$f" -o "$tmp" &>/dev/null || { rm -f "$tmp"; return 1; }
  else skip "$f" "no css tool"; rm -f "$tmp"; return 0; fi
  out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
}
min_html(){
  local f=$1 tmp out in; in=$(wc -c <"$f"); tmp=$(mktemp)
  if has minify; then minify --type html -o "$tmp" "$f" &>/dev/null || { rm -f "$tmp"; return 1; }
  else skip "$f" "minify missing"; rm -f "$tmp"; return 0; fi
  out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
}
min_json(){
  local f=$1 tmp out in; [[ $f =~ \.min\.json$|package(-lock)?\.json$ ]] && return 0
  in=$(wc -c <"$f"); tmp=$(mktemp)
  if has jaq; then jaq -c . "$f" >"$tmp" 2>/dev/null || { rm -f "$tmp"; return 1; }
  elif has jq; then jq -c . "$f" >"$tmp" 2>/dev/null || { rm -f "$tmp"; return 1; }
  elif has minify; then minify --type json -o "$tmp" "$f" &>/dev/null || { rm -f "$tmp"; return 1; }
  else skip "$f" "no json tool"; rm -f "$tmp"; return 0; fi
  out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
}
min_xml(){
  local f=$1 tmp out in; [[ $f =~ \.min\.xml$ ]] && return 0
  in=$(wc -c <"$f"); tmp=$(mktemp)
  if has minify; then minify --type xml -o "$tmp" "$f" &>/dev/null || { rm -f "$tmp"; return 1; }
  elif has xmllint; then xmllint --noblanks "$f" >"$tmp" 2>/dev/null || { rm -f "$tmp"; return 1; }
  else skip "$f" "no xml tool"; rm -f "$tmp"; return 0; fi
  out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
}
min_pdf(){
  local f=$1 tmp out in tool=
  [[ $f =~ \.min\.pdf$ ]] && return 0
  tmp=$(mktemp --suffix=.pdf); in=$(wc -c <"$f")
  if has pdfinfo; then
    local prod; prod=$(pdfinfo "$f" 2>/dev/null|grep -F Producer||:)
    [[ $prod =~ Ghostscript|cairo ]] && { skip "$f" "already optimized"; rm -f "$tmp"; return 0; }
  fi
  if has qpdf && qpdf --linearize --object-streams=generate --compress-streams=y --recompress-flate "$f" "$tmp" &>/dev/null; then
    tool=qpdf
  elif has gs && gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -dCompatibilityLevel=1.7 -dDetectDuplicateImages=true -dSubsetFonts=true -dCompressFonts=true -sOutputFile="$tmp" "$f" &>/dev/null; then
    tool=gs
  else
    rm -f "$tmp"; return 1
  fi
  out=$(wc -c <"$tmp")
  if ((out < in)); then mv -f "$tmp" "$f"; ok "$f" "$in" "$out" "$tool"; else rm -f "$tmp"; skip "$f" "no gain"; fi
}
fmt_yaml_min(){
  local f=$1 tmp out in cfg=".yamlfmt"
  [[ ! -f $cfg ]] && cfg=".qlty/configs/.yamlfmt.yaml"
  in=$(wc -c <"$f"); tmp=$(mktemp)
  if has yamlfmt; then yamlfmt -conf "$cfg" "$f" >"$tmp" 2>/dev/null || { rm -f "$tmp"; return 1; }
  else skip "$f" "yamlfmt missing"; rm -f "$tmp"; return 0; fi
  out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
}
fmt_ini(){
  local f=$1 tmp out in; in=$(wc -c <"$f"); tmp=$(mktemp)
  awk 'function t(s){gsub(/^[ \t]+|[ \t]+$/,"",s);return s}
       /^[ \t]*([;#]|$)/{print;next}
       /^[ \t]*\[/{print t($0);next}
       match($0,/=/){print t(substr($0,1,RSTART-1))" = "t(substr($0,RSTART+1));next}
       {print}' "$f" >"$tmp" || { rm -f "$tmp"; return 1; }
  out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
}
fmt_conf(){
  local f=$1 tmp out in; in=$(wc -c <"$f"); tmp=$(mktemp)
  awk 'BEGIN{FS=" +"}
       /^[ \t]*([#;]|$)/{print;next}
       {gsub(/^[ \t]+|[ \t]+$/,""); sub(/[ \t]+/," "); print}' "$f" >"$tmp" || { rm -f "$tmp"; return 1; }
  out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
}

minify_stage(){
  local -a css html json xml pdf yaml ini conf
  mapfile -t css < <(find_fd css | grep -v '\.min\.css$' || true)
  mapfile -t html < <(find_fd html htm)
  mapfile -t json < <(find_fd json | grep -Ev '\.min\.json$|package(-lock)?\.json$' || true)
  mapfile -t xml < <(find_fd xml | grep -v '\.min\.xml$' || true)
  mapfile -t pdf < <(find_fd pdf | grep -v '\.min\.pdf$' || true)
  mapfile -t yaml < <(find_fd yml yaml)
  mapfile -t ini < <(find_fd ini)
  mapfile -t conf < <(find_fd conf cfg)
  run_parallel min_css "${css[@]}"
  run_parallel min_html "${html[@]}"
  run_parallel min_json "${json[@]}"
  run_parallel min_xml "${xml[@]}"
  run_parallel min_pdf "${pdf[@]}"
  run_parallel fmt_yaml_min "${yaml[@]}"
  run_parallel fmt_ini "${ini[@]}"
  run_parallel fmt_conf "${conf[@]}"
}

main(){
  check_deps
  $do_lint && lint_stage
  $do_minify && ! $dry_run && minify_stage
  ((lint_errors>0)) && die "lint errors: $lint_errors"
}
main "$@"
