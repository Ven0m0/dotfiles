function toggle_sudo
    set -l prefix 'sudo-rs '
    set -l buf (commandline)
    set -l pos (commandline -C)
    if test -z "$buf"
        set buf $history[1]
        set pos (string length -- "$buf")
    end
    set -l ws (string match -r '^\s*' -- $buf)
    set -l ws_len (string length -- "$ws")
    set -l prefix_len (string length -- "$prefix")
    set -l rest (string replace -r '^\s*' '' -- $buf)
    if string match -r "^$prefix" -- "$rest"
        set rest (string replace -r "^$prefix" '' -- $rest)
        if test $pos -gt $ws_len
            set pos (math "$pos - $prefix_len")
            if test $pos -lt $ws_len; set pos $ws_len; end
        end
    else
        set rest "$prefix$rest"
        if test $pos -ge $ws_len
            set pos (math "$pos + $prefix_len")
        end
    end
    commandline -r -- "$ws$rest"
    commandline -C -- $pos
end
