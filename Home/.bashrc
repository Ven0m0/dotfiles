[[ $- != *i* ]] && return
#================================ [Helpers] ===================================
has(){ command -v -- "$1" &>/dev/null; }
ifsource(){ [[ -r "${1/#\~\//${HOME}/}" ]] && . "${1/#\~\//${HOME}/}"; }
exportif(){ [[ -e "$2" ]] && export "${1}=${2}"; }
prepend_var(){ local -n p="$1"; [[ -d "$2" && ":$p:" != *":$2:"* ]] && p="$2${p:+:$p}"; }
prependpath(){ prepend_var PATH "$1"; }

#============================ [Core Configuration] ============================
# --- History
HISTCONTROL="erasedups:ignoreboth" HISTSIZE=10000 HISTFILESIZE=10000
HISTIGNORE="&:bg:fg:clear:cls:exit:history:?"
HISTTIMEFORMAT="%F %T " HISTFILE="${HOME}/.bash_history"

# --- Shell Behavior
shopt -s autocd cdable_vars cdspell checkwinsize dirspell globstar nullglob hostcomplete no_empty_cmd_completion histappend cmdhist
bind -r '\C-s'
stty -ixon -ixoff -ixany
export IGNOREEOF=10

# --- Environment
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config} XDG_CACHE_HOME=${XDG_CACHE_HOME:-${HOME}/.cache}
XDG_DATA_HOME=${XDG_DATA_HOME:-${HOME}/.local/share} XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME}/.local/state}
XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$UID} XDG_PROJECTS_DIR=${XDG_PROJECTS_DIR:-${HOME}/Projects}
export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_RUNTIME_DIR XDG_PROJECTS_DIR

has micro && export EDITOR='micro' MICRO_TRUECOLOR=1
export GIT_EDITOR="$EDITOR" SUDO_EDITOR="$EDITOR"
if has code; then
  export VISUAL="code -w"
elif has vscode; then
  export VISUAL="vscode -w"
elif has kate; then
  export VISUAL="kate"
else
  export VISUAL="$EDITOR"
fi
if has firefox; then
  export BROWSER='firefox'
else
  export BROWSER='xdg-open'
fi
if has sudo-rs; then
  export SUDO=sudo-rs
elif has doas; then
  export SUDO=doas
else
  export SUDO=sudo
fi
export LANG='C.UTF-8' LC_COLLATE='C' TZ='Europe/Berlin' TIME_STYLE='+%d-%m %H:%M'
export GPG_TTY="$(tty)"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export NODE_OPTIONS='--max-old-space-size=4096'

# Paging
if has bat; then
  export PAGER='bat -p'
fi
export LESSQUIET=1 BATPIPE=color CLICOLOR=1 SYSTEMD_COLORS=1 PYTHON_COLORS=1

#=============================== [Sourcing] =================================
dotfiles=(/etc/bashrc
  "${HOME}/.bash_aliases"
  "${HOME}/.bash_functions"
  "${HOME}/.bash_completions"
  /usr/share/doc/pkgfile/command-not-found.bash
  "${XDG_CONFIG_HOME}/bash/init.bash"
)
for p in "${dotfiles[@]}"; do ifsource "$p"; done; unset p

ifsource /usr/share/bash-preexec/bash-preexec.sh
[[ -r "/usr/share/blesh/ble.sh" ]] && . -- "/usr/share/blesh/ble.sh" --attach=none

#================================ [PATH Setup] ================================
prependpath "$HOME/.local/bin"
prependpath "$HOME/.bin"
prependpath "$HOME/bin"
prependpath "$HOME/.cargo/bin"
exportif BUN_INSTALL "$HOME/.bun"
prependpath "$BUN_INSTALL/bin"

#=============================== [Tooling Init] ===============================
# --- Language & Runtimes
if has mise; then
  eval "$(mise activate -yq bash)"
  alias mx="mise x --"
