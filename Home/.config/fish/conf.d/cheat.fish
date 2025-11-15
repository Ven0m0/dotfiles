status -i >/dev/null 2>&1 || return
function cheat.sh
    curl cheat.sh/$argv
end
complete -c cheat.sh -xa '(curl -s cheat.sh/:list)'
