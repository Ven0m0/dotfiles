function fenv -d ""
    printenv | sort | awk -F= '{printf "%-30s %s\n", $1, $2}' | fzf --delimiter=' ' --nth=1 --layout=reverse-list --no-mouse --no-multi --cycle --inline-info --no-scrollbar +s --height=100% --tiebreak=begin,end -e
end
