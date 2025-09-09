# ~/.zshrc


HISTFILE=${HOME}/.zsh_history
HISTSIZE=10000 SAVEHIST="$HISTSIZE"

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt PROMPT_SUBST

export TERM="xterm-256color" 
export EDITOR=micro
export VISUAL=micro

alias mkdir='mkdir -p'

mcd () { mkdir -p "$1" && cd "$1"; }

stty -ixon
