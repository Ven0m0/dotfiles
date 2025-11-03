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
    if type -q fastfetch
      set -g fetch 'fastfetch --detect-version false --users-myself-only --localip-compact --ds-force-drm --thread'
    else
      set -e fetch
  end
  # disable mommy plugin
  if functions -q __call_mommy; functions -e __call_mommy; end
    function __disable_mommy --on-event fish_postexec
  if functions -q __call_mommy; functions -e __call_mommy; end
    functions -e __disable_mommy
  end
  case '*'
    if type -q hyfetch
      set -g fetch 'hyfetch -b fastfetch -m rgb -p transgender'
    else if type -q fastfetch
      set -g fetch 'fastfetch --detect-version false --users-myself-only --localip-compact --ds-force-drm --thread'
    else
      set -e fetch
    end
end

function fish_greeting
  if set -q fetch
    LC_ALL=C LANG=C eval $fetch 2>/dev/null
  end
end

# ─── Tool Initialization ─────────────
for tool in batman batpipe pay-respects starship
  if type -q $tool >/dev/null 2>&1
    switch $tool
    	case batman; _evalcache batman --export-env >/dev/null
    	case batpipe; _evalcache batpipe >/dev/null
    	case pay-respects; _evalcache pay-respects fish --alias >/dev/null
    	case starship; _evalcache starship init fish && enable_transience
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

if test -d ~/.basher
	set basher ~/.basher/bin
	set -gx PATH $basher $PATH
	_evalcache basher init - fish
end

# Ghostty integration
if test "$TERM" = "xterm-ghostty" -a -e "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
	source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
end

# Async prompt
set -Ux async_prompt_functions fish_prompt # fish_right_prompt
set -Ux async_prompt_enable 1

# ─── Abbreviations & Aliases ─────────
abbr -a mv mv -iv
abbr -a rm rm -iv
abbr -a cp cp -iv
abbr -a sort sort -h
abbr -a mkdir mkdir -pv
abbr -a df df -h
abbr -a free free -h
abbr -a ip ip --color=auto
abbr -a du du -hcsx
abbr -a c clear
abbr -a py python3

# https://www.reddit.com/r/fishshell/comments/1g3nh1u/any_way_to_create_functions_with_dynamic_names/
function qcd
	echo cd (string repeat -n (string length $argv) ../)
end
abbr -a qcd --position command --regex 'q+' --function qcd

alias cat='\bat -pp'
alias ptch='patch -p1 <'
alias updatesh='curl -fsSL https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Updates.sh | bash'
alias clearnsh='curl -fsSL https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Clean.sh | bash'
alias sudo='sudo '; alias doas='doas '; alias sudo-rs='sudo-rs '
alias mkdir='mkdir -p '; alias ed='$EDITOR '
alias ping='ping -c 4'
alias clear='command clear; and fish_greeting 2>/dev/null'
alias cls='command clear; and fish_greeting 2>/dev/null'

# ─── Functions ───────────────────────
function mkdircd
	command mkdir -p -- $argv; and command cd $argv[-1]
end
function ip
	command ip --color=auto -- $argv
end
