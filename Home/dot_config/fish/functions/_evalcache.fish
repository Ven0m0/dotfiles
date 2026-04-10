#!/usr/bin/env fish

function _evalcache -d "Cache command output with mtime tracking"
    set -q argv[1]; or return
    switch "$argv[1]"
        case -l --list
            echo -e "No.\tCommand\tMtime"
            for i in (seq (count $__evalcache_entries))
                set -q __evalcache_entries[$i]; or continue
                set -l hash $__evalcache_entries[$i]
                set -l key __evalcache_$hash
                set -q $key; or continue
                echo -e "$i\t$$key[1]\t$$key[2]"
            end
            return
        case -e --erase
            set -q argv[2]; and set -q __evalcache_entries[$argv[2]]; or return 1
            set -l hash $__evalcache_entries[$argv[2]]
            set -e __evalcache_{$hash} __evalcache_entries[$argv[2]]
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
    
    set -q FISH_EVALCACHE_DIR; or set -gx FISH_EVALCACHE_DIR "$XDG_CACHE_HOME/fish-evalcache"
    set -q __EVALCACHE_RUNNING; and command $argv && return
    
    set -l hash (string join \n $argv | command -q md5sum && md5sum | cut -d' ' -f1 || md5)
    set -l key __evalcache_$hash
    set -l exec_path (command -v $argv[1] 2>/dev/null)
    test -n "$exec_path"; or begin
        echo "evalcache: '$argv[1]' not found" >&2
        return 127
    end
    
    set -l mtime (stat -c %Y $exec_path 2>/dev/null || stat -f %m $exec_path 2>/dev/null || echo 0)
    if set -q $key
        set -l cached $$key
        test $mtime -le $cached[2]; and echo -e $cached[3] && return
    end
    
    set -l cache_file "$FISH_EVALCACHE_DIR/$hash.fish"
    if test -f $cache_file
        set -l file_mtime (stat -c %Y $cache_file 2>/dev/null || stat -f %m $cache_file 2>/dev/null || echo 0)
        if test $mtime -le $file_mtime
            set -l output (cat $cache_file)
            set -U $key $argv[1] $mtime $output
            set -Ua __evalcache_entries $hash
            echo -e $output
            return
        end
    end
    
    mkdir -p $FISH_EVALCACHE_DIR
    set -gx __EVALCACHE_RUNNING 1
    set -l output (command $argv 2>&1)
    set -l code $status
    set -e __EVALCACHE_RUNNING
    
    test $code -eq 0 -a -n "$output"; or begin
        echo "evalcache: command failed (status $code)" >&2
        return $code
    end
    
    echo -e $output >$cache_file
    set -U $key $argv[1] $mtime $output
    set -Ua __evalcache_entries $hash
    echo -e $output
end

function _evalcache_async -d "Disk-only cache for async contexts"
    set -q argv[1]; or return
    set -q FISH_EVALCACHE_DIR; or set -gx FISH_EVALCACHE_DIR "$XDG_CACHE_HOME/fish-evalcache"
    set -l hash (string join \n $argv | command -q md5sum && md5sum | cut -d' ' -f1 || md5)
    set -l exec_path (command -v $argv[1] 2>/dev/null)
    test -n "$exec_path"; or return 127
    set -l mtime (stat -c %Y $exec_path 2>/dev/null || stat -f %m $exec_path 2>/dev/null || echo 0)
    set -l cache_file "$FISH_EVALCACHE_DIR/$hash.fish"
    if test -f $cache_file
        set -l file_mtime (stat -c %Y $cache_file 2>/dev/null || stat -f %m $cache_file 2>/dev/null || echo 0)
        test $mtime -le $file_mtime; and cat $cache_file && return
    end
    mkdir -p $FISH_EVALCACHE_DIR
    command $argv >$cache_file 2>&1; and cat $cache_file
end
