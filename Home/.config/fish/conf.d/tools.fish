status -i >/dev/null 2>&1 || return

# ─── Tool Initialization ─────────────
command -qs pay-respects >/dev/null 2>&1 && _evalcache pay-respects fish --alias >/dev/null 2>&1

# x-cmd (command-line toolkit)
# https://github.com/x-cmd/x-cmd
test -r "$HOME/.x-cmd.root/X.fish" && source "$HOME/.x-cmd.root/X.fish"

if command -qs mpatch
    alias ptch='mpatch'
else
    alias ptch='patch -Np1 <'
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
