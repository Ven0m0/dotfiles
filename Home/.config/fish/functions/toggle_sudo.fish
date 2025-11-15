function toggle_sudo --description 'Toggles sudo-rs (fallback sudo) on the command line'
    set -l buf (commandline)
    set -l pos (commandline -C)
    if test -z "$buf"
        set buf $history[1]; set pos (string length -- "$buf")
    end
    set -l ws (string match -r '^\s*' -- "$buf")
    set -l rest (string replace -r '^\s*' '' -- "$buf")
    set -l prefix (if type -q sudo-rs; echo 'sudo-rs '; else; echo 'sudo '; end)
    set -l plen (string length -- "$prefix")
    if string match -q -r "^$prefix" -- "$rest"
        set rest (string replace -r "^$prefix" '' -- "$rest")
        set pos (math "$pos - $plen"); or set pos (string length -- "$ws")
    else
        set rest "$prefix$rest"
        set pos (math "$pos + $plen")
    end
    commandline -r -- "$ws$rest"
    commandline -C -- $pos
end
