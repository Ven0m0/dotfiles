#================================== [Async] ===================================
async_exec() {
  # Execute a function in a detached background subshell.
  ( "$@" &>/dev/null & disown )
}

welcome_fetch() {
  # Wait for the parent shell to become idle before running.
  sleep 2
  local fetch_cmd=''
  if has hyfetch && has fastfetch; then
    fetch_cmd='hyfetch -b fastfetch -p transgender'
  elif has fastfetch; then
    fetch_cmd='fastfetch'
  fi
  [[ -n "$fetch_cmd" ]] && eval "$fetch_cmd"
}

path_dedupe() {
  local new_path=""
  declare -A seen
  IFS=:
  for p in "${PATH[@]}"; do
    [[ -z "$p" || -n "${seen[$p]}" ]] && continue
    seen[$p]=1
    new_path="${new_path:+$new_path:}$p"
  done
  export PATH="$new_path"
}
