#!/usr/bin/env zsh

# Skip if non-interactive
[[ $- != *i* ]] && return

has(){ command -v -- "$1" >/dev/null 2>&1; return $?; }
ifsource(){ [ -r "$1" ] && source "$1"; }

ifsource "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# =========================================================
# CORE / ENV
# =========================================================
setopt EXTENDED_GLOB NULL_GLOB GLOB_DOTS

export SHELL=zsh
export EDITOR=micro VISUAL=micro
export PAGER=bat
export TERM=xterm-256color
export CLICOLOR=1 MICRO_TRUECOLOR=1
export KEYTIMEOUT=1
export TZ=Europe/Berlin
export TIME_STYLE='+%d-%m %H:%M'
export LC_ALL=C.UTF-8 LANG=C.UTF-8 LANGUAGE=C.UTF-8

# Less/Man
export LESS='-g -i -M -R -S -w -z-4'
export LESSHISTFILE=- LESSCHARSET=utf-8
export MANPAGER="sh -c 'col -bx | bat -lman -ps --squeeze-limit 0'"
export MANROFFOPT="-c"

# FZF
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
export FZF_DEFAULT_COMMAND='fd -tf -gH -c always -strip-cwd-prefix -E ".git"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd -td -gH -c always'

export GPG_TTY=$TTY
export RUSTUP_DIST_SERVER='https://mirrors.ustc.edu.cn/rust-static'         # affect `rustup update`
export RUSTUP_UPDATE_ROOT='https://mirrors.ustc.edu.cn/rust-static/rustup'  # affect `rustup self-update`


# =========================================================
# ZSH OPTIONS
# =========================================================
# Directory navigation
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT PUSHD_TO_HOME PUSHD_MINUS CD_SILENT
# Globbing/completion behavior
setopt EXTENDED_GLOB GLOB_DOTS NULL_GLOB GLOB_STAR_SHORT NUMERIC_GLOB_SORT HASH_EXECUTABLES_ONLY
# History
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS INC_APPEND_HISTORY EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS SHARE_HISTORY HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST HIST_FCNTL_LOCK
# I/O & UI
setopt INTERACTIVE_COMMENTS RC_QUOTES NO_BEEP NO_FLOW_CONTROL
setopt NO_CLOBBER AUTO_RESUME COMBINING_CHARS NO_MAIL_WARNING
setopt CORRECT CORRECT_ALL LONG_LIST_JOBS TRANSIENT_RPROMPT
setopt NOTIFY
setopt magic_equal_subst     # perform filename expansion on `any=expr` args
stty stop undef >/dev/null 

# =========================================================
# PATHS
# =========================================================
typeset -gU cdpath fpath mailpath path

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
  "$HOME/.{cargo,local}/bin"(N)
  $path
)

# =========================================================
# HISTORY
# =========================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
HISTTIMEFORMAT="%F %T "

