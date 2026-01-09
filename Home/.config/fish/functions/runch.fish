function runch -a script -d "chmod +x and run script"
    test -z "$script"; and echo "Usage: runch script" >&2 && return 2
    chmod u+x $script 2>/dev/null; or begin
        echo "Cannot make executable: $script" >&2
        return 1
    end
    string match -q '*/*' -- $script && exec $script || exec ./$script
end
