#!/usr/bin/env zsh
[[ $- != *i* ]] && return
has(){ command -v -- "$1" &>/dev/null; }
ifsource(){ [[ -f $1 ]] && . "$1"; }
ifsource "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

if has mommy; then
  export MOMMY_COLOR="" MOMMY_PREFIX="%F{005}/%F{006}" MOMMY_SUFFIX="~%f" MOMMY_COMPLIMENTS_ENABLED=0
  set -o PROMPT_SUBST; RPS1='$(mommy -1 -s $?)'
fi

setopt EXTENDED_GLOB NULL_GLOB GLOB_DOTS no_global_rcs AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS \
  PUSHD_SILENT PUSHD_TO_HOME PUSHD_MINUS CD_SILENT path_dirs GLOB_STAR_SHORT NUMERIC_GLOB_SORT \
  HASH_EXECUTABLES_ONLY HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS INC_APPEND_HISTORY EXTENDED_HISTORY \
  HIST_REDUCE_BLANKS HIST_SAVE_NO_DUPS SHARE_HISTORY HIST_IGNORE_SPACE HIST_EXPIRE_DUPS_FIRST \
  HIST_FCNTL_LOCK INTERACTIVE_COMMENTS RC_QUOTES NO_BEEP NO_FLOW_CONTROL NO_HIST_BEEP NO_CLOBBER \
  AUTO_RESUME COMBINING_CHARS NO_MAIL_WARNING LONG_LIST_JOBS TRANSIENT_RPROMPT PROMPT_SUBST NOTIFY \
  MAGIC_EQUAL_SUBST LIST_PACKED AUTO_LIST AUTO_MENU AUTO_PARAM_KEYS COMPLETE_IN_WORD NONOMATCH \
  SHORT_LOOPS RM_STAR_WAIT
unsetopt MENU_COMPLETE
skip_global_compinit=1 DISABLE_MAGIC_FUNCTIONS=true ENABLE_CORRECTION=true COMPLETION_WAITING_DOTS=true

export EDITOR=micro VISUAL=${VISUAL:-code} PAGER=bat GIT_PAGER=delta BAT_STYLE=auto \
  BATDIFF_USE_DELTA=true BATPIPE=color LESSCHARSET=utf-8 LESSHISTFILE=- LESSQUIET=1 \
  TERM=xterm-256color CLICOLOR=1 MICRO_TRUECOLOR=1 KEYTIMEOUT=1 TZ=Europe/Berlin \
  TIME_STYLE='+%d-%m %H:%M' LC_ALL=C.UTF-8 LANG=C.UTF-8 LANGUAGE=C.UTF-8 \
  LESS='-g -i -M -R -S -w -z-4' GPG_TTY=$TTY HISTCONTROL=ignoreboth \
  HISTORY_IGNORE="(\&|[bf]g|c|clear|history|exit|q|pwd|* --help)" \
  FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline" \
  FZF_DEFAULT_COMMAND='fd -tf -gH -c always -strip-cwd-prefix -E .git' \
  FZF_ALT_C_COMMAND='fd -td -gH -c always'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
WORDCHARS='*?[]~&;!#$%^(){}<>' HISTFILE=$HOME/.zsh_history HISTSIZE=10000 SAVEHIST=10000
stty stop undef &>/dev/null || :

