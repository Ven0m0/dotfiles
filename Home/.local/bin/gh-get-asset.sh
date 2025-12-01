#!/usr/bin/env bash
set -eufo pipefail
shopt -s nullglob
export LC_ALL=C LANG=C
# Download GitHub release assets
# https://github.com/chmouel/gh-get-asset
# Cleanup
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT
# Defaults
release=""
output_opt=(-O)
curl_args=(-fsSL)
<<<<<<< Updated upstream
die(){
||||||| Stash base
die() {
=======
has() { command -v "$1" &>/dev/null; }
die() {
>>>>>>> Stashed changes
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

usage(){
  cat <<'EOF'
gh-get-asset - Download GitHub release assets

USAGE:
  gh-get-asset [OPTIONS] OWNER/REPO ASSET_SUBSTRING

ARGUMENTS:
  OWNER/REPO         GitHub repository (e.g., chmouel/gosmee)
  ASSET_SUBSTRING    Substring to match in asset name

OPTIONS:
  -o FILE            Output to FILE instead of asset name
  -r RELEASE         Specific release tag (default: latest)
  -s, --silent       Silent mode (no progress)
  -h, --help         Show this help message

DESCRIPTION:
  Downloads release assets from GitHub repositories. Searches for
  assets matching the given substring in the asset name.

EXAMPLES:
  gh-get-asset chmouel/gosmee Linux-ARM64.rpm
  gh-get-asset -o /tmp/binary.tar.gz user/repo linux-amd64
  gh-get-asset -r v1.2.3 owner/repo asset.zip

REQUIREMENTS:
  - curl (for downloading)
  - jq (for JSON parsing)

AUTHOR:
  Chmouel Boudjnah - https://fosstodon.org/web/@chmouel
EOF
}

gh_get_release(){
  local repo="$1" substring="$2"

  curl -fsSL -o "$TMP" "https://api.github.com/repos/${repo}/releases"

  local selector='.[0]'
  if [[ -n $release ]]; then
    selector=".[] | select(.tag_name==\"${release}\")"
  fi

  jq -rM "${selector}.assets[]|select(.name| contains(\"${substring}\"))? | .browser_download_url" <"$TMP"
}

main() { # Parse options
  while getopts "r:so:h" opt; do
    case "$opt" in
    r) release="$OPTARG" ;;
    s) curl_args+=(-s) ;;
    o) output_opt=(-o "$OPTARG") ;;
    h)
      usage
      exit 0
      ;;
    *) die "Invalid option. Use -h for help." ;;
    esac
  done
  shift $((OPTIND - 1))

  # Check arguments
  [[ $# -eq 2 ]] || die "Expected 2 arguments. Use -h for help."

  # Check dependencies
  has curl || die "curl is required"
  has jq || die "jq is required"

  local repo="$1" substring="$2"

  # Get assets
  local -a assets
  mapfile -t assets < <(gh_get_release "$repo" "$substring")

  if [[ ${#assets[@]} -eq 0 ]]; then
    die "Could not find asset matching '${substring}' in ${repo}"
  fi

  # Download each asset
  for asset in "${assets[@]}"; do
    printf 'Downloading: %s\n' "$asset"
    curl "${output_opt[@]}" "${curl_args[@]}" "$asset"
  done

  printf '✓ Download complete\n'
}

main "$@"
