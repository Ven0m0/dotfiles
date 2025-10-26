[[ $- != *i* ]] && return
#============ Helpers ============
# Check for command
has(){ command -v -- "$1" &>/dev/null; }
#hconv(){ printf '%s\n' "${1/#\~\//${HOME}/}"; }
# Safely source file if it exists ( ~ -> $HOME )
ifsource(){ [[ -r "${1/#\~\//${HOME}/}" ]] && . "${1/#\~\//${HOME}/}" 2>/dev/null; return $?; }
# Safely prepend only if not already in PATH ( ~ -> $HOME )
prependpath(){ [[ -d $1 ]] && [[ :$PATH: != *":$1:"* ]] && PATH="$1${PATH:+:$PATH}"; export PATH; }
bname(){ local t=${1%${1##*[!/]}}; t=${t##*/}; [[ $2 && $t == *"$2" ]] && t=${t%$2}; printf '%s\n' "${t:-/}"; }
dname(){ local p=${1:-.}; [[ $p != *[!/]* ]] && { printf '/\n'; return; }; p=${p%${p##*[!/]}}; [[ $p != */* ]] && { printf '.\n'; return; }; p=${p%/*}; p=${p%${p##*[!/]}}; printf '%s\n' "${p:-/}"; }
match(){ printf '%s\n' "$1" | grep -E -o "$2" &>/dev/null || return 1; }
#============ Sourcing ============
# wiki.archlinux.org/title/Bash#Command_not_found
dot=(/etc/bashrc
  "$HOME"/.{bash_aliases,bash_functions,bash_completions,bash.d/cht.sh,config/bash/cht.sh}
  /usr/share/doc/pkgfile/command-not-found.bash
)
for p in "${dot[@]}"; do [[ -r "$p" ]] && . "$p"; done

# completions
ifsource "/usr/share/bash-completion/bash_completion" || ifsource "/etc/bash_completion"

# github.com/kazhala/dotbare
ifsource "${HOME}/.dotbare/dotbare.plugin.bash" &&  alias dotbare="${HOME}/.dotbare/dotbare"

# Fzf-tabs for readline
if [[ -f "/usr/lib/librl_custom_complete.so" ]]; then
  export INPUTRC="${HOME}/.inputrcf"
else
  export INPUTRC="${HOME}/.inputrc"
fi

ifsource /usr/share/bash-preexec/bash-preexec.sh

has mise && eval "$(mise activate --shims bash)"

#============ History / Prompt basics ============
# PS1='[\u@\h|\w] \$' # bash-prompt-generator.org
# https://github.com/glabka/configs/blob/master/home/.bashrc
HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL="erasedups:ignoreboth:autoshare"
HISTIGNORE="&:[bf]g:clear:cls:exit:history:bash:fish:?:??"
export HISTTIMEFORMAT="%F %T " IGNOREEOF=100
HISTFILE="${HOME}/.bash_history"
PROMPT_DIRTRIM=2 
PROMPT_COMMAND="history -a"
#============ Core ============
CDPATH=".:${HOME}:/"
ulimit -c 0 # disable core dumps
export FIGNORE="argo.lock"
shopt -s histappend cmdhist checkwinsize dirspell cdable_vars cdspell extglob \
         autocd cdable_vars hostcomplete no_empty_cmd_completion globstar nullglob
# Disable Ctrl-s, Ctrl-q
set -o noclobber
bind -r '\C-s'
stty -ixon -ixoff -ixany
set +H # disable history expansion that breaks some scripts
# set -o vi; export VIMINIT='set encoding=utf-8'
#============ Env ============
prependpath "${HOME}/.root/usr/bin"
prependpath "${HOME}/.local/bin"
prependpath "${HOME}/.bin"
prependpath "${HOME}/bin"

# General
SUDO=doas
BROWSER=firefox
TERMINAL=ghostty

# Editor selection: prefer micro, fallback to nano
if has micro; then EDITOR=micro; else EDITOR=nano; fi
export MICRO_TRUECOLOR=1 VISUAL="$EDITOR" VIEWER="$EDITOR" GIT_EDITOR="$EDITOR" SYSTEMD_EDITOR="$EDITOR" FCEDIT="$EDITOR" SUDO_EDITOR="$EDITOR"
# https://wiki.archlinux.org/title/Locale
export LANG=C.UTF-8 LC_COLLATE=C LC_CTYPE=C.UTF-8
export LC_MEASUREMENT=C TZ='Europe/Berlin' TIME_STYLE='+%d-%m %H:%M'
unset LC_ALL POSIXLY_CORRECT
jobs="$(nproc)" SHELL="${BASH:-$(command -v bash 2>/dev/null)}"
has dbus-launch && export "$(dbus-launch 2>/dev/null)"

has ibus && export GTK_IM_MODULE=ibus XMODIFIERS=@im=ibus QT_IM_MODULE=ibus

# Mimalloc & Jemalloc
# https://github.com/microsoft/mimalloc/blob/main/docs/environment.html
MALLOC_CONF="metadata_thp:auto,tcache:true,background_thread:true,percpu_arena:percpu"
export MALLOC_CONF _RJEM_MALLOC_CONF="$MALLOC_CONF" MIMALLOC_VERBOSE=0 MIMALLOC_SHOW_ERRORS=0 MIMALLOC_SHOW_STATS=0 MIMALLOC_ALLOW_LARGE_OS_PAGES=1 MIMALLOC_PURGE_DELAY=25 MIMALLOC_ARENA_EAGER_COMMIT=2

: "${LESS:=}"
: "${LESS_TERMCAP_mb:=$'\e[1;32m'}" "${LESS_TERMCAP_md:=$'\e[1;32m'}" "${LESS_TERMCAP_me:=$'\e[0m'}" "${LESS_TERMCAP_se:=$'\e[0m'}" "${LESS_TERMCAP_so:=$'\e[01;33m'}" "${LESS_TERMCAP_ue:=$'\e[0m'}" "${LESS_TERMCAP_us:=$'\e[1;4;31m'}"
export "${!LESS_TERMCAP@}"
export LESSHISTFILE=- LESSCHARSET=utf-8 LESS='less -RFQs --use-color --no-histdups --mouse --wheel-lines=2'

# Delta / bat integration
has delta && export GIT_PAGER=delta
if has bat; then
  export PAGER='bat -ps --squeeze-limit 0' BAT_PAGER='less -RFQs --use-color --no-histdups --mouse --wheel-lines=2'
  export LESSCHARSET='utf-8' LESSHISTFILE=-
  
  export BAT_STYLE=auto LESSQUIET=1 BATDIFF_USE_DELTA=true BATPIPE=color
  alias cat='\bat -pp -s --squeeze-limit 0'
  unalias bat
  has prettybat && alias bat='prettybat'
  if has batman; then
    eval "$(batman --export-env)"
  else
    export MANPAGER="sh -c 'col -bx | bat -lman -p -s --squeeze-limit 0'" MANROFFOPT="-c"
  fi
  has batpipe && eval "$(SHELL=bash batpipe)"
else
  alias cat='cat -sn'
  export PAGER="${PAGER:-less}"
fi
export GIT_PAGER="${GIT_PAGER:-$PAGER}"

# Konsole manpages
export _NROFF_U=1

if has vivid; then export LS_COLORS="$(vivid generate molokai)"; elif has dircolors; then eval "$(dircolors -b)" &>/dev/null; fi
: "${CLICOLOR:=$(tput colors)}"
export CLICOLOR SYSTEMD_COLORS=1

# XDG + misc
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:=${HOME}/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:=${HOME}/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:=${HOME}/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:=${HOME}/.cache}"

: CURL_HOME="$HOME"
: WGETRC="${HOME}/.wgetrc"
export GPG_TTY="$(tty)"

if has cargo; then
  export CARGO_HOME="${HOME}/.cargo" RUSTUP_HOME="${HOME}/.rustup"
  ifsource "$HOME/.cargo/env"
  prependpath "${CARGO_HOME}/bin"
  cargo_run(){
    local found=0 cmd=(cargo) b bins=(gg mommy clicker)
    for b in "${bins[@]}"; do command -v "cargo-${b}" &>/dev/null && { cmd+=("$b"); found=1; }; done
    (( found )) && "${cmd[@]}" "$@" || cargo "$@"
  }
  alias cargo="cargo_run"
else
  unalias cargo
fi
export PYTHONOPTIMIZE=2 PYTHONUTF8=1 PYTHONNODEBUGRANGES=1 PYTHON_JIT=1 PYENV_VIRTUALENV_DISABLE_PROMPT=1 PYTHONSTARTUP="{$HOME}/.pythonstartup" PYTHON_COLORS=1
unset PYTHONDONTWRITEBYTECODE

if has uv; then
  export UV_NO_VERIFY_HASHES=1 UV_SYSTEM_PYTHON=1 UV_BREAK_SYSTEM_PACKAGES=0 UV_TORCH_BACKEND=auto UV_FORK_STRATEGY=fewest \
    UV_RESOLUTION=highest UV_PRERELEASE="if-necessary-or-explicit" UV_COMPILE_BYTECODE=1 UV_LINK_MODE=hardlink
fi

export NODE_OPTIONS="--max-old-space-size=4096"

# GOGC=100 #(needs testing)
if has go; then
  export CGO_ENABLED=0 GOGC=200 GOMAXPROCS="$jobs" GOFLAGS="-ldflags=-s -w -trimpath -modcacherw -pgo auto"
  go telemetry off; go clean -cache -modcache; unset GODEBUG
fi
export ZSTD_NBTHREADS=0 ELECTRON_OZONE_PLATFORM_HINT=auto _JAVA_AWT_WM_NONREPARENTING=1
export FLATPAK_FANCY_OUTPUT=1 FLATPAK_TTY_PROGRESS=0 FLATPAK_FORCE_TEXT_AUTH=1
# Wayland
if has qt6ct; then
  export QT_QPA_PLATFORMTHEME=qt6ct
elif has qt5ct; then
  export QT_QPA_PLATFORMTHEME=qt5ct
fi
if [[ ${XDG_SESSION_TYPE:-} == "wayland" ]]; then
  export GDK_BACKEND=wayland QT_QPA_PLATFORM=wayland SDL_VIDEODRIVER=wayland CLUTTER_BACKEND=wayland GTK_USE_PORTAL=1 \
    MOZ_ENABLE_WAYLAND=1 MOZ_ENABLE_XINPUT2=1 MOZ_DBUS_REMOTE=1 QT_WAYLAND_DISABLE_WINDOWDECORATION=1 QT_AUTO_SCREEN_SCALE_FACTOR=0
fi
export NVD_BACKEND=direct MOZ_DISABLE_RDD_SANDBOX=1 \
  LIBVA_DRIVER_NAME=nvidia VDPAU_DRIVER=nvidia __GLX_VENDOR_LIBRARY_NAME=nvidia \
  __GL_THREADED_OPTIMIZATIONS=1 __GL_SORT_FBCONFIGS=1 \
  #__GL_SHARPEN_ENABLE=1 __GL_SHARPEN_IGNORE_FILM_GRAIN=1 \
  __GL_VRR_ALLOWED=1 __GL_GSYNC_ALLOWED=1 __GL_SYNC_TO_VBLANK=0 \
  __GL_ALLOW_FXAA_USAGE=1 #__GL_ConformantBlitFramebufferScissor=1 \
  __GL_ALLOW_UNOFFICIAL_PROTOCOL=1 __GL_IGNORE_GLSL_EXT_REQS=1 \
  __GL_SHADER_DISK_CACHE=1 __GL_SHADER_DISK_CACHE_PATH="${HOME}/.cache/nvidia/GLCache"
#============ Fuzzy finders ============
fuzzy_finders(){
  local FIND_CMD SHELL=bash
  if command -v fd &>/dev/null; then FIND_CMD='fd -tf -gH -c always -strip-cwd-prefix -E ".git" -E "go/"'
  elif command -v fdfind &>/dev/null; then FIND_CMD='fdfind -tf -gH -c always -strip-cwd-prefix -E ".git" -E "go/"'
  elif command -v rg &>/dev/null; then FIND_CMD='rg -S. --no-require-git --no-messages --no-ignore-messages --files --glob "!.git"'
  elif command -v ug &>/dev/null; then FIND_CMD='ug -rlsjU. --index ""'
  else FIND_CMD='find -O3 . \( -path "./.git" -o -path "./go" \) -prune -o -type f -print'
  fi
  if command -v bat &>/dev/null; then 
    FZF_CTRL_T_OPTS="-1 -0 --inline-info --walker-skip=".git,node_modules,target,go" --preview 'bat -n --color=always --line-range=:250 {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
  else
    FZF_CTRL_T_OPTS="-1 -0 --inline-info --walker-skip=".git,node_modules,target,go" --preview 'cat -sn {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
  fi
  declare -x FZF_DEFAULT_COMMAND="$FIND_CMD" FZF_CTRL_T_COMMAND="$FIND_CMD" FZF_CTRL_T_OPTS \
    FZF_DEFAULT_OPTS='-1 -0 --cycle --border --preview-window=wrap --smart-case --marker="*" --walker-skip=".git,node_modules,target,go,.cache" --inline-info --layout=reverse-list --tiebreak=index --height=70%' \
    FZF_CTRL_R_OPTS="-1 -0 --tiebreak=index --inline-info --no-sort --exact --preview 'echo {}' --preview-window="down:3:hidden:wrap" --bind '?:toggle-preview'" \
    FZF_ALT_C_OPTS='-1 -0 --tiebreak=index --inline-info --walker-skip=".git,node_modules,target,go" --preview "tree -C {} 2>/dev/null | head -200"' \
    FZF_COMPLETION_OPTS='--border --info=inline --tiebreak=index' \
    FZF_COMPLETION_PATH_OPTS='--info=inline --tiebreak=index --walker "file,dir,follow,hidden"' \
    FZF_COMPLETION_DIR_OPTS='--info=inline --tiebreak=index --walker "dir,follow"'
  command mkdir -p -- "${HOME}/.config/bash/completions" &>/dev/null
  if has fzf; then
    ifsource "/usr/share/fzf/key-bindings.bash"
    ifsource "/usr/share/fzf/completion.bash" || eval "$(SHELL=bash fzf --bash)"
    ifsource "/usr/share/fzf-tab-completion/bash/fzf-bash-completion.sh" && bind -x '"\t": fzf_bash_completion'
  fi
  if has sk; then
    declare -x SKIM_DEFAULT_COMMAND="$FIND_CMD" "${FZF_DEFAULT_OPTS:-}"
    ifsource "/usr/share/skim/key-bindings.bash"
    [[ ! -r "${HOME}/.config/bash/completions/sk_completion.bash" ]] && SHELL=bash sk --shell bash >| "${HOME}/.config/bash/completions/sk_completion.bash"
    ifsource "${HOME}/.config/bash/completions/sk_completion.bash" || . <(SHELL=bash sk --shell bash)
  fi
}
fuzzy_finders
#============ Completions ============
# complete -cf sudo
complete -o default -o bashdefault -F _completion_loader sudo
complete -o default -o bashdefault -F _completion_loader sudo-rs
complete -o default -o bashdefault -F _completion_loader doas
complete -o default -o bashdefault -F _completion_loader git
complete -o default -o bashdefault -F _completion_loader command
complete -o default -o bashdefault -F _completion_loader type
complete -o default -o bashdefault -F _completion_loader builtin
complete -o default -o bashdefault -F _completion_loader exec

run-help() { help "$READLINE_LINE" 2>/dev/null || man "$READLINE_LINE"; }
bind -m vi-insert -x '"\eh": run-help'
bind -m emacs -x     '"\eh": run-help'

command -v pay-respects &>/dev/null && eval "$(pay-respects bash)"
command -v gh &>/dev/null && eval "$(gh completion -s bash)"

# Ghostty
[[ $TERM == xterm-ghostty ]] && ifsource "${GHOSTTY_RESOURCES_DIR:-}/shell-integration/bash/ghostty.bash"
# Wikiman
command -v wikiman &>/dev/null && ifsource "/usr/share/wikiman/widgets/widget.bash"
#============ Functions ============
# Having to set a new script as executable always annoys me.
runch(){
  shopt -u nullglob nocaseglob; local s="$1"
  [[ -z $s ]] && { echo $'runch: missing script argument\nUsage: runch <script>' >&2; return 2; }
  [[ ! -f $s ]] && { echo "runch: file not found: $s" >&2; return 1; }
  command chmod +x -- "$s" &>/dev/null || { echo "runch: cannot make executable: $s" >&2; return; }
  [[ $s == */* ]] && "$s" || "./$s"
}
sel(){
  local p="${1:-.}"
  [[ -e $p ]] || { echo "sel: not found: $p" >&2; return; }
  if [[ -d $p ]]; then
    if has eza; then
      LC_ALL=C command eza -al --color=auto --group-directories-first --icons=auto --no-time --no-git --smart-group --no-user --no-permissions -- "$p"
    else
      LC_ALL=C command ls -ahgG --color=auto --group-directories-first -- "$p"
    fi
  elif [[ -f "$p" ]]; then
    if has bat; then
      LC_ALL=C command bat -spp --color auto -- "$p"
    else
      LC_ALL=C command cat -sn -- "$p"
    fi
  else
    printf 'sel: not a file/dir: %s\n' "$p" >&2; return 1
  fi
}
# Function to run cargo commands dynamically
cargo_run(){
  local bins=(gg mommy clicker) cmd=(cargo) b
  for b in "${bins[@]}"; do
    command -v "cargo-$b" &>/dev/null && cmd+=("$b")
  done
  (( ${#cmd[@]} > 1 )) || { echo "No cargo binaries available: ${bins[*]}" >&2; return 1; }
  "${cmd[@]}" "$@"
}
sudo-cl(){
  [[ ${#READLINE_LINE} -eq 0 ]] && READLINE_LINE=$(fc -ln -1 | xargs)
  if [[ $READLINE_LINE == sudo\ * ]]; then
    READLINE_LINE="${READLINE_LINE#sudo }"
  else
    READLINE_LINE="sudo $READLINE_LINE"
  fi
  READLINE_POINT="${#READLINE_LINE}"
}
bind -x '"\e\e": sudo-cl'
#bind '"\es": "\C-asudo \C-e"'

gclone(){ 
  LC_ALL=C command git clone --filter=blob:none --depth 1 --no-tags\
    -c protocol.version=2 -c http.sslVersion=tlsv1.3 -c http.version=HTTP/2 "$@"
}
gpush(){ LC_ALL=C command git add . && LC_ALL=C command git commit -m "${1:-Update}" && LC_ALL=C command git push; }
symbreak(){ LC_ALL=C command find -L "${1:-.}" -type l; }
command -v hyperfine &>/dev/null && hypertest(){ LC_ALL=C LANG=C command hyperfine -w 25 -m 50 -i -S bash -- "$@"; }
touchf(){ command mkdir -p -- "$(dirname -- "$1")" && command touch -- "$1"; }

extract(){
  local c e i
  (($#)) || return
  for i; do
  c='' e=1
        if [[ ! -r $i ]]; then
            echo "$0: file is unreadable: \`$i'" >&2
            continue
        fi
        case $i in
            *.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz|zst)))))
                   c=(bsdtar xvf);;
            *.7z)  c=(7z x);;
            *.Z)   c=(uncompress);;
            *.bz2) c=(bunzip2);;
            *.exe) c=(cabextract);;
            *.gz)  c=(gunzip);;
            *.rar) c=(unrar x);;
            *.xz)  c=(unxz);;
            *.zip) c=(unzip);;
            *.zst) c=(unzstd);;
            *)     echo "$0: unrecognized file extension: \`$i'" >&2
                   continue;;
        esac
        command "${c[@]}" "$i"
        ((e = e || $?))
    done
    return "$e"
}
#============ Aliases ============
# Enable aliases to be sudo’ed
alias sudo='sudo ' sudo-rs='sudo-rs ' doas='doas '
alias mkdir='mkdir -p'
alias e='$EDITOR' se='sudo $EDITOR'
alias nano='nano -/' mi=micro
alias redo='sudo $(fc -ln -1)'

alias e="\$EDITOR"
alias se='\sudo $EDITOR'
alias r='\bat -p'

alias bash='SHELL=bash bash'
alias zsh='SHELL=zsh zsh'
alias fish='SHELL=fish fish'

alias pacman='sudo pacman --noconfirm --needed'
alias paru='paru --skipreview --noconfirm --needed --sudo "$SUDO"'
ssh(){ [[ $TERM == kitty ]] && LC_ALL=C LANG=C.UTF-8 command kitty +kitten ssh "$@" || LC_ALL=C LANG=C.UTF-8 TERM=xterm-256color command ssh "$@"; }

alias cls='clear' c='clear'
alias q='exit'
alias h='history'
alias ptch='patch -p1 <'

# Cheat.sh 
export CHTSH_CURL_OPTIONS="-sfLZ4 --compressed -m 5 --connect-timeout 3"
cht(){
  # join all arguments with '/', so “topic sub topic” → “topic/sub/topic”
  local query="${*// /\/}"
  if ! LC_ALL=C curl -sfZ4 --compressed -m 5 --connect-timeout 3 "cht.sh/${query}"; then
    LC_ALL=C curl -sfZ4 --compressed -m 5 --connect-timeout 3 "cht.sh/:help"
  fi
}
curlsh(){ LC_ALL=C command curl -sfSL "$*" | bash; }
alias cleansh='curlsh https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Clean.sh'
alias updatesh='curlsh https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Updates.sh'

passwdl(){ eval "$(E3LFbgu='CAT /ETC/PASSWD' && printf %s "${E3LFbgu~~}")"; }

if has eza; then
  alias ls='eza -F --color=auto --group-directories-first --icons=auto'
  alias la='eza -AF --color=auto --group-directories-first --icons=auto'
  alias ll='eza -AlF --color=auto --group-directories-first --icons=auto --no-time --no-git --smart-group --no-user --no-permissions'
  alias lt='eza -ATF -L 3 --color=auto --group-directories-first --icons=auto --no-time --no-git --smart-group --no-user --no-permissions'
else
  alias ls='ls --color=auto --group-directories-first -BhLC'
  alias la='ls --color=auto --group-directories-first -ABhLgGoC'
  alias ll='ls --color=auto --group-directories-first -ABhLgGo'
  alias lt='ls --color=auto --group-directories-first -ABhLgGo'
fi
alias which='command -v '
alias grep='grep --color=auto' fgrep='fgrep --color=auto' egrep='grep --color=auto-E'
alias cp='cp -iv' mv='mv -iv' ln='ln -ivsn'
alias rm='rm -Iv --preserve-root' rmd='rm -rIv --preserve-root' rmdir'rmdir -v'
alias chmod='chmod --preserve-root' chown='chown --preserve-root' chgrp='chgrp --preserve-root'
alias histl='history | grep -i'
alias find='find -O3' findl='find -O3 . | grep -i'
alias psl="ps aux | grep -i"
alias topcpu="ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
alias diskl='lsblk -A -o NAME,SIZE,TYPE,MOUNTPOINT'
has btm && alias top=btm btop=btm

alias plasma-reset="DISPLAY=:0 kwin --replace ; sleep 2 ; plasmashell --replace &"

# DIRECTORY NAVIGATION
alias ..='cd ..' ...='cd ../..' ....='cd ../../..' .....='cd ../../../..' ......='cd ../../../../..' bd='cd "$OLDPWD"' cd-="cd -" home='cd ~'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias 000='chmod -R 000' 644='chmod -R 644' 666='chmod -R 666' 755='chmod -R 755' 777='chmod -R 777'
alias h="history | grep " p="ps aux | grep " f="find . | grep "
alias mktar='tar -cvf' mkbz2='tar -cvjf' mkgz='tar -cvzf' untar='tar -xvf' unbz2='tar -xvjf' ungz='tar -xvzf'

# Common use
alias grep='grep --color=auto'
alias fgrep='\grep --color=auto -F'
alias egrep='\grep --color=auto -E'
alias big="expac -H M '%m\t%n' | sort -hr | nl | head -n 50"   # Sort installed packages according to size in MB
alias gitpkg='LC_ALL=C pacman -Qq | LC_ALL=C \grep -ci "\-git"'         # List amount of -git packages

alias cleanup='sudo pacman -Rns (pacman -Qtdq)'
alias dmesg="sudo /bin/dmesg -L=always"
alias reboot='sudo systemctl reboot'
alias poweroff='sudo systemctl poweroff'
alias netctl='sudo netctl'
alias scat='sudo cat'
alias openports='ss --all --numeric --processes --ipv4 --ipv6'

# https://snarky.ca/why-you-should-use-python-m-pip/
alias pip='python -m pip' py3='python3' py='python'

alias speedt='curl -sf https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'

# Dotfiles
# LC_ALL=C git clone --bare git@github.com:Ven0m0/dotfiles.git $HOME/.dotfiles
# alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# --- Tool Wrappers ---

# Git -> Gix wrapper (gitoxide)
git(){
  local subcmd="${1:-}"
  if has gix; then
    case "$subcmd" in
      clone|fetch|pull|init|status|diff|log|rev-parse|rev-list|commit-graph|verify-pack|index-from-pack|pack-explode|remote|config|exclude|free|mailmap|odb|commitgraph|pack) gix "$@";;
      *) command git "$@";;
    esac
  else
    command git "$@"
  fi
}

# Curl -> Aria2 wrapper
curl(){
  local -a args=() out_file=""
  if has aria2c; then
    while [[ $# -gt 0 ]]; do
      case "$1" in
        -o|--output) out_file="$2"; shift 2;;
        -L|--location|-s|--silent|-S|--show-error|-f|--fail|--compressed) shift;;
        http*|ftp*) args+=("$1"); shift;;
        *) args+=("$1"); shift;;
      esac
    done
    if [[ ${#args[@]} -gt 0 ]]; then
      local -a aria_flags=(-x16 -s16 -k1M -j16 --file-allocation=none --summary-interval=0)
      if [[ -n $out_file ]]; then
        aria2c "${aria_flags[@]}" -d "$(dirname "$out_file")" -o "$(basename "$out_file")" "${args[@]}"
      else
        aria2c "${aria_flags[@]}" "${args[@]}"
      fi
    else
      command curl "$@"
    fi
  else
    command curl "$@"
  fi
}

# Pip -> UV wrapper
pip(){
  if has uv; then
    case "${1:-}" in
      install|uninstall|list|show|freeze|check) uv pip "$@";;
      *) command pip "$@";;
    esac
  else
    command pip "$@"
  fi
}

# ADB connect
adb-connect(){
  if ! adb devices &>/dev/null; then exit 1; fi
  local IP="${1:-$(adb shell ip route | awk '{print $9}')}" PORT="${2:-5555}"
  adb tcpip "$PORT" &>/dev/null || :
  adb connect "${IP}:${PORT}"
}

#============ Bindings (readline) ============
bind 'set completion-query-items 250'
bind 'set page-completions off'
bind 'set show-all-if-ambiguous on'
bind 'set show-all-if-unmodified on'
bind 'set menu-complete-display-prefix on'
bind "set completion-ignore-case on"
bind "set completion-map-case on"
bind 'set mark-directories on'
bind "set mark-symlinked-directories on"
bind "set bell-style none"
bind 'set skip-completed-text on'
bind 'set colored-stats on'
bind 'set colored-completion-prefix on'
bind 'set expand-tilde on'
bind '"Space": magic-space'
bind '"\C-o": kill-whole-line'
bind '"\C-a": beginning-of-line'
bind '"\C-e": end-of-line'
bind '"\e[1;5D": backward-word'
bind '"\e[1;5C": forward-word'
# prefixes the line with sudo , if Alt+s is pressed
#bind '"\ee": "\C-asudo \C-e"'
#bind '"\es":"\C-asudo "'
#============ Stealth ============
stealth=${stealth:-0}
#============ Prompt 2 ============
configure_prompt(){
  command -v starship &>/dev/null && { eval "$(LC_ALL=C starship init bash)"; return; }
  local MGN='\[\e[35m\]' BLU='\[\e[34m\]' YLW='\[\e[33m\]' BLD='\[\e[1m\]' UND='\[\e[4m\]' GRN='\[\e[32m\]' CYN='\[\e[36m\]' DEF='\[\e[0m\]' RED='\[\e[31m\]' PNK='\[\e[38;5;205m\]' USERN HOSTL
  USERN="${MGN}\u${DEF}"; [[ $EUID -eq 0 ]] && USERN="${RED}\u${DEF}"
  HOSTL="${BLU}\h${DEF}"; [[ -n $SSH_CONNECTION ]] && HOSTL="${YLW}\h${DEF}"
  exstat(){ [[ $? == 0 ]] && printf '%s:)${DEF}' || printf '%sD:${DEF}'; }
  PS1="[${USERN}@${HOSTL}${UND}|${DEF}${CYN}\w${DEF}]>${PNK}\A${DEF}|\$(exstat) ${BLD}\$${DEF} "
  PS2='> '
  # Only add if not in stealth mode and not already present in PROMPT_COMMAND
  if command -v mommy &>/dev/null && (( stealth == 1 )) && [[ ${PROMPT_COMMAND:-} != *mommy* ]]; then
    PROMPT_COMMAND="LC_ALL=C mommy -1 -s \$?; ${PROMPT_COMMAND:-}" # mommy https://github.com/fwdekker/mommy
    # PROMPT_COMMAND="LC_ALL=C mommy \$?; ${PROMPT_COMMAND:-}" # Shell-mommy https://github.com/sleepymincy/mommy
  fi
}
configure_prompt 2>/dev/null &
#============ End ============
dedupe_path(){
  local IFS=: dir s; declare -A seen
  for dir in $PATH; do [[ -n $dir && -z ${seen[$dir]} ]] && seen[$dir]=1 && s="${s:+$s:}$dir"; done
  [[ -n $s ]] && export PATH="$s"
}
dedupe_path
#============ Fetch ============
if [[ $SHLVL -ge 3; ! $BASH_SUBSHELL -ge 1 ]]; then
  if [[ "${stealth:-0}" -eq 1 ]]; then
    has fastfetch && fetch='fastfetch --ds-force-drm --thread --detect-version false'
  else
    if has hyfetch; then
      fetch='hyfetch -b fastfetch -m rgb -p transgender'
    elif has fastfetch; then
      fetch='fastfetch --ds-force-drm --thread --detect-version false'
    elif has vnfetch; then
      fetch='vnfetch'
    elif has vnfetch.sh; then
      fetch='vnfetch.sh'
    fi
    [[ -n $fetch ]] && eval "$fetch" 2>/dev/null &
  fi
fi
#============ Sourcing 2 ============
# Sdkman
ifsource "$HOME/.sdkman/bin/sdkman-init.sh" && export SDKMAN_DIR="$HOME/.sdkman"

# Zoxide
if command -v zoxide &>/dev/null; then
  export _ZO_DOCTOR=0 _ZO_ECHO=0 _ZO_EXCLUDE_DIRS="${HOME}:.cache:go"
  export _ZO_FZF_OPTS="--cycle -0 -1 --inline-info --no-multi --no-sort --preview 'eza --no-quotes --color=always --color-scale-mode=fixed --group-directories-first --oneline {2..}'"
  ifsource "$HOME/.config/bash/zoxide.bash" && eval "$(zoxide init bash)"
fi
if has intelli-shell; then
  eval "$(intelli-shell init bash)"
fi
if has zellij; then
  eval "$(zellij setup --generate-auto-start bash)"
  ifsource ~/.config/bash/completions/zellij.bash
fi
#============ END ============
unset -f ifsource prependpath
