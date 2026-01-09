function fssh -d "Fuzzy find ssh host"
    rg --no-filename --ignore-case '^host [^*]' ~/.ssh/config | cut -d' ' -f2 | fzf | read -l result
    and ssh "$result"
end
