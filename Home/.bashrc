[[ $- != *i* ]] && return

#============ Helpers ============
has(){ command -v -- "$1" &>/dev/null; }
ifsource(){ [[ -r "${1/#\~\//${HOME}/}" ]] && . "${1/#\~\//${HOME}/}"; }
prependpath(){ [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && PATH="$1${PATH:+:$PATH}"; }
bname(){ local t="${1%/}"; printf '%s\n' "${t##*/}"; }
dname(){ local p="${1%/}"; [[ "$p" == "${p#*/}" ]] && p="."; printf '%s\n' "${p%/*}"; }
match(){ [[ "$1" =~ $2 ]]; }

#============ Sourcing (Initial) ============
dot=( /etc/bashrc "$HOME"/.{bash_aliases,bash_functions,bash_completions,bash.d/cht.sh,config/bash/cht.sh} /usr/share/doc/pkgfile/command-not-found.bash )
for p in "${dot[@]}"; do ifsource "$p"; done

if [[ -f /usr/lib/librl_custom_complete.so ]]; then export INPUTRC=$HOME/.inputrcf; else export INPUTRC=$HOME/.inputrc; fi
ifsource /usr/share/bash-preexec/bash-preexec.sh
has mise && eval "$(mise activate -yq bash)"

#============ History & Prompt ============
HISTSIZE=1000 HISTFILESIZE=2000
HISTCONTROL="erasedups:ignoreboth:autoshare"
HISTIGNORE="&:bg:fg:clear:cls:exit:history:bash:fish:?:??"
export HISTTIMEFORMAT="%F %T " IGNOREEOF=100 HISTFILE=$HOME/.bash_history
PROMPT_DIRTRIM=2 PROMPT_COMMAND="history -a"

#============ Core Shell Behavior ============
CDPATH=.:$HOME:/
ulimit -c 0 # disable core dumps
shopt -s histappend cmdhist checkwinsize dirspell cdable_vars cdspell extglob autocd hostcomplete no_empty_cmd_completion globstar nullglob
set -o noclobber; set +H # disable overwrite and history expansion
bind -r '\C-s'; stty -ixon -ixoff -ixany

#============ Environment Variables ============
# Path
prependpath "$HOME/.root/usr/bin"
prependpath "$HOME/.local/bin"
prependpath "$HOME/.bin"
prependpath "$HOME/bin"
export BUN_INSTALL=$HOME/.bun
prependpath "${BUN_INSTALL:-$HOME/.bun}/bin"

# General
export SUDO=doas BROWSER=firefox TERMINAL=ghostty
if has micro; then EDITOR=micro; else EDITOR=nano; fi
export VISUAL=$EDITOR VIEWER=$EDITOR GIT_EDITOR=$EDITOR SYSTEMD_EDITOR=$EDITOR FCEDIT=$EDITOR SUDO_EDITOR=$EDITOR MICRO_TRUECOLOR=1

# Locale
export LANG=C.UTF-8 LC_COLLATE=C LC_CTYPE=C.UTF-8 LC_MEASUREMENT=C
export TZ='Europe/Berlin' TIME_STYLE='+%d-%m %H:%M'

# System
export jobs=$(nproc) SHELL=${BASH:-$(command -v bash 2>/dev/null)}
has dbus-launch && export "$(dbus-launch 2>/dev/null)"
has ibus && export GTK_IM_MODULE=ibus XMODIFIERS=@im=ibus QT_IM_MODULE=ibus

# Allocators
MALLOC_CONF="metadata_thp:auto,tcache:true,background_thread:true,percpu_arena:percpu,trust_madvise:true,abort_conf:true"
export MALLOC_CONF _RJEM_MALLOC_CONF="$MALLOC_CONF"
export MIMALLOC_VERBOSE=0 MIMALLOC_SHOW_ERRORS=0 MIMALLOC_SHOW_STATS=0 MIMALLOC_ALLOW_LARGE_OS_PAGES=1 MIMALLOC_ARENA_EAGER_COMMIT=1

# Pagers (Less/Bat/Delta)
: "${LESS_TERMCAP_mb:=$'\e[1;32m'}" "${LESS_TERMCAP_md:=$'\e[1;32m'}" "${LESS_TERMCAP_me:=$'\e[0m'}" \
  "${LESS_TERMCAP_se:=$'\e[0m'}" "${LESS_TERMCAP_so:=$'\e[01;33m'}" "${LESS_TERMCAP_ue:=$'\e[0m'}"
export "${!LESS_TERMCAP@}"
export LESSHISTFILE=- LESSCHARSET=utf-8
export LESS='-RFKQiqs --use-color -Dd+r$Du+b$ --no-histdups --no-edit-warn --mouse --wheel-lines=3'
if has bat; then
  export PAGER='bat -ps --squeeze-limit 0' BAT_PAGER="$LESS"
  export BAT_STYLE=auto BATDIFF_USE_DELTA=true BATPIPE=color
  if has batman; then eval "$(batman --export-env)"; else export MANPAGER="sh -c 'col -bx | bat -lman -p -s --squeeze-limit 0'" MANROFFOPT="-c"; fi
  has batpipe && eval "$(SHELL=bash batpipe)"
fi
export GIT_PAGER="${GIT_PAGER:-delta}"

# Colors & XDG
if has vivid; then export LS_COLORS=$(vivid generate molokai); elif has dircolors; then eval "$(dircolors -b)"; fi
: "${CLICOLOR:=$(tput colors)}"; export CLICOLOR SYSTEMD_COLORS=1 FIGNORE=argo.lock
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config} XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share} XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$UID} XDG_PROJECTS_DIR=${XDG_PROJECTS_DIR:-$HOME/Projects}
: CURL_HOME=$HOME; : WGETRC=$HOME/.wgetrc; export GPG_TTY=$(tty)

