function man
    if not set -q argv[2]; and status list-files "man/man1/$(__fish_canonicalize_builtin $argv).1" &>/dev/null
        __fish_print_help $argv[1]
        return
    end
    command -q batman && batman $argv || command man $argv
end
