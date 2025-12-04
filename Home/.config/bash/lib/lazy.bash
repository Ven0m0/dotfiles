#================================ [Lazy Load] =================================
lazy_fn(){
  local fn_name="$1" src_file="$2"
  # Redefine function: unset self, source file, execute function
  eval "$fn_name(){
    unset -f $fn_name;
    . \"\$src_file\";
    \"\$fn_name\" \"\$@\";
  }"
}

lazy_build_cache(){
  local dir="$1" cache_file="$2"
  # Use fd/rg for fast parsing, fallback to grep if needed
  if command -v fd >/dev/null && command -v rg >/dev/null; then
    command fd -t f '.*\.bash$' "$dir" |
      command xargs -I{} rg -oN --no-heading '^[a-zA-Z0-9_]+[[:space:]]*\(\)' {} |
      command sd -- '^(.*):([a-zA-Z0-9_]+)\(\)' '$2\t$1' >"$cache_file"
  else
    # POSIX fallback
    find "$dir" -name '*.bash' -exec grep -H '^[a-zA-Z0-9_]*()' {} + |
      sed 's/^\(.*\):\([a-zA-Z0-9_]*\)()/\2\t\1/' >"$cache_file"
  fi
}

lazy_init(){
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
