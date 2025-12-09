# ~/.config/bash/plugins/00-core.bash
#================================== [Core] ====================================
# --- History
HISTCONTROL="erasedups:ignoreboth"
HISTSIZE=10000
HISTFILESIZE=20000
HISTIGNORE="&:bg:fg:clear:cls:exit:history:?:ls:pwd"
HISTTIMEFORMAT="%F %T "
HISTFILE="${HOME}/.bash_history"
PROMPT_DIRTRIM=3
PROMPT_COMMAND="history -a"
# --- Shell Behavior
shopt -s autocd cdable_vars cdspell checkwinsize dirspell globstar nullglob
shopt -s hostcomplete no_empty_cmd_completion histappend cmdhist
set -o noclobber
# Disable flow control (Ctrl-S/Q)
stty -ixon -ixoff -ixany &>/dev/null
bind -r '\C-s' &>/dev/null
export IGNOREEOF=10 COLUMNS
# --- Sourcing Legacy
ifsource /etc/bashrc
ifsource /usr/share/bash-preexec/bash-preexec.sh