typeset -gaU cdpath fpath mailpath path prepath
[[ -v prepath ]] || prepath=($HOME/{.local/,.}bin(N) $HOME/.cargo/bin)
path=($prepath /usr/local/{,s}bin(N) $HOME/.{cargo,local}/bin(N) /usr/{local/,}{s,}bin $path)
cdpath=($HOME .. $HOME/*(N-/) $HOME/.config)
export PATH XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config} \
  XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache} \
  XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share} \
  XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state} \
  XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$UID} \
  XDG_PROJECTS_DIR=${XDG_PROJECTS_DIR:-$HOME/Projects} \
  ZDOTDIR=$XDG_CONFIG_HOME/zsh ZSH_CACHE_DIR=$XDG_CACHE_HOME/zsh \
  ZSH_COMPDUMP=$ZSH_CACHE_DIR/.zcompdump

antidote_dir=$XDG_DATA_HOME/antidote
[[ -d $antidote_dir ]] || git clone --depth 1 https://github.com/mattmc3/antidote "$antidote_dir" &>/dev/null || :
bundle=$ZSH_CACHE_DIR/.zsh_plugins.zsh list=$XDG_CONFIG_HOME/zsh/config/plugins.txt
[[ -f $bundle && $list -ot $bundle ]] || "$antidote_dir/bin/antidote" bundle <"$list" >"$bundle"
source "$bundle"

typeset -g ZSH_AUTOSUGGEST_STRATEGY=(history completion) ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
zstyle ':omz:plugins:ssh-agent' agent-forwarding yes lazy yes quiet yes
unset 'FAST_HIGHLIGHT[chroma-man]' 'FAST_HIGHLIGHT[chroma-ssh]' 2>/dev/null || :

has fzf && eval "$(fzf --zsh)" && (( $+functions[fzf_completion] )) && bindkey '^T' fzf_completion
has zoxide && eval "$(zoxide init zsh)" && alias cd=z
has mise && eval "$(mise activate zsh)"

autoload -Uz compinit
(){ local z=$XDG_CACHE_HOME/.zcompdump n=$(date +%s) m; [[ -f $z ]] && m=$(stat -c %Y "$z" 2>/dev/null || stat -f %m "$z" 2>/dev/null)
  (( m && n-m < 86400 )) && compinit -C -d "$z" || { compinit -d "$z"; zcompile "$z" &! }; }
zstyle ':completion:*:default' menu select=1 list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' use-cache on cache-path $XDG_CACHE_HOME/zsh/zcompcache insert-unambiguous true \
  matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*' completer _complete _match _approximate \
  squeeze-slashes false special-dirs true
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:options' description yes auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{red}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format ' %F{yellow}-- no matches --%f'
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands
zstyle ':completion:*:sudo:*' command-path /usr/{local/,}{s,}bin /{s,}bin
zstyle ':autocomplete:*' min-input 1 insert-unambiguous yes
zstyle ':fzf-tab:*' switch-group '<' '>' use-fzf-default-opts yes
zstyle ':fzf-tab:complete:pacman:*' fzf-preview 'pacman -Si $word'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -T -L2 --color=always $realpath'
has vivid && LS_COLORS="$(vivid generate molokai)" || has dircolors && eval "$(dircolors -b)" 2>/dev/null
LS_COLORS=${LS_COLORS:-'di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:'}
zstyle ':completion:*' verbose true


[[ -z $SSH_AUTH_SOCK ]] && has ssh-agent && eval "$(ssh-agent -s -a "$XDG_RUNTIME_DIR/ssh-agent.socket" 2>/dev/null)" >/dev/null
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

has eza && alias ls='eza --git --icons -F --group-directories-first --time-style=long-iso --color-scale' \
  l='eza --git-ignore --git --icons -F --group-directories-first --time-style=long-iso' \
  ll='eza -alh --git --icons -F --group-directories-first --time-style=long-iso' \
  llm='eza -alh --sort=modified --git --icons -F --group-directories-first' \
  lt='eza --tree' tree='eza --tree'
has mise && alias mx='mise x --'

mkcd(){ mkdir -p "$1" && cd "$1" && (has eza && eza || ls); }
touchf(){ mkdir -p "${1:h}" && touch "$1"; }
extract(){ [[ -f $1 ]] || return 1; case $1 in *.tar.bz2|*.tbz2) tar xjf "$1";; *.tar.gz|*.tgz) tar xzf "$1";;
  *.tar.xz|*.txz) tar xJf "$1";; *.tar) tar xf "$1";; *.bz2) bunzip2 "$1";; *.gz) gunzip "$1";;
  *.zip) unzip -q "$1";; *.rar) unrar x "$1";; *.Z) uncompress "$1";; *.7z) 7z x "$1";; *) return 2;; esac; }
fcd(){ local r=. q p s; [[ $# -gt 0 && -d $1 ]] && { r=$1; shift; }; q=$*
  has eza && p='eza -T -L2 --color=always {}' || p='ls -la --color=always {}'
  has fd && s=$(fd -HI -td . "$r" | fzf --height 60% --preview "$p" ${q:+-q "$q"}) || s=$(find "$r" -type d ! -path '*/.git/*' | fzf --height 60% --preview "$p" ${q:+-q "$q"})
  [[ -n $s ]] && cd "$s"; }
fe(){ local q=$* p f; has bat && p='bat -n --style=plain --color=always -r :500 {}' || p='head -500 {}'
  f=(${(f)$(fzf -m ${q:+-q "$q"} --preview "$p")}); [[ ${#f} -gt 0 ]] && ${EDITOR:-micro} $f; }
h(){ curl cheat.sh/${@:-cheat}; }

bindkey -e; autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^P' history-beginning-search-backward '^N' history-beginning-search-forward \
  '^R' history-incremental-pattern-search-backward '^S' history-incremental-pattern-search-forward \
  '^[[A' history-substring-search-up '^[[B' history-substring-search-down \
  '^[[H' beginning-of-line '^[[F' end-of-line '^[[3~' delete-char \
  '^[[1;5C' forward-word '^[[1;5D' backward-word '^[[Z' reverse-menu-complete '^Z' undo '^Y' redo
zmodload zsh/complist; bindkey -M menuselect '^[[Z' reverse-menu-complete
prepend-sudo(){ [[ $BUFFER != su(do|)\ * ]] && BUFFER="sudo $BUFFER" && (( CURSOR += 5 )); }
zle -N prepend-sudo; bindkey '\e\e' prepend-sudo
qc-rationalize-dot(){ [[ $LBUFFER == *.. ]] && LBUFFER+='/..' || LBUFFER+='.'; }
zle -N qc-rationalize-dot; bindkey '.' qc-rationalize-dot '\E.' self-insert-unmeta
autoload -Uz add-zsh-hook; _qc-reset-cursor(){ print -n '\E[5 q'; }; add-zsh-hook precmd _qc-reset-cursor

(( $+functions[lazyload] )) && {
  lazyload gh 'source =(smartcache 7d gh completion -s zsh)'
  lazyload docker 'source =(smartcache 7d docker completion zsh)'
  lazyload carapace 'export CARAPACE_BRIDGES="zsh,fish,bash,inshellisense"; source =(smartcache 7d carapace _carapace)'
  lazyload zellij 'eval "$(zellij setup --generate-auto-start zsh)"'
  (( $+commands[theshit] )) && lazyload shit 'eval "$(~/.cargo/bin/theshit alias shit)"'
}
(( $+functions[zsh-defer] )) && {
  zsh-defer -c '(( $+functions[smartcache] )) && smartcache 7d vivid generate molokai &>/dev/null'
  zsh-defer -c 'has gh && (( $+functions[smartcache] )) && smartcache 7d gh completion -s zsh &>/dev/null'
} || {
  (( $+commands[zellij] )) && eval "$(zellij setup --generate-auto-start zsh)"
  (( $+commands[carapace] )) && { export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'; source <(carapace _carapace); }
}

[[ -o INTERACTIVE && -t 2 ]] && (( $+commands[fastfetch] )) && fastfetch >&2
autoload -Uz zrecompile; for f in ~/.zshrc ~/.zshenv ~/.p10k.zsh; [[ -f $f && ( ! -f $f.zwc || $f -nt $f.zwc ) ]] && zrecompile -pq "$f" &>/dev/null
