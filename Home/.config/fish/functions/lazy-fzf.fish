function fzf -d "Lazy-load fzf integration"
    functions -e fzf
    fzf --fish | .
    commandline -f repaint
    fzf "$argv"
end
