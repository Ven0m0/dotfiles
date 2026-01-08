#!/usr/bin/env fish

# ─── Unified Git Clone + CD ──────────────────────────────────────────────────
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

# ─── Unified mkdir + cd ──────────────────────────────────────────────────────
function mkcd -d "Create dir(s) and cd to first"
    test (count $argv) -eq 0; and echo "Usage: mkcd dir [...]" && return 1
    mkdir -p $argv[1]; and cd $argv[1]
end

# ─── Unified touch + mkdir parent ────────────────────────────────────────────
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

# ─── Extract Archives ────────────────────────────────────────────────────────
function x -a file -d "Extract archive by extension"
    not test -f "$file"; and echo "Usage: x file" && return 1
    switch "$file"
        case '*.tar.bz2' '*.tbz2'
            tar xjf $file
        case '*.tar.gz' '*.tgz'
            tar xzf $file
        case '*.tar'
            tar xf $file
        case '*.bz2'
            bunzip2 $file
        case '*.gz'
            gunzip $file
        case '*.zip'
            unzip $file
        case '*.rar'
            unrar x $file
        case '*.7z'
            7z x $file
        case '*.Z'
            uncompress $file
        case '*'
            echo "'$file' cannot be extracted"
            return 1
    end
end

# ─── Privilege Escalation Wrapper ───────────────────────────────────────────
function fuck -d "Re-run last command with sudo/doas"
    set -l last_cmd (history --max=1)
    set -l runner (command -q sudo-rs && echo sudo-rs || command -q doas && echo doas || echo sudo)
    eval "$runner $last_cmd"
end

# ─── Sudo Toggle on Commandline ─────────────────────────────────────────────
function toggle_sudo -d "Toggle sudo-rs/sudo prefix"
    set -l buf (commandline)
    set -l pos (commandline -C)
    test -z "$buf"; and set buf $history[1] && set pos (string length $buf)
    set -l ws (string match -r '^\s*' -- $buf)
    set -l rest (string replace -r '^\s*' '' -- $buf)
    set -l prefix (command -q sudo-rs && echo 'sudo-rs ' || echo 'sudo ')
    set -l plen (string length $prefix)
    if string match -qr "^$prefix" -- $rest
        set rest (string replace -r "^$prefix" '' -- $rest)
        set pos (math "$pos - $plen"); or set pos (string length $ws)
    else
        set rest "$prefix$rest"
        set pos (math "$pos + $plen")
    end
    commandline -r "$ws$rest"
    commandline -C $pos
end

# ─── Fuzzy Process Kill ──────────────────────────────────────────────────────
function fkill -d "Fuzzy find and kill process"
    set -l pid (ps axww -o pid,user,%cpu,%mem,start,time,command | fzf | string trim | cut -d' ' -f1)
    test -n "$pid"; and sudo-rs kill -9 $pid
end

# ─── Fuzzy SSH Host ──────────────────────────────────────────────────────────
function fssh -d "Fuzzy find ssh host"
    rg --no-filename --ignore-case '^host [^*]' ~/.ssh/config | cut -d' ' -f2 | fzf | read -l result
    and ssh "$result"
end

# ─── Git Optimize ────────────────────────────────────────────────────────────
function git-opt -d "Optimize git repo"
    git reflog expire --expire=now --all
    and git gc --prune=now --aggressive
    and git repack -a -d --depth=250 --window=250 --write-bitmap-index
    and git clean -fdX
end

# ─── Man with batman ─────────────────────────────────────────────────────────
function man
    if not set -q argv[2]; and status list-files "man/man1/$(__fish_canonicalize_builtin $argv).1" &>/dev/null
        __fish_print_help $argv[1]
        return
    end
    command -q batman && batman $argv || command man $argv
end

# ─── Shell Switcher ──────────────────────────────────────────────────────────
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

# ─── Yazi CD Wrapper ─────────────────────────────────────────────────────────
function y -d "yazi with auto-cd"
    command -q yazi; or return
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file=$tmp
    if read -z cwd <$tmp; and test -n "$cwd" -a "$cwd" != "$PWD"
        builtin cd $cwd
    end
    rm -f $tmp
end

# ─── Cheat.sh Query ──────────────────────────────────────────────────────────
function cheat -d "Query cheat.sh"
    curl -s cheat.sh/$argv
end
complete -c cheat -xa '(curl -s cheat.sh/:list 2>/dev/null)'

# ─── Quick Up-Dir Abbreviation ───────────────────────────────────────────────
function qcd
    echo cd (string repeat -n (string length $argv) ../)
end
abbr -a qcd --position command --regex 'q+' --function qcd

# ─── RGA + FZF ───────────────────────────────────────────────────────────────
function rga-fzf -d "Fuzzy find in files with rga"
    set -l RG_PREFIX 'rga --files-with-matches'
    test (count $argv) -gt 1; and set RG_PREFIX "$RG_PREFIX $argv[1..-2]"
    set -l file (FZF_DEFAULT_COMMAND="$RG_PREFIX '$argv[-1]'" \
        fzf --sort --preview='test -n {} && rga --pretty --context 5 {q} {}' \
        --phony -q "$argv[-1]" --bind "change:reload:$RG_PREFIX {q}" --preview-window='50%:wrap')
    test -n "$file"; and echo "Opening $file" && $EDITOR "$file"
end

# ─── Make Script Executable and Run ─────────────────────────────────────────
function runch -a script -d "chmod +x and run script"
    test -z "$script"; and echo "Usage: runch script" >&2 && return 2
    chmod u+x $script 2>/dev/null; or begin
        echo "Cannot make executable: $script" >&2
        return 1
    end
    string match -q '*/*' -- $script && exec $script || exec ./$script
end
