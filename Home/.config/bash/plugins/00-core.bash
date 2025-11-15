#================================== [Core] ====================================
# --- History
HISTCONTROL="erasedups:ignoreboth" HISTSIZE=5000 HISTFILESIZE=10000
HISTIGNORE="&:bg:fg:clear:cls:exit:history:?"
HISTTIMEFORMAT="%F %T " HISTFILE="${HOME}/.bash_history"
PROMPT_DIRTRIM=3 PROMPT_COMMAND="history -a"

# --- Shell Behavior
shopt -s autocd cdable_vars cdspell checkwinsize dirspell globstar nullglob hostcomplete no_empty_cmd_completion histappend cmdhist
set -o noclobber
bind -r '\C-s'
stty -ixon -ixoff -ixany
export IGNOREEOF=10 COLUMNS

# --- Sourcing
ifsource /etc/bashrc
ifsource /usr/share/bash-preexec/bash-preexec.sh
