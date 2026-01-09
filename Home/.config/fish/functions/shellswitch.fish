function shellswitch -d "Interactive shell switcher"
    set -l shells (rg --no-filename --invert-match '^(#|$)' /etc/shells)
    test (count $shells) -eq 0; and echo "No shells found" && return 1
    echo "Shells:"
    for i in (seq (count $shells))
        echo "$i) "(basename $shells[$i])
    end
    read -P "Enter number or name: " choice
    if string match -qr '^\d+$' -- $choice; and test $choice -ge 1 -a $choice -le (count $shells)
        exec $shells[$choice]
    else
        for s in $shells
            test (basename $s) = $choice; and exec $s
        end
        echo "No match for '$choice'"
        return 1
    end
end
