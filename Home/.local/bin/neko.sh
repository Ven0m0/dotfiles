#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C
has() { command -v -- "$1" &>/dev/null; }
die() {
  printf '%s\n' "$1" >&2
  exit "${2:-1}"
}

nekofetch() {
  local api="${NEKO_API:-nekos}" cat="" json_tool="" img_tool="" nsfw=""
  local jsont imgt response img_url tmp_file api_base query_str json_path
  # Parse args
  while [[ $# -gt 0 ]]; do
    case $1 in
    -a | --api)
      api="${2,,}"
      shift 2
      ;;
    -j | --json)
      json_tool="$2"
      shift 2
      ;;
    -i | --img)
      img_tool="$2"
      shift 2
      ;;
    --nsfw)
      nsfw="true"
      shift
      ;;
    -*)
      printf 'Unknown: %s\n' "$1" >&2
      return 1
      ;;
    *)
      cat="$1"
      shift
      ;;
    esac
  done
  # Select JSON parser
  if has jaq; then
    jsont="jaq"
  elif has jq; then
    jsont="jq"
  else
    die "error: no json tool (install jaq or jq)"
  fi
  # Select image renderer
  if [[ -n $img_tool ]] && has "$img_tool"; then
    imgt="$img_tool"
  elif has chafa; then
    imgt="chafa"
  elif has viu; then
    imgt="viu"
  else
    imgt="cat"
  fi # API-specific config
  case $api in
  nekos | nekos.best)
    api_base="https://nekos.best/api/v2"
    json_path='.results[0].url'
    if [[ -z $cat ]]; then
      printf 'Usage: nekofetch [--api nekos] <category>\n\n'
      response="$(curl -fsSL "${api_base}/endpoints")" || { die "error: failed to fetch endpoints" 2; }
      printf 'Available categories:\n'
      has column && printf '%s' "$response" | "$jsont" -r 'to_entries[]|"\(.key)\t\(.value.format)"' | column -t -s $'\t' \
        || printf '%s' "$response" | "$jsont" -r 'keys[]'
      return 0
    fi
    query_str="$cat"
    ;;
  waifu | waifu.im)
    api_base="https://api.waifu.im"
    json_path='.images[0].url'
    if [[ -z $cat ]]; then
      printf 'Usage: nekofetch --api waifu <tag1>[,tag2,...]\n\n'
      response="$(curl -fsSL "$api_base/tags")" || { die "error: failed to fetch tags" 2; }
      printf 'Available tags:\n'
      printf 'VERSATILE:\n'
      printf '%s\n' "$response" | "$jsont" -r '.versatile[]'
      printf '\nNSFW:\n'
      printf '%s\n' "$response" | "$jsont" -r '.nsfw[]'
      return 0
    fi # Build query: tag1,tag2 -> included_tags=tag1&included_tags=tag2
    query_str="search?"
    for tag in "${cat//,/ }"; do query_str+="included_tags=${tag}&"; done
    if [[ -n $nsfw ]]; then # Add NSFW flag if requested
      query_str+="is_nsfw=true&"
    else
      query_str+="is_nsfw=false&"
    fi
    query_str="${query_str%&}"
    ;;
  *) die "error: unknown api \"$api\" (use: nekos, waifu)" ;;
  esac
  # Fetch image metadata
  if [[ $api == "waifu" || $api == "waifu.im" ]]; then
    response="$(curl -fsSL -H 'Content-Type: application/json' "$api_base/$query_str")" || {
      die "error: failed to fetch data" 3
    }
  else
    response="$(curl -fsSL "$api_base/$query_str")" || { die "error: failed to fetch data" 3; }
  fi
  img_url="$(printf '%s' "$response" | "$jsont" -r "$json_path")"
  [[ -n $img_url && $img_url != "null" ]] || { die "error: failed to extract image URL" 4; }
  # Render or download
  if [[ $imgt == "chafa" ]]; then
    curl -fsSL "$img_url" | chafa -O 6 -w 9 --clear -
  else
    tmp_file="$(mktemp "/tmp/neko_${cat//,/_}.XXXXXX")||die "mktemp failed" 5"
    trap 'rm -f "$tmp_file"' RETURN
    if curl -fsSL "$img_url" -o "$tmp_file"; then
      if [[ $imgt == "cat" ]]; then
        printf 'Image saved to: %s\n' "$tmp_file"
        trap - RETURN
      else
        "$imgt" "$tmp_file"
      fi
    else
      die "download failed" 6
    fi
  fi
}
nekofetch "$@"
