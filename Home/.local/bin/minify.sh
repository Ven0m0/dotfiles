#!/usr/bin/env bash
set -euo pipefail;shopt -s nullglob globstar;IFS=$'\n\t'
export LC_ALL=C LANG=C LANGUAGE=C
readonly out="${1:-.}" jobs=$(nproc 2>/dev/null || printf 4)
readonly red=$'\e[31m' grn=$'\e[32m' ylw=$'\e[33m' rst=$'\e[0m'
has(){ command -v -- "$1" &>/dev/null; }
die(){ printf '%sx%s %s\n' "$red" "$rst" "$*" >&2; exit 1; }
ok(){ printf '%sv%s %s (%d -> %d%s)\n' "$grn" "$rst" "${1##*/}" "$2" "$3" "${4:+, $4}"; }
skip(){ printf '%so%s %s (%s)\n' "$ylw" "$rst" "${1##*/}" "$2"; }
fail(){ printf '%sx%s %s (%s)\n' "$red" "$rst" "${1##*/}" "$2" >&2; return 1; }
check_deps(){
  local -a m=()
  has minify || has bunx || has npx || m+=(minify/bun/node)
  has jaq || has jq || has minify || m+=(jaq/jq/minify)
  has awk || m+=(awk)
  ((${#m[@]} > 0)) && die "Missing: ${m[*]}"
}
minify_css(){
  local f=$1 tmp out
  tmp=$(mktemp)
  local in
  in=$(wc -c <"$f")
  [[ $f =~ \.min\.css$ ]] && return 0
  if has minify; then
    minify --type css -o "$tmp" "$f" &>/dev/null || { rm -f "$tmp"; fail "$f" "minify failed"; }
  elif has bunx; then
    bunx --bun lightningcss --minify "$f" -o "$tmp" &>/dev/null || { rm -f "$tmp"; fail "$f" "lightningcss failed"; }
  elif has npx; then
    npx -y lightningcss --minify "$f" -o "$tmp" &>/dev/null || { rm -f "$tmp"; fail "$f" "lightningcss failed"; }
  else
    rm -f "$tmp"; skip "$f" "no css minifier"; return 0
  fi
  out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
}
minify_html(){
  local f=$1 tmp out
  tmp=$(mktemp)
  local in
  in=$(wc -c <"$f")
  if has minify; then
    minify --type html -o "$tmp" "$f" &>/dev/null || { rm -f "$tmp"; fail "$f" "minify failed"; }
  else
    rm -f "$tmp"; skip "$f" "minify not installed"; return 0
  fi
  out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
}
minify_json(){
  local f=$1 tmp out
  tmp=$(mktemp)
  local in
  in=$(wc -c <"$f")
  [[ $f =~ \.min\.json$|package(-lock)?\.json$ ]] && return 0
  if has jaq; then
    jaq -c . "$f" >"$tmp" 2>/dev/null || { rm -f "$tmp"; fail "$f" "jaq failed"; }
  elif has jq; then
    jq -c . "$f" >"$tmp" 2>/dev/null || { rm -f "$tmp"; fail "$f" "jq failed"; }
  elif has minify; then
    minify --type json -o "$tmp" "$f" &>/dev/null || { rm -f "$tmp"; fail "$f" "minify failed"; }
  else
    rm -f "$tmp"; skip "$f" "no json minifier"; return 0
  fi
  out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
}
minify_xml(){
  local f=$1 tmp out
  tmp=$(mktemp)
  local in
  in=$(wc -c <"$f")
  [[ $f =~ \.min\.xml$ ]] && return 0
  if has minify; then
    minify --type xml -o "$tmp" "$f" &>/dev/null || { rm -f "$tmp"; fail "$f" "minify failed"; }
  elif has xmllint; then
    xmllint --noblanks "$f" >"$tmp" 2>/dev/null || { rm -f "$tmp"; fail "$f" "xmllint failed"; }
  else
    rm -f "$tmp"; skip "$f" "no xml minifier"; return 0
  fi
  out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
}
minify_pdf(){
  local f=$1 tmp out tool
  tmp=$(mktemp --suffix=.pdf)
  local in
  in=$(wc -c <"$f")
  [[ $f =~ \.min\.pdf$ ]] && return 0
  if has pdfinfo; then
    local prod
    prod=$(pdfinfo "$f" 2>/dev/null | grep -F Producer || :)
    [[ $prod =~ Ghostscript|cairo ]] && { skip "$f" "already processed"; rm -f "$tmp"; return 0; }
  fi
  if has qpdf && qpdf --linearize --object-streams=generate --compress-streams=y --recompress-flate "$f" "$tmp" &>/dev/null; then
    tool=qpdf
  elif has gs && gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -dCompatibilityLevel=1.7 -dDetectDuplicateImages=true -dSubsetFonts=true -dCompressFonts=true -sOutputFile="$tmp" -c 33550336 setvmthreshold -f "$f" &>/dev/null; then
    tool=gs
  else
    rm -f "$tmp"; fail "$f" "no optimizer"
  fi
  out=$(wc -c <"$tmp")
  if ((out < in)); then
    mv -f "$tmp" "$f"; ok "$f" "$in" "$out" "$tool"
  else
    rm -f "$tmp"; skip "$f" "no reduction"
  fi
}
fmt_yaml(){
  local f=$1 tmp out
  tmp=$(mktemp)
  local in
  in=$(wc -c <"$f")
  if has yamlfmt; then
    yamlfmt -q "$f" -out "$tmp" &>/dev/null || { rm -f "$tmp"; fail "$f" "yamlfmt failed"; }
    out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
  else
    rm -f "$tmp"; skip "$f" "yamlfmt not installed"; return 0
  fi
}
fmt_ini(){
  local f=$1 tmp out
  tmp=$(mktemp)
  local in
  in=$(wc -c <"$f")
  awk 'function t(s){gsub(/^[ \t]+|[ \t]+$/,"",s);return s}/^[ \t]*([;#]|$)/{print;next}/^[ \t]*\[/{print t($0);next}match($0,/=/){print t(substr($0,1,RSTART-1))" = "t(substr($0,RSTART+1));next}' "$f" >"$tmp" 2>/dev/null || { rm -f "$tmp"; fail "$f" "awk failed"; }
  out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
}
fmt_conf(){
  local f=$1 tmp out
  tmp=$(mktemp)
  local in
  in=$(wc -c <"$f")
  awk 'BEGIN{FS=" +";placeholder="\033";align_all_columns=z_get_var(align_all_columns,0);align_columns_if_first_matches=align_all_columns?0:z_get_var(align_columns_if_first_matches,0);align_columns=align_all_columns||align_columns_if_first_matches;align_comments=z_get_var(align_comments,1);comment_regex=align_comments?z_get_var(comment_regex,"[#;]"):""}/^[[:blank:]]*$/{if(!last_empty){c_print_section();if(output_lines){empty_pending=1}}last_empty=1;next}{sub(/^ +/,"",$0);if(empty_pending){print"";empty_pending=0}last_empty=0;if(align_columns_if_first_matches&&actual_lines&&(!comment_regex||$1!~"^"comment_regex"([^[:blank:]]|$)")&&$1!=setting){b_queue_entries()}entry_line++;section_line++;field_count[entry_line]=0;comment[section_line]="";for(i=1;i<=NF;i++){if(a_process_regex("[\"'\''\\\\]","(([^ \"'\''\\\\]|\\\\.)*(\"([^\"]|\\\\\")*\"|'\''([^'\'']|\\\\'\'')* '\''))*([^ \\\\]|\\\\.|\\\\$)*")){a_store_field(field_value)}else if(comment_regex&&(a_process_regex(comment_regex,comment_regex".*",1))){sub(/ +$/,"",field_value);comment[section_line]=field_value}else if(length($i)){a_store_field($i"");a_replace_field(placeholder)}}if(field_count[entry_line]){if(!actual_lines){setting=entry[entry_line,1]}actual_lines++}}END{c_print_section()}function a_process_regex(r,v,s,_p,_d){if(match($i,r)){if(s&&RSTART>1){a_replace_field(substr($i,1,RSTART-1)" "substr($i,RSTART));return}_p=$0;sub("^( |"placeholder")*","",_p);if(match(_p,"^"v)){field_value=substr(_p,RSTART,RLENGTH);_d=length($0)-length(_p);$0=substr($0,1,RSTART-1+_d)placeholder substr($0,RSTART+RLENGTH+_d);return 1}}}function a_replace_field(v,_n){if(!match($0,"^ *[^ ]+( +[^ ]+){"(i-1)"}")){$i=v;return}_n=substr($0,RLENGTH+1);$0=substr($0,1,RLENGTH);$i="";$0=$0 v _n}function a_store_field(v,_l){field_count[entry_line]=i;entry[entry_line,i]=v;_l=length(v);field_width[i]=_l>field_width[i]?_l:field_width[i]}function b_queue_entries(_o,_i,_j,_l){_o=section_line-entry_line;for(_i=1;_i<=entry_line;_i++){_l="";for(_j=1;_j<=field_count[_i];_j++){if(align_columns&&actual_lines>1&&setting){_l=_l sprintf("%-"field_width[_j]"s ",entry[_i,_j])}else{_l=_l sprintf("%s ",entry[_i,_j])}}sub(" $","",_l);section[_o+_i]=_l}entry_line=0;actual_lines=0;for(_j in field_width){delete field_width[_j]}}function c_print_section(_i,_len,_max,_l){b_queue_entries();for(_i=1;_i<=section_line;_i++){_len=length(section[_i]);_max=_len>_max?_len:_max}for(_i=1;_i<=section_line;_i++){_l=section[_i];if(comment[_i]){_l=(_l~/[^\t]/?sprintf("%-"_max"s ",_l):_l)comment[_i]}print _l;output_lines++}section_line=0}function z_get_var(v,d){return z_is_set(v)?v:d}function z_is_set(v){return!(v==""&&v==0)}' "$f" >"$tmp" 2>/dev/null || { rm -f "$tmp"; fail "$f" "awk failed"; }
  out=$(wc -c <"$tmp"); mv -f "$tmp" "$f"; ok "$f" "$in" "$out"
}
export -f minify_css minify_html minify_json minify_xml minify_pdf fmt_yaml fmt_ini fmt_conf ok skip fail has
export red grn ylw rst
run_parallel(){
  local fn=$1; shift
  (($# == 0)) && return 0
  if has parallel; then
    printf '%s\n' "$@" | parallel -j"$jobs" "$fn" {} || :
  elif has xargs; then
    printf '%s\n' "$@" | xargs -r -P"$jobs" -I{} bash -c "$fn \"\$@\"" _ {} || :
  else
    local f; for f in "$@"; do "$fn" "$f" || :; done
  fi
}
process(){
  local -a css=() html=() json=() xml=() pdf=() yaml=() ini=() conf=()
  local ex='-Enode_modules -Edist -E.git -E.cache -Ebuild -Etarget -E__pycache__ -E.venv -E.npm -Evendor'
  if has fd; then
    mapfile -t css < <(fd -ecss -tf -E'*.min.css' $ex . "$out" 2>/dev/null)
    mapfile -t html < <(fd -ehtml -ehtm -tf $ex . "$out" 2>/dev/null)
    mapfile -t json < <(fd -ejson -tf -E'*.min.json' -E'package*.json' $ex . "$out" 2>/dev/null)
    mapfile -t xml < <(fd -exml -tf -E'*.min.xml' $ex . "$out" 2>/dev/null)
    mapfile -t pdf < <(fd -epdf -tf -E'*.min.pdf' $ex . "$out" 2>/dev/null)
    mapfile -t yaml < <(fd -eyml -eyaml -tf $ex . "$out" 2>/dev/null)
    mapfile -t ini < <(fd -eini -tf $ex . "$out" 2>/dev/null)
    mapfile -t conf < <(fd -econf -ecfg -tf $ex . "$out" 2>/dev/null)
  else
    local -a fp=(! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/dist/*" ! -path "*/.cache/*" ! -path "*/build/*" ! -path "*/target/*" ! -path "*/__pycache__/*" ! -path "*/.venv/*" ! -path "*/.npm/*" ! -path "*/vendor/*")
    mapfile -t css < <(find "$out" -type f -name '*.css' ! -name '*.min.css' "${fp[@]}" 2>/dev/null)
    mapfile -t html < <(find "$out" -type f \( -name '*.html' -o -name '*.htm' \) "${fp[@]}" 2>/dev/null)
    mapfile -t json < <(find "$out" -type f -name '*.json' ! -name '*.min.json' ! -name 'package*.json' "${fp[@]}" 2>/dev/null)
    mapfile -t xml < <(find "$out" -type f -name '*.xml' ! -name '*.min.xml' "${fp[@]}" 2>/dev/null)
    mapfile -t pdf < <(find "$out" -type f -name '*.pdf' ! -name '*.min.pdf' "${fp[@]}" 2>/dev/null)
    mapfile -t yaml < <(find "$out" -type f \( -name '*.yml' -o -name '*.yaml' \) "${fp[@]}" 2>/dev/null)
    mapfile -t ini < <(find "$out" -type f -name '*.ini' "${fp[@]}" 2>/dev/null)
    mapfile -t conf < <(find "$out" -type f \( -name '*.conf' -o -name '*.cfg' \) "${fp[@]}" 2>/dev/null)
  fi
  local -i total=$((${#css[@]} + ${#html[@]} + ${#json[@]} + ${#xml[@]} + ${#pdf[@]} + ${#yaml[@]} + ${#ini[@]} + ${#conf[@]}))
  ((total == 0)) && { skip "." "No files found"; return 0; }
  run_parallel minify_css "${css[@]}"
  run_parallel minify_html "${html[@]}"
  run_parallel minify_json "${json[@]}"
  run_parallel minify_xml "${xml[@]}"
  run_parallel minify_pdf "${pdf[@]}"
  run_parallel fmt_yaml "${yaml[@]}"
  run_parallel fmt_ini "${ini[@]}"
  run_parallel fmt_conf "${conf[@]}"
  printf '\n%sv%s Processed %d files\n' "$grn" "$rst" "$total"
}
check_deps; process
