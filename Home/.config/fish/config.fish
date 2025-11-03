status -i >/dev/null 2>&1 || return

source /usr/share/cachyos-fish-config/cachyos-config.fish

set -g fish_greeting

if type -q _evalcache
	function init_tool
		if type -qf $argv[1]
      		_evalcache "$argv[2] 2>/dev/null"
  		end
	end
else
	function init_tool
		if type -qf $argv[1]
			eval "$argv[2] 2>/dev/null" 
		end
	end
end


#set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

set -U __done_notification_urgency_level low
set -x GPG_TTY (tty)
set -gx COLORTERM truecolor

fish_add_path $HOME/.local/bin
fish_add_path $HOME/bin
fish_add_path $HOME/bun/bin

#set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_DEFAULT_COMMAND 'fdf -tf -H --size +1k'
set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

init_tool fzf "fzf --fish"
init_tool starship "starship init fish"
init_tool zoxide "zoxide init --cmd cd fish"
init_tool mise "mise activate fish"
init_tool navi "navi widget fish"
init_tool zellij "zellij setup --generate-auto-start fish | string collect"
init_tool intelli-shell "intelli-shell init fish"
init_tool cod "cod init $fish_pid fish"

# ─── Path Deduplication ─────────────────────────────────────────────────────────
set PATH (printf "%s" "$PATH" | awk -O -v RS=':' '!a[$1]++ { if (NR > 1) printf RS; printf $1 }')
