function touchx -d "Touch file (create parents) + optionally open in editor"
    test (count $argv) -eq 0; and echo "Usage: touchx file [file...] [-e|--edit]" && return 1
    
    set -l edit false
    set -l files
    for arg in $argv
        switch $arg
            case -e --edit
                set edit true
            case '*'
                set -a files $arg
        end
    end
    
    for f in $files
        set -l path (string replace -ra '^~' $HOME $f)
        mkdir -p (dirname $path)
        command touch $path
    end
    
    if $edit; and set -q EDITOR
        $EDITOR $files[1]
    end
end
