status -i || return

test -r /usr/share/cachyos-fish-config/cachyos-config.fish && source /usr/share/cachyos-fish-config/cachyos-config.fish 2>/dev/null

function init_tool
	type -qf $argv[1] || return
	type -q _evalcache && _evalcache "$argv[2]" 2>/dev/null || eval "$argv[2]" 2>/dev/null
end

set -U __done_notification_urgency_level low
set -gx GPG_TTY (tty)
set -gx COLORTERM truecolor
set -gx FZF_DEFAULT_COMMAND 'fdf -tf -H --size +1k'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

fish_add_path ~/bun/bin ~/.local/bin /usr/local/bin ~/bin ~/.bin

init_tool fzf "fzf --fish"
init_tool starship "starship init fish"
init_tool zoxide "zoxide init --cmd cd fish"
init_tool mise "mise activate fish"
init_tool navi "navi widget fish"
init_tool zellij "zellij setup --generate-auto-start fish | string collect"
init_tool intelli-shell "intelli-shell init fish"
init_tool cod "cod init $fish_pid fish"

function fish_greeting
	type -q hyfetch && LC_ALL=C hyfetch 2>/dev/null || type -q fastfetch && LC_ALL=C fastfetch 2>/dev/null
end
