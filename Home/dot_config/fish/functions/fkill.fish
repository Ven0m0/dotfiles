function fkill -d "Fuzzy find and kill process"
    set -l pid (ps axww -o pid,user,%cpu,%mem,start,time,command | fzf | string trim | cut -d' ' -f1)
    test -n "$pid"; and sudo-rs kill -9 $pid
end