# Toolchains (Rust, Python, Go, Node)
if has cargo; then export CARGO_HOME=$HOME/.cargo RUSTUP_HOME=$HOME/.rustup; ifsource "$CARGO_HOME/env"; prependpath "$CARGO_HOME/bin"; fi
export PYTHONOPTIMIZE=2 PYTHONUTF8=1 PYTHONNODEBUGRANGES=1 PYTHON_JIT=1 PYENV_VIRTUALENV_DISABLE_PROMPT=1 PYTHONSTARTUP=$HOME/.pythonstartup PYTHON_COLORS=1
if has uv; then export UV_NO_VERIFY_HASHES=1 UV_SYSTEM_PYTHON=1 UV_BREAK_SYSTEM_PACKAGES=0 UV_TORCH_BACKEND=auto UV_FORK_STRATEGY=fewest UV_RESOLUTION=highest UV_PRERELEASE="if-necessary-or-explicit" UV_COMPILE_BYTECODE=1 UV_LINK_MODE=hardlink; fi
export NODE_OPTIONS="--max-old-space-size=4096"
if has go; then export CGO_ENABLED=0 GOGC=200 GOMAXPROCS=$jobs GOFLAGS="-ldflags=-s -w -trimpath -modcacherw -pgo auto"; go telemetry off &>/dev/null; fi

# Misc App Env
export ZSTD_NBTHREADS=0 ELECTRON_OZONE_PLATFORM_HINT=auto _JAVA_AWT_WM_NONREPARENTING=1
export FLATPAK_FANCY_OUTPUT=1 FLATPAK_TTY_PROGRESS=0 FLATPAK_FORCE_TEXT_AUTH=1

# Graphics (Wayland/Nvidia)
if has qt6ct; then export QT_QPA_PLATFORMTHEME=qt6ct; elif has qt5ct; then export QT_QPA_PLATFORMTHEME=qt5ct; fi
if [[ ${XDG_SESSION_TYPE-} == wayland ]]; then
  export GDK_BACKEND=wayland QT_QPA_PLATFORM=wayland SDL_VIDEODRIVER=wayland CLUTTER_BACKEND=wayland GTK_USE_PORTAL=1
  export MOZ_ENABLE_WAYLAND=1 MOZ_ENABLE_XINPUT2=1 MOZ_DBUS_REMOTE=1 QT_WAYLAND_DISABLE_WINDOWDECORATION=1 QT_AUTO_SCREEN_SCALE_FACTOR=0
fi
export NVD_BACKEND=direct MOZ_DISABLE_RDD_SANDBOX=1 LIBVA_DRIVER_NAME=nvidia VDPAU_DRIVER=nvidia __GLX_VENDOR_LIBRARY_NAME=nvidia
export __GL_THREADED_OPTIMIZATIONS=1 __GL_SORT_FBCONFIGS=1 __GL_VRR_ALLOWED=1 __GL_GSYNC_ALLOWED=1 __GL_SYNC_TO_VBLANK=0
export __GL_ALLOW_FXAA_USAGE=1 __GL_ALLOW_UNOFFICIAL_PROTOCOL=1 __GL_IGNORE_GLSL_EXT_REQS=1
export __GL_SHADER_DISK_CACHE=1 __GL_SHADER_DISK_CACHE_PATH=$HOME/.cache/nvidia/GLCache

