status -i >/dev/null 2>&1 || return

# ─── Tool Initialization ─────────────
command -qs pay-respects >/dev/null 2>&1 && _evalcache pay-respects fish --alias >/dev/null 2>&1
set -gx MANPAGER "env BATMAN_IS_BEING_MANPAGER=yes bash /usr/bin/batman"
set -gx MANROFFOPT "-c"
set -gx LESSOPEN "|/usr/bin/batpipe %s";
set -gx LESS "$LESS -R";
set -e LESSCLOSE

if command -qs yazi >/dev/null 2>&1
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end

command -qs vivid && set -gx LS_COLORS "$(vivid generate dracula)"

# x-cmd (command-line toolkit)
# https://github.com/x-cmd/x-cmd
test -r "$HOME/.x-cmd.root/X.fish" && source "$HOME/.x-cmd.root/X.fish"

if command -qs mpatch
    alias ptch='mpatch'
else
    alias ptch='patch -Np1 <'
end

if test -d ~/.basher >/dev/null 2>&1
    set basher ~/.basher/bin
    set -gx PATH $basher $PATH
    _evalcache basher init - fish
end

alias which="command -v"
alias yay='paru'
alias pip="python3 -m pip"
abbr -a py python3
alias npm bun
alias npx bunx
alias bun-ls "bun pm ls -g --depth=0"

if test -r ~/.venv/bin/activate.fish
    source "$HOME/.venv/bin/activate.fish"
end
