function _evalcache_async -d "Disk-only cache for async contexts"
  set -q argv[1]; or return
  set -q FISH_EVALCACHE_DIR; or set -gx FISH_EVALCACHE_DIR "$HOME/.cache/fish-evalcache"
  set -l hash
  if command -sq md5sum
    set hash (string join \n $argv | md5sum | string split -f1 ' ')
  else if command -sq md5
    set hash (string join \n $argv | md5)
  else
    set hash (string join _ $argv | string replace -ra '[^a-zA-Z0-9_-]' _)
  end
  set -l exec_path (command -v $argv[1] 2>/dev/null)
  test -n "$exec_path"; or return 127
  set -l mtime (stat -c %Y "$exec_path" 2>/dev/null; or stat -f %m "$exec_path" 2>/dev/null; or echo 0)
  set -l cache_file "$FISH_EVALCACHE_DIR/$hash.fish"
  if test -f "$cache_file"
    set -l file_mtime (stat -c %Y "$cache_file" 2>/dev/null; or stat -f %m "$cache_file" 2>/dev/null; or echo 0)
    test $mtime -le $file_mtime; and cat "$cache_file"; and return
  end
  mkdir -p "$FISH_EVALCACHE_DIR"
  command $argv > "$cache_file" 2>&1; and cat "$cache_file"
end
