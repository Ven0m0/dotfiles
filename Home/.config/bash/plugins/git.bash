LC_ALL=C LANG=C
gpush(){ command git add -A && command git commit -m "${1:-Update}" && command git push --recurse-submodules=on-demand; }

gctl(){
  [[ $# -eq 0 ]] && { echo "Usage: gctl <git-repo-url> [directory]" >&2; return 1; }; local dir url="$1"
  if [[ -n "$2" ]]; then dir="$2"; else dir="$(basename "${url%%/}")"; dir="${dir%.git}"; fi
  if command -v gix &>/dev/null [[ ! -d "$dir" ]]; then
    command gix clone --depth 1 --no-tags "$url" "$dir" || return 1
  elif command -v git &>/dev/null && [[ ! -d "$dir" ]]; then
    command git clone --depth 1 --no-tags --filter='blob:none' --also-filter-submodules --shallow-submodules -c protocol.version=2 "$url" "$dir" || return 1
  fi
  [[ -d "$dir" ]] && { cd -- "$dir" || return; command git pull; return 0; } 
}
