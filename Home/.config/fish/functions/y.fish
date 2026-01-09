function y -d "yazi with auto-cd"
    command -q yazi; or return
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file=$tmp
    if read -z cwd <$tmp; and test -n "$cwd" -a "$cwd" != "$PWD"
        builtin cd $cwd
    end
    rm -f $tmp
end
