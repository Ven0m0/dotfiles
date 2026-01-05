function fenv -d ""
    printenv | sort | column -t -s '=' | fzf --layout=reverse-list --no-mouse --no-multi --cycle --inline-info --no-scrollbar +s --height=100% --tiebreak=begin,end -e
end
