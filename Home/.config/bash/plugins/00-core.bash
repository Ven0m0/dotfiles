#================================== [Core] ====================================
# --- History
HISTCONTROL="erasedups:ignoreboth" HISTSIZE=5000 HISTFILESIZE=10000
HISTIGNORE="&:bg:fg:clear:cls:exit:history:?"
HISTTIMEFORMAT="%F %T " HISTFILE="$HOME/.bash_history"
PROMPT_DIRTRIM=3
shopt -s histappend cmdhist

# --- Shell Behavior
shopt -s autocd cdable_vars cdspell checkwinsize dirspell extglob globstar hostcomplete no_empty_cmd_completion nullglob
set -o noclobber
bind -r '\C-s'
stty -ixon -ixoff -ixany
export IGNOREEOF=10

# --- Sourcing
ifsource /etc/bashrc
ifsource /usr/share/bash-preexec/bash-preexec.sh
