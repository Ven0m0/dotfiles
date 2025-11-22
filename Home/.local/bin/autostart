#!/bin/sh
#
# summary: a simple posix script for launching multiple preset programs
# repository: https://github.com/hollowillow/scripts
#
# usage: autostart [arg]
# description: 
#
#       launch sets of applications using files located in "$XDG_CONFIG_HOME/autostart".
#       each file should only contain programs to be executed separated by newlines.
#       not providing an argument launches a fzf window to select one or more files.
#       providing arguments that are valid file names within the directory launches them directly.
#
# dependencies: fzf

# create help message from comment block at the head of file
if [ "$1" = "-h" ]; then
        sed "1,2d;s/^# //;s/^#$/ /;/^$/ q" "$0"; exit 0
fi

# declare autostart directory
AUTOSTART_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
mkdir -p "$AUTOSTART_DIR" # create directory if it doesn't already exist
cd "$AUTOSTART_DIR" || { printf '%s\n' "Error: Autostart directory not found"; exit 2; }

# parse arguments or launch interactive fzf menu
IFS='
'
if [ -n "$*" ]; then
        FILES="$*"
else
        FILES=$(\
                find "$AUTOSTART_DIR" -type f -exec basename {} \; | 
                fzf \
                --prompt='autostart: ' \
                --header="$(printf '%s\n' 'enter:confirm' "$FZF_DEFAULT_HEADER")" \
                --preview='cat {}' \
                --multi \
        )
fi

if [ -z "$FILES" ]; then
    printf '%s\n' "No files selected."; exit 1
fi

# launch programs specified within selected files
for FILE in $FILES; do
        # make sure file still exists since launching script
        if [ -f "$AUTOSTART_DIR/$FILE" ]; then
                while IFS= read -r PROGRAM; do
                        # spawn detached program
                        nohup "$PROGRAM" >/dev/null 2>&1 &
                done < "$AUTOSTART_DIR/$FILE"
        else
                printf '%s\n' "Warning: File '$FILE' does not exist."
        fi
done
