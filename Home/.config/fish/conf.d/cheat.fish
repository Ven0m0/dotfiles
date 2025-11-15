status -i >/dev/null 2>&1 || return
function cheat
    curl cheat.sh/$argv
end
complete -c cheat -xa '(curl -s cheat.sh/:list)'