# LLM
export ANTHROPIC_MODEL="claude-sonnet-4.5" CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
export DISABLE_NON_ESSENTIAL_MODEL_CALLS=1 DISABLE_ERROR_REPORTING=1 DO_NOT_TRACK=1

#============ Fuzzy Finders ============
fuzzy_finders(){
  local FIND_CMD='find . -type f -print'
  has fd && FIND_CMD='fd -tf -gH -c always --strip-cwd-prefix'
  has rg && FIND_CMD='rg --files --no-messages'
  local FZF_PREVIEW='cat -sn {}'
  has bat && FZF_PREVIEW="bat -n --color=always --line-range=:250 {}"
  
  export FZF_DEFAULT_COMMAND="$FIND_CMD --hidden --glob '!.git'"
  export FZF_CTRL_T_COMMAND="$FIND_CMD --hidden --glob '!.git'"
  export FZF_DEFAULT_OPTS='\
    -1 -0 --cycle --border --preview-window=wrap --smart-case --marker="*" \
    --walker-skip=".git,node_modules,target,go,.cache" --inline-info --layout=reverse-list'
  export FZF_CTRL_T_OPTS="\
    -1 -0 --inline-info --preview '$FZF_PREVIEW' \
    --bind 'ctrl-/:change-preview-window(down|hidden|)'"
  export FZF_CTRL_R_OPTS='\
    -1 -0 --tiebreak=index --inline-info --no-sort --exact \
    --preview "echo {}" --preview-window=down:3:hidden:wrap --bind "?:toggle-preview"'
  export FZF_ALT_C_OPTS='\
    -1 -0 --tiebreak=index --inline-info --walker-skip=".git,node_modules,target,go" \
    --preview "tree -C {} 2>/dev/null | head -200"'
  export FZF_COMPLETION_OPTS='--border --info=inline --tiebreak=index'
  
  mkdir -p "$HOME/.config/bash/completions" &>/dev/null
  if has fzf; then
    ifsource /usr/share/fzf/key-bindings.bash
    ifsource /usr/share/fzf/completion.bash || eval "$(SHELL=bash fzf --bash)"
    ifsource /usr/share/fzf-tab-completion/bash/fzf-bash-completion.sh && bind -x '"\t": fzf_bash_completion'
  fi
}
fuzzy_finders

#============ Functions ============
runch(){ chmod +x -- "$1" && "$@" || { echo "runch: failed to run '$1'" >&2; return 1; }; }
sel(){ if [[ -d "$1" ]]; then ls "$1"; elif [[ -f "$1" ]]; then cat "$1"; else echo "sel: not found: $1" >&2; return 1; fi; }
cargo_run(){ local cmd=(cargo mommy clicker); command "${cmd[@]}" "$@"; }
sudo-cl(){ [[ -z $READLINE_LINE ]] && READLINE_LINE=$(fc -ln -1); [[ $READLINE_LINE == sudo* ]] && READLINE_LINE=${READLINE_LINE#sudo } || READLINE_LINE="sudo $READLINE_LINE"; READLINE_POINT=${#READLINE_LINE}; }
gclone(){ command git clone --filter=blob:none --depth 1 --no-tags -c protocol.version=2 -c http.sslVersion=tlsv1.3 -c http.version=HTTP/2 "$@"; }
gpush(){ command git add . && command git commit -m "${1:-Update}" && command git push; }
symbreak(){ command find -L "${1:-.}" -type l; }
hypertest(){ has hyperfine && LC_ALL=C LANG=C command hyperfine -w 25 -m 50 -i -S bash -- "$@"; }
touchf(){ command mkdir -p -- "$(dirname -- "$1")" && command touch -- "$1"; }
extract(){ for i; do local c;! [[ -r $i ]] && { echo "$0: unreadable: '$i'" >&2; continue; }; c=($(case "$i" in *.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz|zst))))) echo bsdtar xvf;; *.7z) echo 7z x;; *.Z) echo uncompress;; *.bz2) echo bunzip2;; *.exe) echo cabextract;; *.gz) echo gunzip;; *.rar) echo unrar x;; *.xz) echo unxz;; *.zip) echo unzip;; *.zst) echo unzstd;; *) echo "$0: unknown ext: '$i'" >&2; continue;; esac)); command "${c[@]}" "$i"; done; }
cht(){ curl -s "cht.sh/${*// /}" || curl -s "cht.sh/:help"; }
curlsh(){ command curl -sfSL "$*" | bash; }
adb-connect(){ local IP=${1:-$(adb shell ip route | awk '{print $9}')} PORT=${2:-5555}; adb tcpip "$PORT" &>/dev/null; adb connect "${IP}:${PORT}"; }

