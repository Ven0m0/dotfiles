function gcl -d "Clone git repo and cd (gh/gix fallback)"
    test (count $argv) -eq 0; and echo "Usage: gcl owner/repo | url [dir]" && return 1
    
    set -l url $argv[1]
    set -l dir ""
    set -l is_bare false
    
    if test "$argv[1]" = --bare
        set is_bare true
        set url $argv[2]
    end
    
    # Extract owner/repo from URL or shorthand
    if string match -qr '^https?://' -- $url
        set -l parts (string match -r 'github\.com/([^/]+)/([^/]+?)(\.git)?$' -- $url)
        set url "$parts[2]/$parts[3]"
    end
    
    # Use provided dir or derive from repo name
    if test (count $argv) -ge 2; and test "$argv[2]" != --bare
        set dir $argv[2]
    else
        set dir (string split -f2 / $url)
    end
    
    test -d $dir; and cd $dir && return 0
    
    # Try gh > gix > git
    set -l clone_ok false
    if command -q gh
        if test $is_bare = true
            gh repo clone $url -- --bare
        else
            gh repo clone $url $dir
        end
        set clone_ok (test $status -eq 0)
    end
    
    if not $clone_ok
        set -l git_cmd (command -q gix && echo gix || echo git)
        if test $is_bare = true
            $git_cmd clone --bare "https://github.com/$url.git" $dir
        else
            $git_cmd clone "https://github.com/$url.git" $dir
        end
        set clone_ok (test $status -eq 0)
    end
    
    $clone_ok; and cd $dir
end
