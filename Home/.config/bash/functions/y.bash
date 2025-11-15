# Yazi file manager with directory change on exit
has yazi || return
y(){
  local cwd tmp_file="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp_file"
  if IFS= read -r -d '' cwd < "$tmp_file" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    cd -- "$cwd" || return 1
  fi
  rm -f -- "$tmp_file"
}
