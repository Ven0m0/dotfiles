#================================== [Async] ===================================
async_exec(){
  # Execute a function in a detached background subshell.
  (
    "$@" &>/dev/null &
    disown
  )
}

welcome_fetch(){
  # Wait for the parent shell to become idle before running.
  sleep 2
  local fetch_cmd=''
  if has hyfetch && has fastfetch; then
    fetch_cmd='hyfetch -b fastfetch -p transgender'
  elif has fastfetch; then
    fetch_cmd='fastfetch'
  fi
  [[ -n $fetch_cmd ]] && eval "$fetch_cmd"
}

path_dedupe(){
  local new_path=""
  local -A seen
  local old_ifs="$IFS"
  IFS=':'
  set -f # Disable globbing to safely handle paths with *
  for p in $PATH; do
    [[ -z $p || -n ${seen[$p]} ]] && continue
    seen[$p]=1
    new_path="${new_path:+$new_path:}$p"
  done
  set +f
  IFS="$old_ifs"
  export PATH="$new_path"
}
