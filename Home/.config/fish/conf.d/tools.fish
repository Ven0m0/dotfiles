status -i >/dev/null 2>&1 || return

# ─── Tool Initialization ─────────────

for tool in batman batpipe pay-respects starship
  if type -q $tool >/dev/null 2>&1
    switch $tool
    	case batman; _evalcache batman --export-env >/dev/null 2>&1
    	case batpipe; _evalcache batpipe >/dev/null 2>&1
    	case pay-respects; _evalcache pay-respects fish --alias >/dev/null 2>&1
    	case starship; _evalcache starship init fish >/dev/null 2>&1 && enable_transience >/dev/null 2>&1
	end
  end
end

if type -q yazi >/dev/null 2>&1
	function y
		set tmp (mktemp -t "yazi-cwd.XXXXXX")
		yazi $argv --cwd-file="$tmp"
		if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
			builtin cd -- "$cwd"
		end
		rm -f -- "$tmp"
	end
end

type -q ast-grep && ast-grep completions fish | source

if type -q mpatch
	alias ptch='mpatch'
else
	alias ptch='patch -Np1 <'
end

if test -d ~/.basher >/dev/null 2>&1
	set basher ~/.basher/bin
	set -gx PATH $basher $PATH
	_evalcache basher init - fish
end

abbr -a pip "uv pip"
abbr -a py python3

abbr -a npm bun
abbr -a npx bunx
abbr -a pnpm bun

if test -r ~/.venv/bin/activate.fish
	source "$HOME/.venv/bin/activate.fish"
end
if type -q vs
	vx shell completions fish | source
	vx shell init fish | source
end
# uv python update-shell
# uv venv
