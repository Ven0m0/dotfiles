source /usr/share/cachyos-fish-config/cachyos-config.fish

# ─── Fish setup ─────────────────────────────────────────────────────────
set -Ux fish_prompt_pwd_dir_length 2
set -gx __fish_git_prompt_show_informative_status 0
set -Ux __fish_git_prompt_showupstream none
set -Ux fish_term24bit 1
function fish_title
    echo $argv[1] (prompt_pwd)
end

# ─── Keybinds ─────────────────────────────────────────────────────────
#fish_hybrid_key_bindings
functions -q toggle_sudo
	bind \cs 'toggle_sudo'
end
# ─── Environment Tweaks ─────────────────────────────────────────────────────────
set -gx EDITOR micro
set -gx VISUAL $EDITOR
set -gx VIEWER $EDITOR
set -gx GIT_EDITOR $EDITOR
set -gx SYSTEMD_EDITOR $EDITOR
set -gx PAGER bat
# set -gx LESS '-RQsn --no-histdups --mouse --wheel-lines=4'
set -gx LESSHISTFILE '-'
set -gx BATPIPE color

# Fuzzy
#set -gx FZF_DEFAULT_OPTS '--inline-info --layout=reverse-list --height=70% -1 -0'
#set -gx FZF_DEFAULT_COMMAND 'fd -tf -F --exclude .git; or rg --files; or find -O3 .'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx SKIM_DEFAULT_COMMAND 'fd -tf -F --exclude .git; or rg --files; or find -O3 .'
set -gx SKIM_DEFAULT_OPTIONS $FZF_DEFAULT_OPTS
set -Ux FZF_LEGACY_KEYBINDINGS 0
#set -Ux FZF_COMPLETE 3
_evalcache fzf --fish 2>/dev/null
# ────────────────────────────────────────────────────────────
# choose fetch command depending on stealth and available tools
# set -l stealth 1
if test "$stealth" = "1"
  if type -qf fastfetch
    set -g fetch 'fastfetch --detect-version false --users-myself-only --localip-compact --ds-force-drm --thread'
  else
    set -e fetch
  end
else if type -qf hyfetch
  set -g fetch 'hyfetch -b fastfetch -m rgb -p transgender'
else if type -qf fastfetch
  set -g fetch 'fastfetch --detect-version false --users-myself-only --localip-compact --ds-force-drm --thread'
else
  set -e fetch
end
# greeting runs the chosen fetch if present
function fish_greeting
  if set -q fetch
    LC_ALL=C LANG=C eval $fetch 2>/dev/null
  end
end

# If stealth, try to disable mommy (plugin defines __call_mommy --on-event fish_postexec)
if test "$stealth" = "1"
  # remove it now if already defined
  if functions -q __call_mommy
    functions -e __call_mommy
  end
  # one-shot watcher: if mommy appears later, erase it and then remove this watcher
  function __disable_mommy --on-event fish_postexec
    if functions -q __call_mommy
      functions -e __call_mommy
    end
    functions -e __disable_mommy
  end
end

if test -d ~/.basher
    set basher ~/.basher/bin
end
set -gx PATH $basher $PATH
status --is-interactive >/dev/null 2>&1; and _evalcache basher init - fish 2>/dev/null

set -e LC_ALL

# Prompt
if type -qf starship
	_evalcache starship init fish 2>/dev/null
end

if type -qf batman
	_evalcache batman --export-env 2>/dev/null
end
if type -qf batpipe
	_evalcache batpipe 2>/dev/null
end
if type -qf pay-respects
	_evalcache pay-respects fish --alias 2>/dev/null
end
# ─── Ghostty bash integration ─────────────────────────────────────────────────────────
if test "$TERM" = "xterm-ghostty" -a -e "$GHOSTTY_RESOURCES_DIR"/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish
    source "$GHOSTTY_RESOURCES_DIR"/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish
end

# Async prompt
set -Ux async_prompt_functions fish_prompt fish_right_prompt
set -Ux async_prompt_enable 1
# ─── Abbreviations ─────────────────────────────────────────────────────────
abbr -a mv mv -iv
abbr -a rm rm -iv
abbr -a cp cp -iv
abbr -a sort sort -h
abbr -a mkdir mkdir -pv
abbr -a df df -h
abbr -a free free -h
abbr -a ip ip --color=auto
abbr -a du du -hcsx

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