# =========================================================
# ZINIT (Plugin manager)
# =========================================================
: ${ZINIT_HOME:=${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git}
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p -- "${ZINIT_HOME:h}" && \
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" &>/dev/null || :
fi
source "${ZINIT_HOME}/zinit.zsh"

# Plugin prefs before load
typeset -g ZSH_AUTOSUGGEST_STRATEGY=(history completion)
typeset -g ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# Annexes
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

# Core plugins + compinit bootstrap
zinit wait lucid light-mode for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions

unset 'FAST_HIGHLIGHT[chroma-man]'  # buggy: stuck history browsing
unset 'FAST_HIGHLIGHT[chroma-ssh]'  # buggy: incorrect

# Theme (p10k)
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Extra plugins
zinit wait lucid for \
  zsh-users/zsh-history-substring-search \
  hlissner/zsh-autopair \
  MichaelAquilina/zsh-you-should-use

# zoxide as program (fast jump)
zinit wait'0' lucid as'program' from'gh-r' for ajeetdsouza/zoxide

# https://github.com/adi-li/zsh-cwebpb
zinit load "adi-li/zsh-cwebpb"
# https://github.com/qoomon/zsh-lazyload
zinit load "qoomon/zsh-lazyload"
# https://github.com/romkatv/zsh-defer
zinit load "romkatv/zsh-defer"
# https://github.com/QuarticCat/zsh-smartcache
zinit load "QuarticCat/zsh-smartcache"

# https://github.com/zdharma-continuum/zsh-sweep
zinit sbin'bin/zsweep' for @psprint/zsh-sweep

zinit wait lucid for dim-an/cod


autoload -Uz colors && colors

# =========================================================
# COMPLETION (fast + styled)
# =========================================================
autoload -Uz compinit
() {
  local zdump="${XDG_CACHE_HOME:-$HOME/.cache}/.zcompdump"
  local now mtime skip=0
  if [[ -f $zdump ]]; then
    now=$(date +%s)
    mtime=$(stat -c %Y "$zdump" 2>/dev/null || stat -f %m "$zdump" 2>/dev/null)
    [[ -n $mtime && $((now - mtime)) -lt 86400 ]] && skip=1
  fi
  if (( skip )); then
    compinit -C -d "$zdump"
  else
    compinit -d "$zdump"
    { zcompile "$zdump" } &!
  fi
}

# Styles
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*:match:*' original only
zstyle ':completion:*' squeeze-slashes false
zstyle ':completion:*' special-dirs true
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:options' description yes
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{red}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{purple}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{green} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{yellow}-- no matches found --%f'
zstyle ':completion:*' format ' %F{blue}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

# Process completion
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always

# SSH/SCP/RSYNC completion
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# LS_COLORS for completions
if (( $+commands[vivid] )); then
  export LS_COLORS="$(vivid generate molokai)"
elif (( $+commands[dircolors] )); then
  eval "$(dircolors -b)" &>/dev/null
fi
LS_COLORS=${LS_COLORS:-'di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'}
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# FZF tab completion (if installed to PREFIX)
if (( $+commands[fzf] )) && [[ -n ${PREFIX:-} && -f ${PREFIX}/share/fzf-tab-completion/zsh/fzf-zsh-completion.sh ]]; then
  source "${PREFIX}/share/fzf-tab-completion/zsh/fzf-zsh-completion.sh"
  bindkey '^I' fzf_completion
fi

# =========================================================
# PROMPT / THEME
# =========================================================
# p10k config (do not also set PROMPT/RPROMPT to avoid conflicts)
[[ -f $HOME/.p10k.zsh ]] && source "$HOME/.p10k.zsh"

# =========================================================
# FUNCTIONS
# =========================================================
has(){ command -v -- "$1" &>/dev/null; }
ifsource(){ [[ -r $1 ]] && source "$1"; }

mkcd(){ mkdir -p -- "$1" && cd -- "$1" || return; }
touchf(){ mkdir -p -- "${1:h}"; command touch -- "$1"; }

extract(){
  local f=$1
  [[ -f $f ]] || { print -r -- "File does not exist: $f" >&2; return 1; }
  case "$f" in
    *.tar.bz2|*.tbz2) tar -xjf "$f" ;;
    *.tar.gz|*.tgz)   tar -xzf "$f" ;;
    *.tar.xz|*.txz)   tar -xJf "$f" ;;
    *.tar)            tar -xf "$f" ;;
    *.bz2)            bunzip2 "$f" ;;
    *.gz)             gunzip "$f" ;;
    *.zip)            unzip -q "$f" ;;
    *.rar)            unrar x "$f" ;;
    *.Z)              uncompress "$f" ;;
    *.7z)             7z x "$f" ;;
    *)                print -r -- "Unsupported archive: $f" >&2; return 2 ;;
  esac
}

