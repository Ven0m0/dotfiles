source /usr/share/cachyos-fish-config/cachyos-config.fish

set -e LC_ALL

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
