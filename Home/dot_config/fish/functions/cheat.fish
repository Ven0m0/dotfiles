function cheat -d "Query cheat.sh"
    curl -s cheat.sh/$argv
end
complete -c cheat -xa '(curl -s cheat.sh/:list 2>/dev/null)'
