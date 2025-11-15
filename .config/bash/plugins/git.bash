has git || return
LC_ALL=C LANG=C
gpush(){ 
  command git add -A
  command git commit -m "${1:-Update}" && command git push --recurse-submodules=on-demand \
    -c protocol.version=2 -c http.version=HTTP/2 -c http.sslVersion=tlsv1.3
  command git status --long
}

gctl(){
  [[ $# -eq 0 ]] && { echo "Usage: gctl <git-repo-url> [directory]" >&2; return 1; }; local url="$1" dir="$2"
  if [[ ! -n "$2" ]]; then dir="$(basename "${url%%/}")"; dir="${dir%.git}"; fi
  if [[ ! -d "$dir" ]]; then
    if has gix; then
      command gix clone --depth 1 --no-tags -c protocol.version=2 -c http.version=HTTP/2 -c http.sslVersion=tlsv1.3 "$url" "$dir" || return 1
    else
      command git clone --depth 1 --no-tags --filter='blob:none' --also-filter-submodules --shallow-submodules \
        -c protocol.version=2 -c http.version=HTTP/2 -c http.sslVersion=tlsv1.3 "$url" "$dir" || return 1
    fi
  else
    [[ -d "$dir" ]] && { cd -- "$dir" || return; command git pull -c protocol.version=2 -c http.version=HTTP/2 -c http.sslVersion=tlsv1.3; return 0; }
  fi
}
