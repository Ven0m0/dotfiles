function fuck -d "Execute last command as sudo"
    eval "sudo (history --max=1)"
end
