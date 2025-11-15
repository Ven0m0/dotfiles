# Only for interactive shells
status -i >/dev/null 2>&1 || return

# ─── Fish Setup ─────────────────────────
set -U fish_prompt_pwd_dir_length 2
set -g __fish_git_prompt_show_informative_status 0
set -U __fish_git_prompt_showupstream none
set -U fish_term24bit 1
set -U fish_autosuggestion_enabled 1

function fish_title
  echo $argv[1] (prompt_pwd)
end

# ─── Keybinds ─────────────────────────
functions -q toggle_sudo; and bind \cs 'toggle_sudo'

# ─── Environment ──────────────────────
set -gx EDITOR micro
set -gx VISUAL $EDITOR
set -gx VIEWER $EDITOR
set -gx GIT_EDITOR $EDITOR
set -gx SYSTEMD_EDITOR $EDITOR
set -gx PAGER bat
set -gx LESSHISTFILE '-'
set -gx BATPIPE color

# ─── Fuzzy Finders ───────────────────
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx SKIM_DEFAULT_COMMAND 'fd -tf -F --exclude .git; or rg --files; or find -O3 .'
set -gx SKIM_DEFAULT_OPTIONS $FZF_DEFAULT_OPTS
set -Ux FZF_LEGACY_KEYBINDINGS 0
_evalcache fzf --fish 2>/dev/null

# ─── Fetch Command ────────────────────
switch "$stealth"
	case 1
		# disable mommy plugin
		if functions -q __call_mommy; functions -e __call_mommy; end
			function __disable_mommy --on-event fish_postexec
		if functions -q __call_mommy; functions -e __call_mommy; end
    		functions -e __disable_mommy
		end
	case 0

	case '*'

end

function fish_greeting
	if type -q hyfetch
		LC_ALL C hyfetch 2>/dev/null
    else if type -q fastfetch
		fastfetch
	end
end

# Ghostty integration
if test "$TERM" = "xterm-ghostty" -a -e "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
	source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
end

# Async prompt
set -U async_prompt_functions fish_prompt # fish_right_prompt
set -U async_prompt_enable 1

# ─── Abbreviations & Aliases ─────────
abbr -a mv mv -iv
abbr -a rm rm -iv
abbr -a cp cp -iv
abbr -a sort sort -h
abbr -a df df -h
abbr -a free free -h
abbr -a ip ip --color=auto
abbr -a du du -hcsx
abbr -a c clear
abbr -a e $EDITOR

# https://www.reddit.com/r/fishshell/comments/1g3nh1u/any_way_to_create_functions_with_dynamic_names/
function qcd
	echo cd (string repeat -n (string length $argv) ../)
end
abbr -a qcd --position command --regex 'q+' --function qcd

alias cat='command bat -pp'

alias sudo='sudo '; alias doas='doas '; alias sudo-rs='sudo-rs '
alias mkdir='mkdir -pv '; alias ed='$EDITOR '
alias ping='ping -c 4'
alias cls='clear'

# ─── Functions ───────────────────────
function mkdircd
	command mkdir -p -- $argv; and command cd $argv[-1]
end
function ip
	command ip --color=auto -- $argv
end
