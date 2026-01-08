#!/usr/bin/env fish

# ─── Backup File ─────────────────────────────────────────────────────────────
function backup -a filename
    cp $filename $filename.bak
end

# ─── Copy with Directory Handling ────────────────────────────────────────────
function copy
    if test (count $argv) -eq 2; and test -d $argv[1]
        set -l from (string trim -r -c / $argv[1])
        command cp -r $from $argv[2]
    else
        command cp $argv
    end
end

# ─── Fuzzy Environment Variables ─────────────────────────────────────────────
function fenv -d "Fuzzy search environment variables"
    set -l lines
    set -l max 0
    for v in (env)
        set -l n (string split -m1 = $v)[1]
        set -l l (string length $n)
        test $l -gt $max; and set max $l
        set -a lines $v
    end
    for v in $lines
        set -l p (string split -m1 = $v)
        printf "%-*s %s\n" $max $p[1] $p[2]
    end | fzf --delimiter=' ' --nth=1 --layout=reverse-list --no-multi --cycle -e
end

# ─── Fuzzy Port Viewer ───────────────────────────────────────────────────────
function fport -d "Show listening TCP connections"
    ss --listening --tcp --numeric | fzf
end

# ─── Fish Title ──────────────────────────────────────────────────────────────
function fish_title
    echo $argv[1] (prompt_pwd)
end

# ─── History with Timestamp ──────────────────────────────────────────────────
function history
    builtin history --show-time='%F %T ' $argv
end

# ─── IP Wrapper ──────────────────────────────────────────────────────────────
function ip
    command ip --color=auto $argv
end

# ─── suedit ──────────────────────────────────────────────────────────────────
function suedit -d "Edit file as root"
    set -q EDITOR; or set -l EDITOR nano
    command -q sudo-rs && sudo-rs $EDITOR $argv || command -q doas && doas $EDITOR $argv || sudo $EDITOR $argv
end

# ─── wget XDG wrapper ────────────────────────────────────────────────────────
function wget
    command wget --hsts-file="$XDG_DATA_HOME/wget-hsts" $argv
end

# ─── GitHub Man Page Viewer ──────────────────────────────────────────────────
function batmanurl -w man -d "View GitHub manpage with bat"
    test (count $argv) -eq 0; and echo "Usage: batmanurl <github-url>" && return 1
    set -l raw_url (string replace -r 'github\.com/([^/]+)/([^/]+)/blob/([^/]+)/(.*)' \
        'raw.githubusercontent.com/$1/$2/$3/$4' $argv[1])
    curl -s $raw_url | bat -l man
end

# ─── FZF Zoxide Binding ──────────────────────────────────────────────────────
function _fzf_search_zoxide -d "Zoxide interactive search"
    set -l zoxide_cmd (command -v zoxide || echo zoxide)
    set -l token (commandline --current-token)
    set -l selection ($zoxide_cmd query --interactive $token 2>/dev/null)
    test $status -eq 0; and commandline --current-token --replace (string escape $selection | string join ' ')
    commandline -f repaint
end

function fzf_zoxide_configure_binding -d "Set zoxide fzf keybinding"
    status is-interactive; or return
    set -l key \cz
    set -q argv[1]; and set key $argv[1]
    for mode in default insert
        bind --mode $mode $key _fzf_search_zoxide
    end
end
