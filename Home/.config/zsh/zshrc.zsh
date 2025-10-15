# ~/.zshrc

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ $- != *i* ]] && return

DISABLE_MAGIC_FUNCTIONS="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

[[ -z "${plugins[*]}" ]] && plugins=(fzf aliases archlinux)
source $ZSH/oh-my-zsh.sh
export HISTCONTROL=ignoreboth
export HISTIGNORE="&:[bf]g:c:clear:history:exit:q:pwd:* --help"
HISTFILE=${HOME}/.zsh_history
HISTSIZE=10000 SAVEHIST="$HISTSIZE"
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt prompt_subst
setopt transient_rprompt
setopt auto_remove_slash
setopt extended_glob
setopt INC_APPEND_HISTORY EXTENDED_HISTORY HIST_IGNORE_DUPS HIST_FIND_NO_DUPS appendhistory
HIST_EXPIRE_DUPS_FIRST
HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS AUTO_PUSHD auto_cd
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
ulimit -n 10240
export CLICOLOR=1
stty -ixon

# Set 2 space indent for each new level in a multi-line script. This can then be
# overridden by a prompt or plugin, but is a better default than Zsh's.
PS2='${${${(%):-%_}//[^ ]}// /  }    '

setopt combining_chars       # Combine 0-len chars with the base character (eg: accents).
setopt NO_mail_warning
setopt rc_quotes
setopt NO_beep
setopt auto_resume
setopt long_list_jobs

# Set the default Less options.
# Mouse-wheel scrolling can be disabled with -X (disable screen clearing).
# Add -X to disable it.
if [[ -z "$LESS" ]]; then
  export LESS='-g -i -M -R -S -w -z-4'
fi

# fish -c 'fish_update_completions'
# https://github.com/umlx5h/zsh-manpage-completion-generator
# https://github.com/crazy-complete/crazy-complete

# Reduce key delay
export KEYTIMEOUT=${KEYTIMEOUT:-1}

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the list of directories that Zsh searches for programs.
if [[ ! -v prepath ]]; then
  typeset -ga prepath
  prepath=(
    $HOME/{,s}bin(N)
    $HOME/.local/{,s}bin(N)
  )
fi
path=(
  $prepath
  /opt/{homebrew,local}/{,s}bin(N)
  /usr/local/{,s}bin(N)
  $path
)

setopt NO_flow_control         # Allow the usage of ^Q/^S in the context of zsh.
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# Expands .... to ../..
function dot-expansion {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+='/..'
  else
    LBUFFER+='.'
  fi
}
zle -N dot-expansion

# Inserts 'sudo ' at the beginning of the line.
function prepend-sudo {
  if [[ "$BUFFER" != su(do|)\ * ]]; then
    BUFFER="sudo $BUFFER"
    (( CURSOR += 5 ))
  fi
}
zle -N prepend-sudo


# Use built-in paste magic.
autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# Load more specific 'run-help' function from $fpath.
(( $+aliases[run-help] )) && unalias run-help && autoload -Uz run-help
alias help=run-help

# Make ls more useful.
alias ls="${aliases[ls]:-ls} -h --group-directories-first"

alias pip=pip3
alias python=python3

if [[ "$OSTYPE" == linux-android ]]; then
  alias open='termux-open'
elif (( $+commands[xdg-open] )); then
  alias open='xdg-open'
fi

if [[ "$OSTYPE" == linux-android ]]; then
    alias pbcopy='termux-clipboard-set'
    alias pbpaste='termux-clipboard-get'
  elif (( $+commands[wl-copy] && $+commands[wl-paste] )); then
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
fi

zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

alias make="make -j`nproc`"
alias ninja="ninja -j`nproc`"
alias mkdir='mkdir -p'

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
# Fish-like syntax highlighting and autosuggestions
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export FZF_BASE=/usr/share/fzf

autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1

export TERM="xterm-256color" 
export EDITOR=micro
export VISUAL=micro

alias -g -- -h='-h 2>&1 | bat --language=help --style=plain -s --squeeze-limit 0'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain -s --squeeze-limit 0'

h() { curl cheat.sh/${@:-cheat}; }
mcd() { mkdir -p -- "$1" && cd "$1"; }
function mkcd() {
	mkdir -p -- "$1" &&
		cd -P -- "$1" || return
}

bindkey -M emacs '^Z' symmetric-ctrl-z
bindkey -M viins '^Z' symmetric-ctrl-z
bindkey -e

setopt pushd_silent
setopt pushd_minus
setopt pushd_to_home

LS_COLORS=${LS_COLORS:-'di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'}
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$__zsh_cache_dir/zcompcache"

