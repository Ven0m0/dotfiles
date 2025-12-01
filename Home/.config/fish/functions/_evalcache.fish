function _evalcache -d "Cache command output with exec mtime tracking"
    set -q argv[1]; or return
    switch "$argv[1]"
        case -l --list
            set -l i 1
            echo -e "No.\tCommand\tMtime"
            for hash in $__evalcache_entries
                set -l key __evalcache_$hash
                set -q $key; or continue
                set -l data $$key
                echo -e "$i\t$data[1]\t$data[2]"
                set i (math $i + 1)
            end
            return
        case -e --erase
            set -q argv[2]; or return 1
            set -q __evalcache_entries[$argv[2]]; or return 1
            set -l hash $__evalcache_entries[$argv[2]]
            set -e __evalcache_{$hash}
            set -e __evalcache_entries[$argv[2]]
            rm -f "$FISH_EVALCACHE_DIR/$hash.fish" 2>/dev/null
            return
        case -c --clear
            for hash in $__evalcache_entries
                set -e __evalcache_{$hash}
            end
            set -e __evalcache_entries
            set -q FISH_EVALCACHE_DIR; and rm -rf "$FISH_EVALCACHE_DIR"
            return
    end
    set -q FISH_EVALCACHE_DIR; or set -gx FISH_EVALCACHE_DIR "$HOME/.cache/fish-evalcache"
    set -q __EVALCACHE_RUNNING; and command $argv; and return
    set -l hash
    if command -sq md5sum
        set hash (string join \n $argv | md5sum | string split -f1 ' ')
    else if command -sq md5
        set hash (string join \n $argv | md5)
    else
        set hash (string join _ $argv | string replace -ra '[^a-zA-Z0-9_-]' _)
    end
    set -l key __evalcache_$hash
    set -l exec_path (command -v $argv[1] 2>/dev/null)
    test -n "$exec_path"; or begin
        echo "evalcache: command '$argv[1]' not found" >&2
        return 127
    end
    set -l mtime (stat -c %Y "$exec_path" 2>/dev/null; or stat -f %m "$exec_path" 2>/dev/null; or echo 0)
    if set -q $key
        set -l cached $$key
        test $mtime -le $cached[2]; and echo -e $cached[3]; and return
    end
    set -l cache_file "$FISH_EVALCACHE_DIR/$hash.fish"
    if test -f "$cache_file"
        set -l file_mtime (stat -c %Y "$cache_file" 2>/dev/null; or stat -f %m "$cache_file" 2>/dev/null; or echo 0)
        if test $mtime -le $file_mtime
            set -l output (cat "$cache_file")
            set -U $key "$argv[1]" $mtime "$output"
            set -Ua __evalcache_entries $hash
            echo -e "$output"
            return
        end
    end
    mkdir -p "$FISH_EVALCACHE_DIR"
    set -gx __EVALCACHE_RUNNING 1
    set -l output (command $argv 2>&1)
    set -l status_code $status
    set -e __EVALCACHE_RUNNING
    test $status_code -eq 0 -a -n "$output"; or begin
        echo "evalcache: command failed or empty output (status $status_code)" >&2
        return $status_code
    end
    echo -e "$output" >"$cache_file"
    set -U $key "$argv[1]" $mtime "$output"
    set -Ua __evalcache_entries $hash
    echo -e "$output"
end
