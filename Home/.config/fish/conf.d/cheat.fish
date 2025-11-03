function cheat.sh
    curl cheat.sh/$argv
end
complete -c cheat.sh -xa '(curl -s cheat.sh/:list)'
