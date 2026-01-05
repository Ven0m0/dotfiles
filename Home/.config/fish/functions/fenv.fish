function fenv -d ""
    set -l LC_ALL=C; set -l lines; set -l max 0
    for v in (printenv)
        set lines $lines $v
        set n (string split -m1 = $v)[1]
        set l (string length -- $n)
        test $l -gt $max && set max $l
    end        
    for v in $lines
        set p (string split -m1 = $v)
        printf "%-*s %s\n" $max $p[1] $p[2]
    end | fzf --delimiter=' ' --nth=1 --layout=reverse-list --no-mouse --no-multi \
            --cycle --inline-info --no-scrollbar +s --height=100% --tiebreak=begin,end -e
end
