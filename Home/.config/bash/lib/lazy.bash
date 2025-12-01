#================================ [Lazy Load] =================================
lazy_fn(){
  local fn_name="$1" src_file="$2"
  # Redefine the function to source the file and re-execute.
  eval "$fn_name(){
    unset -f $fn_name;
    . \"\$src_file\";
    \"\$fn_name\" \"\$@\";
  }"
}

lazy_build_cache(){
  local dir="$1" cache_file="$2"
  # Use fd and rg for high-performance function parsing.
  command fd -t f '.*\.bash$' "$dir" \
    | command xargs -I{} rg -oN --no-heading '^[a-zA-Z0-9_]+[[:space:]]*\(\)' {} \
    | command sd -- '^(.*):([a-zA-Z0-9_]+)\(\)' '$2\t$1' >"$cache_file"
}

lazy_init(){
  local dir="$1" cache_file="$BASH_CACHE_DIR/fn_cache.tsv"
  # Rebuild cache only if a source file is newer or the cache is missing.
  if [[ ! -f $cache_file ]] || [[ -n "$(command fd -t f . "$dir" -N --changed-within 1d)" ]]; then
    lazy_build_cache "$dir" "$cache_file"
  fi
  # Create stubs from the cache file.
  while IFS=$'\t' read -r fn_name src_file; do
    [[ -n $fn_name && -n $src_file ]] && lazy_fn "$fn_name" "$src_file"
  done <"$cache_file"
}
