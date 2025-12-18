#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C
has(){ command -v -- "$1" &>/dev/null; }
msg(){ printf '%s\n' "$@"; }
log(){ printf '%s\n' "$@" >&2; }
die(){ printf '%s\n' "$1" >&2; exit "${2:-1}"; }

usage(){
  cat <<'EOF'
lint-all.sh [-p|--path DIR] [--jobs N] [--lint-only|--minify-only] [--dry-run] [--help]
  -p|--path DIR     Target root (default: $PWD)
  -j|--jobs N       Parallel jobs (default: nproc or 4)
  --lint-only       Only lint/format
  --minify-only     Only minify/compact
  --dry-run         Lint only; skip mutating format/minify steps
  --help            Show this
EOF
}
# defaults
root=$PWD
jobs=$(nproc 2>/dev/null||printf 4)
do_lint=true
do_minify=true
dry_run=false
while (($#)); do
  case $1 in
    -p|--path) shift; root=${1:-$root};;
    -j|--jobs) shift; jobs=${1:-$jobs};;
    --lint-only) do_minify=false;;
    --minify-only) do_lint=false;;
    --dry-run) dry_run=true;;
    --help) usage; exit 0;;
    *) die "Unknown arg: $1";;
  esac
  shift
done
# repo-relative resolve
s=${BASH_SOURCE[0]}
[[ $s != /* ]] && s=$PWD/$s
cd -P -- "${s%/*}"
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
# dependency gates
check_deps(){
  local -a miss=() opt=()
  if $do_lint; then
    local -a req=(shfmt shellcheck yamlfmt yamllint ruff markdownlint)
    local -a may=(taplo stylua selene actionlint biome)
    local t
    for t in "${req[@]}"; do has "$t" || miss+=("$t"); done
    for t in "${may[@]}"; do has "$t" || opt+=("$t"); done
  fi
  if $do_minify; then
    has minify || has bunx || has npx || miss+=(minify/bun/node)
    has jaq || has jq || has minify || miss+=(jaq/jq/minify)
    has qpdf || has gs || miss+=(qpdf/gs)
    has awk || miss+=(awk)
    has xmllint || has minify || miss+=(xmllint/minify)
  end
  if ((${#miss[@]})); then
    die "Missing deps: ${miss[*]}"
  fi
  ((${#opt[@]})) && log "Optional missing: ${opt[*]}"
}
# file discovery
excludes=(-E .git -E node_modules -E dist -E build -E target -E .cache -E __pycache__ -E .venv -E vendor -E .npm)
find_fd(){
  local -a exts=("$@")
  local cmd
  if has fd; then
    cmd=(fd -H -t f "${excludes[@]}" . "$root")
    "${cmd[@]}" "${exts[@]/#/-e}" 2>/dev/null || true
  else
    local -a find_ex=()
    for p in .git node_modules dist build target .cache __pycache__ .venv vendor .npm; do
      find_ex+=(! -path "*/$p/*")
    done
    find "$root" -type f \( "${exts[0]/#/-name *.}" \) "${find_ex[@]}" 2>/dev/null || true
  fi
}
# lint/format functions
fmt_shell(){
  local f=$1
  $dry_run || shfmt -w "$f"
  shellcheck "$f"
}
fmt_yaml(){
  local f=$1 cfg=".yamlfmt"
  [[ ! -f $cfg ]] && cfg=".qlty/configs/.yamlfmt.yaml"
  $dry_run || yamlfmt -conf "$cfg" "$f"
  yamllint -c ".qlty/configs/.yamllint.yaml" -f parsable "$f"
}
fmt_python(){
  local f=$1
  $dry_run || ruff format "$f"
  ruff check "$f"
}
fmt_markdown(){
  local f=$1
  markdownlint "$f"
}
fmt_toml(){
  local f=$1
  if has taplo; then $dry_run || taplo fmt "$f"; fi
}
fmt_lua(){
  local f=$1
  if has stylua; then $dry_run || stylua "$f"; fi
  if has selene; then selene "$f"; fi
}
fmt_actions(){
  local f=$1
  if has actionlint; then actionlint -ignore SC2086 -shellcheck-shell=bash -oneline "$f"; fi
}
lint_stage(){
  local -a sh_files yaml_files py_files md_files toml_files lua_files act_files
  mapfile -t sh_files < <(find_fd sh bash zsh)
  mapfile -t yaml_files < <(find_fd yml yaml)
  mapfile -t py_files < <(find_fd py)
  mapfile -t md_files < <(find_fd md markdown)
  mapfile -t toml_files < <(find_fd toml)
  mapfile -t lua_files < <(find_fd lua)
  mapfile -t act_files < <(find_fd yml yaml | grep -E '/\.github/workflows/[^/]+\.y[a]?ml$' || true)

  local -i errs=0
  run_parallel fmt_shell "${sh_files[@]}" || ((errs++))
  run_parallel fmt_yaml "${yaml_files[@]}" || ((errs++))
  run_parallel fmt_python "${py_files[@]}" || ((errs++))
  run_parallel fmt_markdown "${md_files[@]}" || ((errs++))
  run_parallel fmt_toml "${toml_files[@]}" || :
  run_parallel fmt_lua "${lua_files[@]}" || :
  run_parallel fmt_actions "${act_files[@]}" || ((errs++))
  return "$errs"
}
# minifiers
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
  local f=$1 tmp out in
  in=$(wc -c <"$f"); tmp=$(mktemp)
  if has minify; then minify --type html -o "$tmp" "$f" &>/dev/null || { rm -f "$tmp"; return 1; }
  else skip "$f" "minify missing"; rm -f "$tmp"; return 0; fi
  out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
}
min_json(){
  local f=$1 tmp out in
  [[ $f =~ \.min\.json$|package(-lock)?\.json$ ]] && return 0
  in=$(wc -c <"$f"); tmp=$(mktemp)
  if has jaq; then jaq -c . "$f" >"$tmp" 2>/dev/null || { rm -f "$tmp"; return 1; }
  elif has jq; then jq -c . "$f" >"$tmp" 2>/dev/null || { rm -f "$tmp"; return 1; }
  elif has minify; then minify --type json -o "$tmp" "$f" &>/dev/null || { rm -f "$tmp"; return 1; }
  else skip "$f" "no json tool"; rm -f "$tmp"; return 0; fi
  out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
}
min_xml(){
  local f=$1 tmp out in
  [[ $f =~ \.min\.xml$ ]] && return 0
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
    local prod
    prod=$(pdfinfo "$f" 2>/dev/null|grep -F Producer||:)
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
  local f=$1 tmp out in
  in=$(wc -c <"$f"); tmp=$(mktemp)
  awk 'function t(s){gsub(/^[ \t]+|[ \t]+$/,"",s);return s}
       /^[ \t]*([;#]|$)/{print;next}
       /^[ \t]*\[/{print t($0);next}
       match($0,/=/){print t(substr($0,1,RSTART-1))" = "t(substr($0,RSTART+1));next}
       {print}' "$f" >"$tmp" || { rm -f "$tmp"; return 1; }
  out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
}
fmt_conf(){
  local f=$1 tmp out in
  in=$(wc -c <"$f"); tmp=$(mktemp)
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
  local -i lint_err=0
  $do_lint && lint_stage || lint_err=$?
  $do_minify && ! $dry_run && minify_stage
  if ((lint_err>0)); then die "lint errors: $lint_err"; fi
}
main "$@"
