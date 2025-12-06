#!/usr/bin/env bash
# Only run for interactive shells
[[ $- != *i* ]] && return

#============================== [Framework Init] ==============================
export BASH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bash"
export BASH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/bash"

# Ensure core directories exist
mkdir -p "$BASH_CONFIG_DIR"/{lib,plugins,functions} "$BASH_CACHE_DIR"

#================================= [Helpers] ==================================
has() { command -v -- "$1" &>/dev/null; }
ifsource() { [[ -r ${1/#\~\//${HOME}/} ]] && . "${1/#\~\//${HOME}/}"; }
exportif() { [[ -e $2 ]] && export "$1=$2"; }
prepend_var() {
  local -n p="$1"
  [[ -d $2 && ":$p:" != *":$2:"* ]] && p="$2${p:+:$p}"
}
prependpath() { prepend_var PATH "$1"; }

#================================ [Lazy Load] =================================
lazy_fn() {
  local fn_name="$1" src_file="$2"
  # Redefine function: unset self, source file, execute function
  eval "$fn_name(){
    unset -f $fn_name;
    . \"\$src_file\";
    \"\$fn_name\" \"\$@\";
  }"
}

lazy_build_cache() {
  local dir="$1" cache_file="$2"
  # Use fd/rg for fast parsing, fallback to grep if needed
  if command -v fd >/dev/null && command -v rg >/dev/null; then
    # Optimized: rg can search multiple files directly, no xargs needed
    command fd -t f '.*\.bash$' "$dir" -X rg -oN --no-heading '^[a-zA-Z0-9_]+[[:space:]]*\(\)' \
      | command sd -- '^(.*):([a-zA-Z0-9_]+)\(\)' '$2\t$1' >"$cache_file"
  else
    # POSIX fallback - uses + for batching instead of individual exec
    find "$dir" -name '*.bash' -exec grep -H '^[a-zA-Z0-9_]*()' {} + \
      | sed 's/^\(.*\):\([a-zA-Z0-9_]*\)()/\2\t\1/' >"$cache_file"
  fi
}

lazy_init() {
  local dir="$1" cache_file="$BASH_CACHE_DIR/fn_cache.tsv"
  local rebuild=0

  # Rebuild if cache missing
  if [[ ! -f $cache_file ]]; then
    rebuild=1
  else
    # Fast check: Rebuild only if any file in dir is newer than cache
    # This stops at the first newer file found, minimizing I/O
    if [[ -n $(find "$dir" -type f -newer "$cache_file" -print -quit 2>/dev/null) ]]; then
      rebuild=1
    fi
  fi

  if [[ $rebuild -eq 1 ]]; then
    lazy_build_cache "$dir" "$cache_file"
  fi

  # Create stubs
  if [[ -f $cache_file ]]; then
    while IFS=$'\t' read -r fn_name src_file; do
      [[ -n $fn_name && -n $src_file ]] && lazy_fn "$fn_name" "$src_file"
    done <"$cache_file"
  fi
}

#================================== [Async] ===================================
async_exec() {
  # Execute a function in a detached background subshell.
  (
    "$@" &>/dev/null &
    disown
  )
}

welcome_fetch() {
  if has hyfetch; then
    hyfetch
  elif has fastfetch; then
    fastfetch
  fi
}

path_dedupe() {
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

# Load plugins (sourced in order by filename)
shopt -s nullglob globstar
for plugin in "${BASH_CONFIG_DIR}/plugins/"*.{bash,sh}; do
  . "$plugin"
done
unset plugin

# Load completions
ifsource "${BASH_CONFIG_DIR}/completer.sh"

# Initialize lazy-loaded functions
lazy_init "${BASH_CONFIG_DIR}/functions"

# Run async post-startup tasks
async_exec path_dedupe
async_exec welcome_fetch

# Cleanup
unset -f lazy_init lazy_build_cache lazy_fn async_exec welcome_fetch path_dedupe
