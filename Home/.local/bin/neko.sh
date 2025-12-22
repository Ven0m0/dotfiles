#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C
has(){ command -v -- "$1" &>/dev/null; }
die(){ printf '%s\n' "$1" >&2; exit "${2:-1}"; }

show_help(){
  cat <<'EOF'
nekofetch - Fetch and display anime images in terminal

USAGE:
  nekofetch [OPTIONS] <category>
  nekofetch --api waifu <tag>[,tag2,...]

OPTIONS:
  -a, --api <name>   API to use: nekos (default), waifu
  -i, --img <tool>   Force image viewer: chafa, viu, cat
  -j, --json <tool>  Force JSON parser: jaq, jq
  --nsfw             Enable NSFW content (waifu.im only)

EXAMPLES:
  nekofetch neko              # Random neko from nekos.best
  nekofetch --api nekos       # List all nekos.best categories
  nekofetch --api waifu       # List all waifu.im tags
  nekofetch -a waifu maid     # Maid images from waifu.im
  nekofetch -a waifu waifu,maid --nsfw

APIS:
  nekos.best  - Anime images/GIFs (neko, kitsune, hug, pat, etc.)
  waifu.im    - Anime waifus with tag filtering (maid, waifu, etc.)
EOF
}
cleanup(){ [[ -f ${tmp_file:-} ]] && rm -f "$tmp_file"; }

nekofetch(){
  local api="${NEKO_API:-nekos}" cat="" json_tool="" img_tool="" nsfw=""
  local jsont imgt response img_url api_base query_str json_path is_gif=0
  tmp_file=""
  trap cleanup EXIT
  while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help) show_help; return 0 ;;
    -a | --api) api="${2,,}"; shift 2 ;;
    -j | --json) json_tool="$2"; shift 2 ;;
    -i | --img) img_tool="$2"; shift 2 ;;
    --nsfw) nsfw="true"; shift ;;
    -*)
      printf 'Unknown option: %s\nTry: nekofetch --help\n' "$1" >&2
      return 1 ;;
    *) cat="$1"; shift ;;
    esac
  done

  # JSON parser
  if [[ -n $json_tool ]] && has "$json_tool"; then
    jsont="$json_tool"
  elif has jaq; then
    jsont="jaq"
  elif has jq; then
    jsont="jq"
  else
    die "error: install jaq or jq"
  fi
  # Image renderer
  if [[ -n $img_tool ]] && has "$img_tool"; then
    imgt="$img_tool"
  elif has chafa; then
    imgt="chafa"
  elif has viu; then
    imgt="viu"
  else
    imgt="cat"
  fi

  # API config
  case $api in
  nekos | nekos.best)
    api_base="https://nekos.best/api/v2"
    json_path='.results[0].url'
    if [[ -z $cat ]]; then
      printf 'nekos.best categories:\n\n'
      response="$(curl -fsSL "${api_base}/endpoints")" || die "error: failed to fetch endpoints" 2
      if has column; then
        printf '%s' "$response" | "$jsont" -r 'to_entries[]|"\(.key)\t\(.value.format)"' | column -t -s $'\t'
      else
        printf '%s' "$response" | "$jsont" -r 'keys[]'
      fi
      printf '\nUsage: nekofetch <category>\n'
      return 0
    fi
    query_str="$cat"
    ;;
  waifu | waifu.im)
    api_base="https://api.waifu.im"
    json_path='.images[0].url'
    if [[ -z $cat ]]; then
      printf 'waifu.im tags:\n\n'
      response="$(curl -fsSL "$api_base/tags")" || die "error: failed to fetch tags" 2
      printf 'SFW: '
      printf '%s' "$response" | "$jsont" -r '.versatile|join(", ")'
      printf '\nNSFW: '
      printf '%s' "$response" | "$jsont" -r '.nsfw|join(", ")'
      printf '\n\nUsage: nekofetch -a waifu <tag>[,tag2] [--nsfw]\n'
      return 0
    fi
    query_str="search?"
    for tag in ${cat//,/ }; do query_str+="included_tags=${tag}&"; done
    [[ -n $nsfw ]] && query_str+="is_nsfw=true" || query_str+="is_nsfw=false"
    ;;
  *) die "error: unknown api '$api' (use: nekos, waifu)" ;;
  esac

  # Fetch
  if [[ $api == waifu || $api == waifu.im ]]; then
    response="$(curl -fsSL -H 'Content-Type: application/json' "$api_base/$query_str")" || die "error: fetch failed" 3
  else
    response="$(curl -fsSL "$api_base/$query_str")" || die "error: fetch failed" 3
  fi

  img_url="$(printf '%s' "$response" | "$jsont" -r "$json_path")"
  [[ -n $img_url && $img_url != null ]] || die "error: no image URL in response" 4

  # GIF detection
  [[ ${img_url,,} == *.gif ]] && is_gif=1

  # Render
  if ((is_gif)); then
    tmp_file="$(mktemp "/tmp/neko_XXXXXX.gif")" || die "mktemp failed" 5
    curl -fsSL "$img_url" -o "$tmp_file" || die "download failed" 6
    case $imgt in
    chafa) chafa --animate on --duration inf -w 9 "$tmp_file" ;;
    viu) viu -w 80 "$tmp_file" ;;
    *)
      printf 'GIF saved: %s\n' "$tmp_file"
      trap - EXIT ;;
    esac
  else
    case $imgt in
    chafa) curl -fsSL "$img_url" | chafa -O 6 -w 9 - ;;
    viu) curl -fsSL "$img_url" | viu -w 80 - ;;
    *)
      tmp_file="$(mktemp "/tmp/neko_XXXXXX")" || die "mktemp failed" 5
      curl -fsSL "$img_url" -o "$tmp_file" || die "download failed" 6
      printf 'Saved: %s\n' "$tmp_file"
      trap - EXIT ;;
    esac
  fi
}
nekofetch "$@"
