#================================= [Git Funcs] ================================
if has gix; then
  gclone(){ command gix clone --depth 1 --no-tags "$@"; }
else
  gclone(){ command git clone --filter=blob:none --depth 1 --no-tags -c protocol.version=2 "$@"; }
fi

gpush(){ command git add -A && command git commit -m "${1:-Update}" && command git push --recurse-submodules=on-demand; }