# fcd: fuzzy-pick a directory and cd into it
# Usage: fcd [root_dir] [query...]
fcd() {
  local root="." q sel preview
  [[ $# -gt 0 && -d $1 ]] && { root="$1"; shift; }
  q="${*:-}"
  preview=$(( $+commands[eza] )) && preview='eza -T -L2 --color=always {}' || preview='ls -la --color=always {}'
  if (( $+commands[fd] )); then
    sel="$(fd -HI -t d . "$root" 2>/dev/null | fzf --ansi --height ${FZF_HEIGHT:-60%} --layout=reverse --border --select-1 --exit-0 --preview "$preview" ${q:+--query "$q"})"
  else
    sel="$(find "$root" -type d -not -path '*/.git/*' -print 2>/dev/null | fzf --ansi --height ${FZF_HEIGHT:-60%} --layout=reverse --border --select-1 --exit-0 --preview "$preview" ${q:+--query "$q"})"
  fi
  [[ -n $sel ]] && cd -- "$sel"
}

# fe: fuzzy-pick files and open in $EDITOR
fe() {
  local -a files; local q="${*:-}" preview
  if (( $+commands[bat] )); then
    preview='bat -n --style=plain --color=always --line-range=:500 {}'
  else
    preview='head -n 500 {}'
  fi
  if (( $+commands[fzf] )); then
    files=("${(@f)$(fzf --multi --select-1 --exit-0 ${q:+--query="$q"} --preview "$preview")}")
  else
    print -r -- "fzf not found" >&2; return 127
  fi
  [[ ${#files} -gt 0 ]] && "${EDITOR:-micro}" "${files[@]}"
}

h(){ curl "cheat.sh/${@:-cheat}"; }

dot-expansion(){
  if [[ $LBUFFER = *.. ]]; then LBUFFER+='/..'; else LBUFFER+='.'; fi
}
zle -N dot-expansion

prepend-sudo(){
  if [[ $BUFFER != su(do|)\ * ]]; then BUFFER="sudo $BUFFER"; (( CURSOR += 5 )); fi
}
zle -N prepend-sudo

pskill(){ ps aux | grep -F -- "$1" | grep -v grep | awk '{print $2}' | xargs kill; }

dsort(){ du -shx -- * 2>/dev/null | sort -rh | head -n "${1:-20}"; }
bak(){ cp -r -- "$1" "${1}.bak.$(date +%Y%m%d-%H%M%S)"; }

# =========================================================
# ALIASES
# =========================================================
# Prefer rust tools; provide sane fallbacks
if has eza; then
  alias ls='eza --git --icons --classify --group-directories-first --time-style=long-iso --group --color-scale'
  alias l='ls --git-ignore'
  alias ll='eza --all --header --long --git --icons --classify --group-directories-first --group --color-scale'
  alias llm='ll --sort=modified'
  alias la='eza -lbhHigUmuSa'
  alias lx='eza -lbhHigUmuSa@'
  alias lt='eza --tree'
  alias tree='eza --tree'
else
  alias ls='ls --color=auto --group-directories-first'
  alias l='ls -CF'
  alias ll='ls -alF --color=auto --group-directories-first'
  alias la='ls -A --color=auto'
  alias tree='tree -C' 2>/dev/null || :
fi

has bat && alias cat='bat -p'
if has rg; then alias grep='rg'; else alias grep='grep --color=auto'; fi

# Wayland helpers (Arch/Wayland, Debian/Wayland)
alias open='xdg-open'
alias copy='wl-copy'
alias paste='wl-paste'

# zoxide
if has zoxide; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# Quick nav
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Python
alias python=python3
alias pip='python3 -m pip'

# Build
alias make="make -j$(nproc)"
alias ninja="ninja -j$(nproc)"
alias mkdir='mkdir -p'

# Suffix
alias -s {css,gradle,html,js,json,md,patch,properties,txt,xml,yml}=$PAGER
alias -s gz='gzip -l'
alias -s {log,out}='tail -F'

# Misc
alias e="$EDITOR"
alias r='bat -p'
alias which='command -v'
alias dirs='dirs -v'
alias sudo='sudo '
alias sudo-rs='sudo-rs '
alias doas='doas '

# Globals
alias -g -- -h='-h 2>&1 | bat -plhelp'
alias -g -- --help='--help 2>&1 | bat -plhelp'
alias -g L="| ${PAGER:-less}"
alias -g G="| rg -i"
alias -g NE="2>/dev/null"
alias -g NUL=">/dev/null 2>&1"

# =========================================================
# KEYBINDINGS
# =========================================================
bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[Z' reverse-menu-complete
bindkey '\e\e' prepend-sudo
bindkey '^R' history-incremental-pattern-search-backward
bindkey '\C-Z' undo
bindkey '\C-Y' redo

# Ref: https://github.com/marlonrichert/zsh-edit
qc-word-widgets() {
    local wordpat='[[:WORD:]]##|[[:space:]]##|[^[:WORD:][:space:]]##'
    local words=(${(Z:n:)BUFFER}) lwords=(${(Z:n:)LBUFFER})
    case $WIDGET {
        (*sub-l)   local move=-${(N)LBUFFER%%$~wordpat} ;;
        (*sub-r)   local move=+${(N)RBUFFER##$~wordpat} ;;
        (*shell-l) local move=-${(N)LBUFFER%$lwords[-1]*} ;;
        (*shell-r) local move=+${(N)RBUFFER#*${${words[$#lwords]#$lwords[-1]}:-$words[$#lwords+1]}} ;;
    }
    case $WIDGET {
        (*kill*) (( MARK = CURSOR + move )); zle -f kill; zle .kill-region ;;
        (*)      (( CURSOR += move )) ;;
    }
}
for w in qc{,-kill}-{sub,shell}-{l,r}; zle -N $w qc-word-widgets
bindkey '\E[1;5D' qc-sub-l         # [Ctrl+Left]
bindkey '\E[1;5C' qc-sub-r         # [Ctrl+Right]
bindkey '\E[1;3D' qc-shell-l       # [Alt+Left]
bindkey '\E[1;3C' qc-shell-r       # [Alt+Right]
bindkey '\C-H'    qc-kill-sub-l    # [Ctrl+Backspace] (Konsole)
bindkey '\C-W'    qc-kill-sub-l    # [Ctrl+Backspace] (VSCode)
bindkey '\E[3;5~' qc-kill-sub-r    # [Ctrl+Delete]
bindkey '\E^?'    qc-kill-shell-l  # [Alt+Backspace]
bindkey '\E[3;3~' qc-kill-shell-r  # [Alt+Delete]
WORDCHARS='*?[]~&;!#$%^(){}<>'

# Trim trailing spaces from pasted text
# Ref: https://unix.stackexchange.com/questions/693118
qc-trim-paste() {
    zle .$WIDGET && LBUFFER=${LBUFFER%%[[:space:]]#}
}
zle -N bracketed-paste qc-trim-paste

# Change `...` to `../..`
# Ref: https://grml.org/zsh/zsh-lovers.html#_completion
qc-rationalize-dot() {
    if [[ $LBUFFER == *.. ]] {
        LBUFFER+='/..'
    } else {
        LBUFFER+='.'
    }
}
zle -N qc-rationalize-dot
bindkey '.'   qc-rationalize-dot
bindkey '\E.' self-insert-unmeta  # [Alt+.] insert dot

# [Ctrl+L] Clear screen but keep scrollback
# Ref: https://superuser.com/questions/1389834
qc-clear-screen() {
    local prompt_height=$(print -n ${(%%)PS1} | wc -l)
    local lines=$((LINES - prompt_height))
    printf "$terminfo[cud1]%.0s" {1..$lines}  # cursor down
    printf "$terminfo[cuu1]%.0s" {1..$lines}  # cursor up
    zle .reset-prompt
}
zle -N qc-clear-screen
bindkey '\C-L' qc-clear-screen


autoload -Uz add-zsh-hook

# [PRECMD] Reset cursor shape as some programs (nvim, yazi) will change it
_qc-reset-cursor() {
    print -n '\E[5 q'  # line cursor
}
add-zsh-hook precmd _qc-reset-cursor

# =========================================================
# TOOL INTEGRATIONS
# =========================================================
# zellij (auto-start)
(( $+commands[zellij] )) && eval "$(zellij setup --generate-auto-start zsh)"

# Intelli-shell
(( $+commands[intelli-shell] )) && eval "$(intelli-shell init zsh)"

# thefuck (cached alias script)
if (( $+commands[thefuck] )); then
  local tf_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/thefuck"
  mkdir -p -- "${tf_cache:h}"
  [[ ! -f $tf_cache ]] && thefuck --alias > "$tf_cache"
  source "$tf_cache"
fi

# theshit
(( $+commands[theshit] )) && eval "$($HOME/.cargo/bin/theshit alias shit)"

# mise
[[ -f $HOME/.local/bin/mise ]] && eval "$($HOME/.local/bin/mise activate zsh)"

# carapace
if (( $+commands[carapace] )); then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
  source <(carapace _carapace)
fi

# Login info (fastfetch)
if [[ -o INTERACTIVE && -t 2 && $+commands[fastfetch] -ne 0 ]]; then
  fastfetch
fi >&2

# =========================================================
# FINAL OPTIMIZATIONS
# =========================================================
autoload -Uz zrecompile
for f in ~/.zshrc ~/.zshenv ~/.p10k.zsh; do
  [[ -f $f && ( ! -f ${f}.zwc || $f -nt ${f}.zwc ) ]] && zrecompile -pq "$f" &>/dev/null
done
unset f