fi
ifsource "${HOME}/.sdkman/bin/sdkman-init.sh"

if has cargo || has rustup; then
  exportif RUSTUP_HOME "${HOME}/.rustup"
  exportif CARGO_HOME "${HOME}/.cargo"
  ifsource "${CARGO_HOME:-${HOME}/.cargo}/env"
  export CARGO_HTTP_MULTIPLEXING=true CARGO_NET_GIT_FETCH_WITH_CLI=true RUST_LOG=off BINSTALL_DISABLE_TELEMETRY=true
fi

# --- Shell Enhancement Tools
has gh && eval "$(gh completion -s bash)"
if has zoxide; then
  export _ZO_EXCLUDE_DIRS="$HOME" _ZO_FZF_OPTS='--cycle --inline-info --no-multi'
  eval "$(zoxide init --cmd cd bash)"
fi
if has zellij; then
  eval "$(zellij setup --generate-auto-start bash)"
  ifsource "$HOME/.config/bash/completions/zellij.bash"
fi
has fdf && eval "$(fdf --generate bash)"

if has eza; then
  export EZA_ICONS_AUTO=1
  alias ls='eza --group-directories-first --no-git'
  alias la='eza -al --group-directories-first --no-git --no-time --no-user --no-permissions'
  alias ll='eza -al --group-directories-first --git-repos-no-status'
  alias tree='eza -T --color=always --no-git'
fi

# --- Graphics & Session
if [[ "${XDG_SESSION_TYPE-}" == "wayland" ]]; then
  export GDK_BACKEND=wayland QT_QPA_PLATFORM=wayland SDL_VIDEODRIVER=wayland
  export MOZ_ENABLE_WAYLAND=1 MOZ_DBUS_REMOTE=1 MOZ_ENABLE_XINPUT2=1 MOZ_DISABLE_RDD_SANDBOX=1
  export QT_WAYLAND_DISABLE_WINDOWDECORATION=1 QT_ENABLE_HIGHDPI_SCALING=1 QT_AUTO_SCREEN_SCALE_FACTOR=1 GTK_USE_PORTAL=1
  export _JAVA_AWT_WM_NONREPARENTING=1 _NROFF_U=1
fi
has dbus-launch && export "$(dbus-launch 2>/dev/null)"
if has ghostty; then
  [[ "$TERM" == "xterm-ghostty" ]] && ifsource "${GHOSTTY_RESOURCES_DIR:-}/shell-integration/bash/ghostty.bash"
  export TERMINAL="ghostty +ssh-cache --wait-after-command"
fi

# --- Tuning
export GLIBC_TUNABLES="glibc.malloc.hugetlb=1" MALLOC_CONF="metadata_thp:auto,tcache:true,background_thread:true,percpu_arena:percpu"; 
export _RJEM_MALLOC_CONF="$MALLOC_CONF" MIMALLOC_ALLOW_LARGE_OS_PAGES=1 MIMALLOC_VERBOSE=0 MIMALLOC_SHOW_ERRORS=0 PYTHONOPTIMIZE=2 

#================================ [Functions] =================================
y(){
  local tmp_file cwd
  tmp_file="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp_file"
  if IFS= read -r -d '' cwd < "$tmp_file" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    cd -- "$cwd" || exit
  fi
  rm -f -- "$tmp_file"
}
gclone(){
  if has gix; then
    LC_ALL=C gix clone --depth 1 --no-tags -c protocol.version=2 -c http.sslVersion=tlsv1.3 -c http.version=HTTP/2 "$@"
  else
    LC_ALL=C git clone --depth 1 --no-tags --filter=blob:none -c protocol.version=2 -c http.sslVersion=tlsv1.3 -c http.version=HTTP/2 "$@"
  fi
}
gpush(){ LC_ALL=C git add -A && LC_ALL=C git commit -m "${1:-Update}" && LC_ALL=C git push -q --recurse-submodules=on-demand; }