#============ Tool Wrappers ============
git(){ if has gix && [[ " clone fetch pull init status diff log rev-parse remote config " =~ " $1 " ]]; then gix "$@"; else command git "$@"; fi; }
curl(){ if has aria2c && [[ "$*" =~ https?://|ftp:// ]]; then local -a args=() out_file=""; while (($#)); do case "$1" in -o|--output) out_file="$2"; shift 2;; -L|-s|-S|-f|--compressed) shift;; *) args+=("$1"); shift;; esac; done; local -a flags=(-x16 -s16 -k1M -j16 --file-allocation=none --summary-interval=0); if [[ -n $out_file ]]; then aria2c "${flags[@]}" -d "$(dirname "$out_file")" -o "$(basename "$out_file")" "${args[@]}"; else aria2c "${flags[@]}" "${args[@]}"; fi; else command curl "$@"; fi; }
pip(){ if has uv && [[ " install uninstall list show freeze check " =~ " $1 " ]]; then uv pip "$@"; else python -m pip "$@"; fi; }
ssh(){ [[ $TERM == kitty ]] && kitty +kitten ssh "$@" || TERM=xterm-256color command ssh "$@"; }

#============ Aliases ============
alias sudo='sudo ' sudo-rs='sudo-rs ' doas='doas '
alias e="$EDITOR" se="sudo $EDITOR" r='\bat -p' mi=micro nano='nano -/'
alias c='clear' cls='clear' q='exit' h='history'
alias redo='sudo $(fc -ln -1)' ptch='patch -p1 <'
alias bash='SHELL=$(command -v bash) bash' zsh='SHELL=$(command -v zsh) zsh' fish='SHELL=$(command -v fish) fish'
alias cleansh='curlsh https://raw.githubusercontent.com/Ven0m0/Linux-OS/main/Cachyos/Clean.sh'
alias updatesh='curlsh https://raw.githubusercontent.com/Ven0m0/Linux-OS/main/Cachyos/Updates.sh'
if has eza; then
  alias ls='eza -F --color=auto --group-directories-first --icons=auto'
  alias la='eza -AF --color=auto --group-directories-first --icons=auto'
  alias ll='eza -AlF --color=auto --group-directories-first --icons=auto --no-time --no-git --smart-group --no-user --no-permissions'
  alias lt='eza -ATF -L 3 --color=auto --group-directories-first --icons=auto'
else
  alias ls='ls --color=auto --group-directories-first -BhLC'
  alias la='ls --color=auto --group-directories-first -ABhLgGoC'
  alias ll='ls --color=auto --group-directories-first -ABhLgGo'
fi
alias which='command -v '
alias grep='grep --color=auto' fgrep='fgrep --color=auto' egrep='grep -E --color=auto'
alias cp='cp -iv' mv='mv -iv' ln='ln -ivsn' rm='rm -Iv --preserve-root'
alias find='find -O3' psl="ps aux | grep -i" topcpu="ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
has btm && alias top=btm btop=btm
alias ..='cd ..' ...='cd ../..' ....='cd ../../..' bd='cd "$OLDPWD"'
alias big="expac -H M '%m\t%n' | sort -hr | nl | head -n 50"
alias gitpkg='pacman -Qq | grep -ci -- "-git"'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'
alias openports='ss -tuna'
alias pip='python -m pip' py='python'
alias speedt='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'

#============ Completions & Bindings ============
ifsource /usr/share/bash-completion/bash_completion || ifsource /etc/bash_completion
for c in sudo doas pkexec git command systemctl curl wget pacman paru; do complete -o default -o bashdefault -F _completion_loader "$c"; done
complete -A hostname ssh scp ping dig host nslookup
complete -A user su login
complete -A directory cd pushd rmdir
complete -A file less cat head tail cp mv rm tar unzip unrar 7z

run-help(){ help "$READLINE_LINE" 2>/dev/null || man "$READLINE_LINE"; }
bind -m vi-insert -x '"\eh": run-help'
bind -m emacs -x '"\eh": run-help'
bind -x '"\e\e": sudo-cl'

bind 'set completion-query-items 250' 'set page-completions off' 'set show-all-if-ambiguous on'
bind 'set show-all-if-unmodified on' 'set menu-complete-display-prefix on' 'set completion-ignore-case on'
bind 'set completion-map-case on' 'set mark-directories on' 'set mark-symlinked-directories on'
bind 'set bell-style none' 'set skip-completed-text on' 'set colored-stats on'
bind 'set colored-completion-prefix on' 'set expand-tilde on'
bind '"\C-o": kill-whole-line' '"\e[1;5D": backward-word' '"\e[1;5C": forward-word'

#============ Finalization ============
# Prompt
configure_prompt(){
  has starship && { eval "$(starship init bash)"; return; }
  local MGN='\[\e[35m\]' BLU='\[\e[34m\]' YLW='\[\e[33m\]' BLD='\[\e[1m\]' UND='\[\e[4m\]' GRN='\[\e[32m\]'
  local CYN='\[\e[36m\]' DEF='\[\e[0m\]' RED='\[\e[31m\]' PNK='\[\e[38;5;205m\]' USERN HOSTL
  USERN="${MGN}\u${DEF}"; [[ $EUID -eq 0 ]] && USERN="${RED}\u${DEF}"
  HOSTL="${BLU}\h${DEF}"; [[ -n $SSH_CONNECTION ]] && HOSTL="${YLW}\h${DEF}"
  exstat(){ [[ $? == 0 ]] && printf '%s:)${DEF}' "$GRN" || printf '%sD:${DEF}' "$RED"; }
  PS1="[${USERN}@${HOSTL}${UND}|${DEF}${CYN}\w${DEF}]>${PNK}\A${DEF}|\$(exstat) ${BLD}\$${DEF} "
  PS2='> '
  has mommy && (( ${stealth:-0} == 1 )) && [[ ${PROMPT_COMMAND-} != *mommy* ]] && PROMPT_COMMAND="mommy -1 -s \$?; $PROMPT_COMMAND"
}
(configure_prompt &>/dev/null &)

# Path Deduplication
dedupe_path(){ local IFS=: p new_path; declare -A seen; for p in $PATH; do [[ -n $p && -z ${seen[$p]} ]] && seen[$p]=1 && new_path="${new_path:+$new_path:}$p"; done; [[ -n $new_path ]] && export PATH="$new_path"; }
(dedupe_path &>/dev/null &)

# Fetch on Login
if [[ $SHLVL -eq 1 && -z ${BASH_SUBSHELL-} ]]; then
  fetch_cmd=""
  if (( ${stealth:-0} != 1 )); then
    if has hyfetch; then fetch_cmd='hyfetch -b fastfetch -m rgb -p transgender'
    elif has fastfetch; then fetch_cmd='fastfetch --ds-force-drm --thread --detect-version false'
    elif has vnfetch; then fetch_cmd='vnfetch'
    fi
  fi
  [[ -n $fetch_cmd ]] && ($fetch_cmd &>/dev/null &)
fi

# Sourcing (Final)
ifsource "$HOME/.sdkman/bin/sdkman-init.sh" && export SDKMAN_DIR="$HOME/.sdkman"
if has zoxide; then
  export _ZO_DOCTOR=0 _ZO_ECHO=0 _ZO_EXCLUDE_DIRS="$HOME:.cache:go"
  export _ZO_FZF_OPTS="--cycle -0 -1 --inline-info --no-multi --no-sort --preview 'eza -1 --color=always {2..}'"
  eval "$(zoxide init bash)"
fi
has intelli-shell && eval "$(intelli-shell init bash)"
if has zellij; then eval "$(zellij setup --generate-auto-start bash)"; ifsource ~/.config/bash/completions/zellij.bash; fi
has gh && eval "$(gh completion -s bash)"
[[ $TERM == xterm-ghostty ]] && ifsource "${GHOSTTY_RESOURCES_DIR:-}/shell-integration/bash/ghostty.bash"
has wikiman && ifsource /usr/share/wikiman/widgets/widget.bash

unset -f ifsource prependpath configure_prompt dedupe_path fuzzy_finders
