source /usr/share/cachyos-fish-config/cachyos-config.fish
set -e LC_ALL

# Only for interactive shells
if status -i >/dev/null 2>&1

set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

set -U __done_notification_urgency_level low

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