#================================ [Aliases] ===================================
alias sudo='sudo ' sudo-rs='sudo-rs ' doas='doas '
alias e="$EDITOR"
alias c='clear'
alias q='exit'
alias ..='cd ..'
alias ...='cd ../..'
alias bd='cd "$OLDPWD"'
alias ls='eza -F --color=auto --group-directories-first --icons=auto'
alias la='eza -AF --color=auto --group-directories-first --icons=auto'
alias ll='eza -AlF --color=auto --group-directories-first --icons=auto --git --header'
alias lt='eza -AlT -L 2 --color=auto --group-directories-first --icons=auto'
alias grep='grep --color=auto'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv --preserve-root'
alias ssh='TERM=xterm-256color command ssh'
has wget2 && alias wget='wget2'
has btm && alias top='btm'
pip(){ if has uv && [[ " install uninstall list show freeze check " =~ " $1 " ]]; then uv pip "$@"; else command python -m pip "$@"; fi; }

#============================== [FZF & Prompt] ================================
configure_fzf(){
  local find_cmd='fd -tf --hidden --no-ignore --exclude .git'
  export FZF_DEFAULT_COMMAND="$find_cmd"
  export FZF_CTRL_T_COMMAND="$find_cmd"
  local base_opts='--height=~90% --layout=reverse-list --border --cycle --preview-window=wrap --inline-info -0 -1'
  base_opts+='--marker=*'
  export FZF_DEFAULT_OPTS="$base_opts"
  export FZF_CTRL_T_OPTS="$base_opts --preview 'bat -p --color=always -r :250 {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
  export FZF_CTRL_R_OPTS="$base_opts --preview 'echo {}' --preview-window=down:3:wrap --bind '?:toggle-preview'"
  export FZF_ALT_C_OPTS="$base_opts --walker-skip='.git,node_modules' --preview 'eza -T {}'"
  ifsource /usr/share/fzf/key-bindings.bash
  ifsource /usr/share/fzf/completion.bash
}
has fzf && has bat && has eza && configure_fzf

# --- Prompt
configure_prompt(){
  PROMPT_DIRTRIM=3
  PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
  if has starship; then
    eval "$(starship init bash)"; return
  fi
  local c_red='\[\e[31m\]' c_grn='\[\e[32m\]' c_blu='\[\e[34m\]' c_cyn='\[\e[36m\]' c_def='\[\e[0m\]'
  local user_color="$c_blu"
  [[ $EUID -eq 0 ]] && user_color="$c_red"
  local exit_status='$(ret=$?; if [[ $ret -eq 0 ]]; then echo -e "$c_grn:)$c_def"; else echo -e "$c_red$ret$c_def"; fi)'
  PS1="[$user_color\u@\h$c_def:$c_cyn\w$c_def] $exit_status > "
  PS2="> "
  export COLUMNS
}
configure_prompt

#============================== [Finalization] ================================
# --- Asynchronous Path Deduplication
(
  new_path=""; declare -A seen; IFS=:
  for p in $PATH; do
    [[ -z "$p" || -n "${seen[$p]}" ]] && continue
    seen[$p]=1; new_path="${new_path:+$new_path:}$p"
  done
  [[ -n "$new_path" ]] && export PATH="$new_path"
) &>/dev/null &

# --- Welcome Fetch
if [[ $SHLVL -eq 1 && -z "${DISPLAY}" ]]; then
  fetch_cmd=""
  if has hyfetch && has fastfetch; then
    fetch_cmd='hyfetch -b fastfetch -p transgender'
  elif has fastfetch; then
    fetch_cmd='fastfetch'
  fi
  [[ -n "$fetch_cmd" ]] && eval "$fetch_cmd"
fi
unset -f ifsource exportif prepend_var prependpath configure_fzf configure_prompt
[[ ! ${BLE_VERSION-} ]] || ble-attach
