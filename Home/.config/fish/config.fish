source /usr/share/cachyos-fish-config/cachyos-config.fish
set -e LC_ALL

function init_tool
	if type -q $argv[1]
      eval "$argv[2]"
  end
end

# Only for interactive shells
if status -i >/dev/null 2>&1

	set -g fish_greeting

	#set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

	set -U __done_notification_urgency_level low

	#set -gx COLORTERM truecolor

	#fish_add_path $HOME/.local/bin
	#fish_add_path $HOME/.cargo/bin

	set -x GPG_TTY (tty)
	init_tool fzf "fzf --fish | source"
	init_tool starship init fish | source
	init_tool zoxide "zoxide init --cmd cd fish | source"
	init_tool mise "mise activate fish | source"
	init_tool navi "navi widget fish | source"

	#set -gx ZSTD_CLEVEL 19
	set -gx ZSTD_NBTHREADS $(nproc --ignore=1)"
	# set -gx ZSTD_NBTHREADS (math (nproc)/2)
	#set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
	#set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

	eval (zellij setup --generate-auto-start fish | string collect)
	intelli-shell init fish | source

end

# ─── Path Deduplication ─────────────────────────────────────────────────────────
set PATH (printf "%s" "$PATH" | awk -O -v RS=':' '!a[$1]++ { if (NR > 1) printf RS; printf $1 }')
# Deduplicate PATH (preserve order) to prevent PATH bloat across reloads
#set -l seen
#set -l newpath
#for dir in $PATH
  #if not contains -- $dir $seen 2>/dev/null
    #set seen $seen $dir
    #set newpath $newpath $dir
  #end
#end
#set -gx PATH $newpath

if type -qf zoxide
	_evalcache zoxide init fish 2>/dev/null
end
