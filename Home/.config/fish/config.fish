status -i >/dev/null 2>&1 || return

test -r /usr/share/cachyos-fish-config/cachyos-config.fish >/dev/null 2>&1 && source /usr/share/cachyos-fish-config/cachyos-config.fish >/dev/null 2>&1

function init_tool
	type -qf $argv[1] || return
	type -q _evalcache && _evalcache "$argv[2]" >/dev/null 2>&1 || eval "$argv[2]" >/dev/null 2>&1
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

# Deduplicate PATH entries while preserving order
set -l unique_path
for path_entry in $PATH
    if not contains $path_entry $unique_path
        set -a unique_path $path_entry
    end
end
set -gx PATH $unique_path
