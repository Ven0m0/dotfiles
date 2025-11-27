has git || return
gpush(){ git add -A && { git commit -m "${1:-Update}" && LC_ALL=C git push --recurse-submodules=on-demand; }; git status; }

gctl(){
  [[ $# -eq 0 ]] && { echo "Usage: gctl <git-repo-url> [directory]" >&2; return 1; }; local url="$1" dir="$2"
  [[ -n "$2" ]] || { dir="$(basename "${url%%/}")"; dir="${dir%.git}"; }
  if [[ ! -d "$dir" ]]; then
    if has gix; then
      LC_ALL=C gix clone --depth 1 --no-tags "$url" "$dir" || return 1
    else
      LC_ALL=C git clone --depth 1 --no-tags --filter='blob:none' -c protocol.version=2 -c http.version=HTTP/2 "$url" "$dir" || return 1
    fi
  else
    [[ -d "$dir" ]] && { cd -- "$dir" || return; LC_ALL=C git pull -c protocol.version=2 -c http.version=HTTP/2; return 0; }
  fi
  LC_ALL=C git status; LC_ALL=C git branch -vv
}
