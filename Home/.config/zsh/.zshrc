# ~/.zshrc

ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
[[ -z "${plugins[*]}" ]] && plugins=(git fzf extract aliases archlinux)
source $ZSH/oh-my-zsh.sh

autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search

key[Control-Left]="${terminfo[kLFT5]}"
key[Control-Right]="${terminfo[kRIT5]}"

[[ -n "${key[Control-Left]}"  ]] && bindkey -- "${key[Control-Left]}"  backward-word
[[ -n "${key[Control-Right]}" ]] && bindkey -- "${key[Control-Right]}" forward-word

HISTFILE=${HOME}/.zsh_history
HISTSIZE=10000 SAVEHIST="$HISTSIZE"
export HISTIGNORE="&:[bf]g:c:clear:history:exit:q:pwd:* --help"
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt PROMPT_SUBST

export TERM="xterm-256color" 
export EDITOR=micro
export VISUAL=micro

alias mkdir='mkdir -p'

mcd () { mkdir -p "$1" && cd "$1"; }

stty -ixon

autoload -Uz promptinit
promptinit