# Group matches and describe.
  zstyle ':completion:*:*:*:*:*' menu select
  zstyle ':completion:*:matches' group 'yes'
  zstyle ':completion:*:options' description 'yes'
  zstyle ':completion:*:options' auto-description '%d'
  zstyle ':completion:*:corrections' format ' %F{red}-- %d (errors: %e) --%f'
  zstyle ':completion:*:descriptions' format ' %F{purple}-- %d --%f'
  zstyle ':completion:*:messages' format ' %F{green} -- %d --%f'
  zstyle ':completion:*:warnings' format ' %F{yellow}-- no matches found --%f'
  zstyle ':completion:*' format ' %F{blue}-- %d --%f'
  zstyle ':completion:*' group-name ''
  zstyle ':completion:*' verbose yes

  # Fuzzy match mistyped completions.
  zstyle ':completion:*' completer _complete _match _approximate
  zstyle ':completion:*:match:*' original only
  zstyle ':completion:*:approximate:*' max-errors 1 numeric

  # Increase the number of errors based on the length of the typed word. But make
  # sure to cap (at 7) the max-errors to avoid hanging.
  zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'

  # Don't complete unavailable commands.
  zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

  # Array completion element sorting.
  zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

  # Directories
  zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
  zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
  zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
  zstyle ':completion:*' squeeze-slashes true
  zstyle ':completion:*' special-dirs ..

  # History
  zstyle ':completion:*:history-words' stop yes
  zstyle ':completion:*:history-words' remove-all-dups yes
  zstyle ':completion:*:history-words' list false
  zstyle ':completion:*:history-words' menu yes

  # Environment Variables
  zstyle ':completion::*:(-command-|export):*' fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-}

  # Populate hostname completion. But allow ignoring custom entries from static
  # */etc/hosts* which might be uninteresting.
  zstyle -a ':zephyr:plugin:compstyle:*:hosts' etc-host-ignores '_etc_host_ignores'

  zstyle -e ':completion:*:hosts' hosts 'reply=(
    ${=${=${=${${(f)"$(cat {/etc/ssh/ssh_,~/.ssh/}known_hosts(|2)(N) 2> /dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
    ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2> /dev/null))"}%%(\#${_etc_host_ignores:+|${(j:|:)~_etc_host_ignores}})*}
    ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2> /dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
  )'

  # Don't complete uninteresting users...
  zstyle ':completion:*:*:*:users' ignored-patterns \
    adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
    dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
    hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
    mailman mailnull mldonkey mysql nagios \
    named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
    operator pcap postfix postgres privoxy pulse pvm quagga radvd \
    rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs '_*'

  # ... unless we really want to.
  zstyle '*' single-ignored show

  # Ignore multiple entries.
  zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
  zstyle ':completion:*:rm:*' file-patterns '*:all-files'

  # Kill
  zstyle ':completion:*:*:*:*:processes' command 'ps -u $LOGNAME -o pid,user,command -w'
  zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
  zstyle ':completion:*:*:kill:*' menu yes select
  zstyle ':completion:*:*:kill:*' force-list always
  zstyle ':completion:*:*:kill:*' insert-ids single

  # Man
  zstyle ':completion:*:manuals' separate-sections true
  zstyle ':completion:*:manuals.(^1*)' insert-sections true
  zstyle ':completion:*:man:*' menu yes select

  # Media Players
  zstyle ':completion:*:*:mpg123:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
  zstyle ':completion:*:*:mpg321:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
  zstyle ':completion:*:*:ogg123:*' file-patterns '*.(ogg|OGG|flac):ogg\ files *(-/):directories'
  zstyle ':completion:*:*:mocp:*' file-patterns '*.(wav|WAV|mp3|MP3|ogg|OGG|flac):ogg\ files *(-/):directories'

  # SSH/SCP/RSYNC
  zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
  zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
  zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
  zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
  zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
  zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# Add descriptive hints to completion options
zstyle ':completion:*' auto-description 'specify: %d'

# Groups the different type of matches under their description
zstyle ':completion:*' group-name ''

# Enables completion for command options (offers suggestions for options relevant to the command being typed)
zstyle '  :completion:*' complete-options true

# Allow hidden files/directories to be shown/included in completions
_comp_options+=(globdots)

# Retains the prefix typed by the user in the completion suggestions
zstyle ':completion:*' keep-prefix true

# Better SSH/Rsync/SCP Autocomplete
zstyle ':completion:*:(ssh|scp|ftp|sftp):*' hosts $hosts

# Makes completion more forgiving and flexible (case-insensitive etc.)
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'

# Sorts files in completion suggestions based on their modification times
zstyle ':completion:*' file-sort modification

# Set the minimum input length for the incremental search to trigger
zstyle ':autocomplete:history-incremental-search-backward:*' min-input 3

# Override for history search only
zstyle ':autocomplete:history-incremental-search-backward:*' list-lines 10

# Carape completion
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

export CLICOLOR=1
setopt AUTOCD              # change directory just by typing its name
setopt PROMPT_SUBST        # enable command substitution in prompt
setopt MENU_COMPLETE       # Automatically highlight first element of completion menu
setopt LIST_PACKED	   # The completion menu takes less space.
setopt AUTO_LIST           # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD    # Complete from both ends of a word.
# Reduce latency when pressing <Esc>
export KEYTIMEOUT=1
HISTDUP=erase
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt AUTO_CD autopushd
# Enable ** and *** as shortcuts for **/* and ***/*, respectively.
# https://zsh.sourceforge.io/Doc/Release/Expansion.html#Recursive-Globbing
setopt GLOB_STAR_SHORT
# Use modern file-locking mechanisms, for better safety & performance.
setopt HIST_FCNTL_LOCK
# Auto-sync history between concurrent sessions.
setopt SHARE_HISTORY
# Enable additional glob operators. (Globbing = pattern matching)
# https://zsh.sourceforge.io/Doc/Release/Expansion.html#Filename-Generation
setopt EXTENDED_GLOB
# Don't let > silently overwrite files. To overwrite, use >! instead.
setopt NO_CLOBBER
# Treat comments pasted into the command line as comments, not code.
setopt INTERACTIVE_COMMENTS
# Don't treat non-executable files in your $path as commands. This makes sure
# they don't show up as command completions. Settinig this option can impact
# performance on older systems, but should not be a problem on modern ones.
setopt HASH_EXECUTABLES_ONLY
# Sort numbers numerically, not lexicographically.
setopt NUMERIC_GLOB_SORT
# Enable the use of Ctrl-Q and Ctrl-S for keyboard shortcuts.
unsetopt FLOW_CONTROL
unalias run-help 2> /dev/null   # Remove the simple default.
autoload -RUz run-help          # Load a more advanced version.
# -R resolves the function immediately, so we can access the source dir.

# Load $functions_source, an associative array (a.k.a. dictionary, hash table
# or map) that maps each function to its source file.
zmodload -F zsh/parameter p:functions_source

# Lazy-load all the run-help-* helper functions from the same dir.
autoload -Uz $functions_source[run-help]-*~*.zwc  # Exclude .zwc files.

# -U ensures each entry in these is unique (that is, discards duplicates).
export -U PATH path FPATH fpath MANPATH manpath
export -UT INFOPATH infopath  # -T creates a "tied" pair; see below.

# These aliases enable you to paste example code into the terminal without the
# shell complaining about the pasted prompt symbol.
alias %= \$=

# Associate file name .extensions with programs to open them.
# This lets you open a file just by typing its name and pressing enter.
# Note that the dot is implicit; `gz` below stands for files ending in .gz
alias -s {css,gradle,html,js,json,md,patch,properties,txt,xml,yml}=$PAGER
alias -s gz='gzip -l'
alias -s {log,out}='tail -F'

# Use `< file` to quickly view the contents of any text file.
READNULLCMD=$PAGER  # Set the program to use for this.

# Auto-remove the right side of each prompt when you press enter. This way,
# we'll have less clutter on screen. This also makes it easier to copy code from
# our terminal.
setopt TRANSIENT_RPROMPT

# If we're not on an SSH connection, then remove the outer margin of the right
# side of the prompt.
[[ -v SSH_CONNECTION ]] || ZLE_RPROMPT_INDENT=0
source $ZSH/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $ZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
ZSH_COMPDUMP="${ZSH}/.zcompdump"
compinit -C -d "$ZSH_COMPDUMP"
typeset -gU cdpath fpath path
cdd() {
  local dir
  dir=$(fd -t d | fzf --prompt="Directory: " --height=50% --border)
  [[ -n $dir ]] && cd "$dir"
}

emf() {
  local file
  file=$(fzf --prompt="Edit: " --height=50% --border)
  [[ -n $file ]] && $EDITOR "$file"
}

# Sudo prefix
function _sudo-widget {
  [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
  zle end-of-line
}
zle -N _sudo-widget
bindkey '\e\e' _sudo-widget  # Alt+Alt

# Create directory and change to it
take() {
  mkdir -p "$1" && cd "$1"
}
# Extract archives intelligently
extract() {
  case $1 in
    *.tar.gz|*.tgz) tar -xzf "$1";;
    *.tar.bz2|*.tbz2) tar -xjf "$1";;
    *.zip) unzip "$1";;
    *.rar) unrar x "$1";;
    *) echo "Unknown archive format";;
  esac
}
# Find and kill processes by name
pskill() {
  ps aux | grep "$1" | grep -v grep | awk '{print $2}' | xargs kill
}
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh



source /usr/share/fzf-tab-completion/zsh/fzf-zsh-completion.sh
bindkey '^I' fzf_completion

autoload -Uz promptinit
promptinit

setopt always_to_end
setopt auto_list
setopt auto_menu
setopt auto_param_slash
setopt complete_in_word
setopt path_dirs
setopt NO_flow_control
setopt menu_complete
# Allow Fish-like user contributed completions.
fpath=($__zsh_config_dir/completions(-/FN) $fpath)

setopt local_options

  # Set colors for diff.
  if command diff --color /dev/null{,} &>/dev/null; then
    alias diff="${aliases[diff]:-diff} --color"
  fi

  # Set colors for grep.
  alias grep="${aliases[grep]:-grep} --color=auto"

# Colorize completions.
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v zellij >/dev/null 2>&1 && eval "$(zellij setup --generate-auto-start zsh)"
command -v intelli-shell >/dev/null 2>&1 && eval "$(intelli-shell init zsh)"
