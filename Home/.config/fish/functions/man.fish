function man
    if not set -q argv[2] &&
            status list-files "man/man1/$(__fish_canonicalize_builtin $argv).1" &>/dev/null
        __fish_print_help $argv[1]
        return
    end
    set -l manpath
    if not __fish_is_standalone
        and set -l fish_manpath (path filter -d $__fish_data_dir/man)
        set manpath $fish_manpath (
            if set -q MANPATH
                string join -- \n $MANPATH
            else if set -l p (command man -p 2>/dev/null)
                string replace -r '[^/]+$' '' $p
            else
                echo ''
            end
        )
        if test (count $argv) -eq 1
            set argv (__fish_canonicalize_builtin $argv)
        end
    end
    set -q manpath[1]
    and set -lx MANPATH $manpath
    if command -q batman
        command batman $argv
    else
      command man $argv
    end
end
