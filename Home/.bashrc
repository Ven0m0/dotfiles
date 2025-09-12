# ~/.bashrc
# https://www.gnu.org/software/bash/manual/bash.html

[[ $- != *i* ]] && return
export LC_ALL=C
#============ Helpers ============
# Check for command
has(){ [[ -x $(command -v -- "$1") ]]; }
# Safely source file if it exists ( ~ -> $HOME )
ifsource(){ [[ -r "${1/#\~\//${HOME}/}" ]] && . "${1/#\~\//${HOME}/}" 2>/dev/null; }
# Safely prepend only if not already in PATH ( ~ -> $HOME )
prependpath(){ [[ -d "${1/#\~\//${HOME}/}" ]] && [[ ":$PATH:" != *":${1/#\~\//${HOME}/}:"* ]] && PATH="${1/#\~\//${HOME}/}${PATH:+:$PATH}"; }
#============ Sourcing ============
# wiki.archlinux.org/title/Bash#Command_not_found
dot=(/etc/bashrc
  "$HOME"/{.bash_aliases,.bash_functions,.bash_fuzz,.fns,.funcs,.bash.d/cht.sh}
  /usr/share/doc/pkgfile/command-not-found.bash
)
for p in "${dot[@]}"; do ifsource "$p"; done; unset p dot

# completions (quiet)
ifsource "/usr/share/bash-completion/bash_completion" || ifsource "/etc/bash_completion"

# github.com/akinomyoga/ble.sh
[[ -r /usr/share/blesh/ble.sh ]] && . "/usr/share/blesh/ble.sh" --attach=none 2>/dev/null || { \
  [[ -r "${HOME}/.local/share/blesh/ble.sh" ]] && . "${HOME}/.local/share/blesh/ble.sh" --attach=none 2>/dev/null; }

# github.com/kazhala/dotbare
[[ -d ${HOME}/.dotbare ]] && { [[ -f ${HOME}/.dotbare/dotbare ]] && alias dotbare="${HOME}/.dotbare/dotbare"; ifsource "${HOME}/.dotbare/dotbare.plugin.bash"; }

ifsource "${HOME}/.nativa.sh" && { export NAVITA_COMMAND=z NAVITA_DATA_DIR="${HOME}/.local/state/navita" NAVITA_CONFIG_DIR="${HOME}/.config/navita"; }

#============ History / Prompt basics ============
# PS1='[\u@\h|\w] \$' # bash-prompt-generator.org
HISTSIZE=1000 HISTFILESIZE="$HISTSIZE"
HISTCONTROL="erasedups:ignoreboth"
HISTIGNORE="&:[bf]g:clear:cls:exit:history:bash:fish:?:??"
export HISTTIMEFORMAT="%F %T " IGNOREEOF=100
HISTFILE="${HOME}/.bash_history"
PROMPT_DIRTRIM=2 PROMPT_COMMAND="history -a"
#============ Core ============
CDPATH=".:${HOME}:/"
ulimit -c 0 # disable core dumps
export FIGNORE="argo.lock" IFS="${IFS:-$' \t\n'}"
shopt -s histappend cmdhist checkwinsize dirspell cdable_vars cdspell execfail varredir_close \
         autocd hostcomplete no_empty_cmd_completion globstar nullglob force_fignore
# Disable Ctrl-s, Ctrl-q
bind -r '\C-s'
stty -ixon -ixoff -ixany
set +H # disable history expansion that breaks some scripts
# set -o vi; export VIMINIT='set encoding=utf-8'
#============ Env ============
prependpath "${HOME}/.root/usr/bin"
prependpath "${HOME}/.local/bin"
prependpath "${HOME}/.bin"
prependpath "${HOME}/bin"

# Editor selection: prefer micro, fallback to nano
_editor_cmd="$(command -v micro 2>/dev/null || :)"; _editor_cmd="${_editor_cmd##*/}"; EDITOR="${_editor_cmd:-nano}"
export EDITOR VISUAL="$EDITOR" VIEWER="$EDITOR" GIT_EDITOR="$EDITOR" SYSTEMD_EDITOR="$EDITOR" FCEDIT="$EDITOR" SUDO_EDITOR="$EDITOR"
unset _editor_cmd 2>/dev/null
# https://wiki.archlinux.org/title/Locale
export LANG=C.UTF-8 LANGUAGE="en_US:en:C"
export LC_COLLATE=C LC_CTYPE=C.UTF-8
export LC_MEASUREMENT=C TZ='Europe/Berlin'

jobs="$(nproc)" SHELL="${BASH:-/bin/bash}"
has dbus-launch && export "$(dbus-launch 2>/dev/null)"

# Mimalloc & Jemalloc
# https://github.com/microsoft/mimalloc/blob/main/docs/environment.html
MALLOC_CONF="metadata_thp:auto,tcache:true,background_thread:true,percpu_arena:percpu"
export MALLOC_CONF _RJEM_MALLOC_CONF="$MALLOC_CONF" MIMALLOC_VERBOSE=0 MIMALLOC_SHOW_ERRORS=0 MIMALLOC_SHOW_STATS=0 MIMALLOC_ALLOW_LARGE_OS_PAGES=1 MIMALLOC_PURGE_DELAY=25 MIMALLOC_ARENA_EAGER_COMMIT=2

# Delta / bat integration
has delta && { export GIT_PAGER=delta; command -v batdiff &>/dev/null && export BATDIFF_USE_DELTA=true; }

if has bat; then
  export PAGER=bat BAT_THEME="Sublime Snazzy" BAT_STYLE=auto LESSQUIET=1
  alias cat='\bat -pp'
  has batman && eval "$(batman --export-env)"
  has batpipe && eval "$(batpipe)"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'" MANROFFOPT="-c"
else
  alias cat='cat -sn'
fi
if has less; then
  LESS_TERMCAP_md=$'\e[01;31m' LESS_TERMCAP_me=$'\e[0m' LESS_TERMCAP_us=$'\e[01;32m' LESS_TERMCAP_ue=$'\e[0m' LESS_TERMCAP_so=$'\e[45;93m' LESS_TERMCAP_se=$'\e[0m'
  LESSHISTFILE="-" LESS='-RFrXnsi --mouse --use-color --no-edit-warn --no-vbell --no-histdups' LESSCHARSET=utf-8
  export LESSHISTFILE LESS LESS_TERMCAP_md LESS_TERMCAP_me LESS_TERMCAP_us LESS_TERMCAP_ue LESS_TERMCAP_so LESS_TERMCAP_se LESSCHARSET
  export PAGER="${PAGER:-less}"
fi
export GIT_PAGER="${GIT_PAGER:-$PAGER}"
# XDG + misc
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:=${HOME}/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:=${HOME}/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:=${HOME}/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:=${HOME}/.cache}"

# https://www.reddit.com/r/programming/comments/109rjuj/how_setting_the_tz_environment_variable_avoids
export INPUTRC="$HOME/.inputrc"
export CURL_HOME="$HOME" WGETRC="${HOME}/.config/wget/wgetrc"
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

export PYTHONOPTIMIZE=2 PYTHONIOENCODING=utf-8 PYTHON_JIT=1 PYENV_VIRTUALENV_DISABLE_PROMPT=1 \
  UV_NO_VERIFY_HASHES=1 UV_SYSTEM_PYTHON=1 UV_BREAK_SYSTEM_PACKAGES=0 UV_TORCH_BACKEND=auto UV_FORK_STRATEGY=fewest \
  UV_RESOLUTION=highest UV_PRERELEASE=allow UV_COMPILE_BYTECODE=1 UV_LINK_MODE=hardlink UV_NATIVE_TLS=1

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

if has dircolors; then
  eval "$(dircolors -b)" &>/dev/null
else
  export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.7z=01;31:*.ace=01;31:*.alz=01;31:*.apk=01;31:*.arc=01;31:*.arj=01;31:*.bz=01;31:*.bz2=01;31:*.cab=01;31:*.cpio=01;31:*.crate=01;31:*.deb=01;31:*.drpm=01;31:*.dwm=01;31:*.dz=01;31:*.ear=01;31:*.egg=01;31:*.esd=01;31:*.gz=01;31:*.jar=01;31:*.lha=01;31:*.lrz=01;31:*.lz=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.lzo=01;31:*.pyz=01;31:*.rar=01;31:*.rpm=01;31:*.rz=01;31:*.sar=01;31:*.swm=01;31:*.t7z=01;31:*.tar=01;31:*.taz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tgz=01;31:*.tlz=01;31:*.txz=01;31:*.tz=01;31:*.tzo=01;31:*.tzst=01;31:*.udeb=01;31:*.war=01;31:*.whl=01;31:*.wim=01;31:*.xz=01;31:*.z=01;31:*.zip=01;31:*.zoo=01;31:*.zst=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.jxl=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.crdownload=00;90:*.dpkg-dist=00;90:*.dpkg-new=00;90:*.dpkg-old=00;90:*.dpkg-tmp=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:*.swp=00;90:*.tmp=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:'
fi
### LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.tga=01;35:*.tiff=01;35:*.png=01;35:*.mpeg=01;35:*.avi=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'
export CLICOLOR=1 SYSTEMD_COLORS=1
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
    [[ -r /usr/share/fzf/key-bindings.bash ]] && . "/usr/share/fzf/key-bindings.bash"
    [[ ! -r ${HOME}/.config/bash/completions/fzf_completion.bash ]] && SHELL=bash fzf --bash >| "${HOME}/.config/bash/completions/fzf_completion.bash"
    . "${HOME}/.config/bash/completions/fzf_completion.bash" || eval "$(SHELL=bash fzf --bash)"
  fi
  if has sk; then
    declare -x SKIM_DEFAULT_COMMAND="$FIND_CMD" "${FZF_DEFAULT_OPTS:-}"
    [[ -r "/usr/share/skim/key-bindings.bash" ]] && . "/usr/share/skim/key-bindings.bash"
    [[ ! -r "${HOME}/.config/bash/completions/sk_completion.bash" ]] && SHELL=bash sk --shell bash >| "${HOME}/.config/bash/completions/sk_completion.bash"
    . "${HOME}/.config/bash/completions/sk_completion.bash" || . <(SHELL=bash sk --shell bash)
  fi
}
fuzzy_finders

#============ Completions ============
complete -o default -o bashdefault -F _completion_loader sudo
complete -o default -o bashdefault -F _completion_loader sudo-rs
complete -o default -o bashdefault -F _completion_loader doas
complete -o default -o bashdefault -F _completion_loader git
complete -o default -o bashdefault -F _completion_loader command
complete -o default -o bashdefault -F _completion_loader type
complete -o default -o bashdefault -F _completion_loader builtin
complete -o default -o bashdefault -F _completion_loader exec

command -v pay-respects &>/dev/null && eval "$(pay-respects bash)"
command -v gh &>/dev/null && eval "$(gh completion -s bash)"

# Ghostty
[[ $TERM == xterm-ghostty ]] && . "${GHOSTTY_RESOURCES_DIR:-}/shell-integration/bash/ghostty.bash"
# Wikiman
command -v wikiman &>/dev/null && . "/usr/share/wikiman/widgets/widget.bash"
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

gcom(){ LC_ALL=C command git add . && LC_ALL=C command git commit -m "$1"; }
gpush(){ LC_ALL=C command git add . && LC_ALL=C command git commit -m "${1:-Update}" && LC_ALL=C command git push; }
symbreak(){ LC_ALL=C command find -L "${1:-.}" -type l; }
command -v hyperfine &>/dev/null && hypertest(){ LC_ALL=C LANG=C command hyperfine -w 25 -m 50 -i -S bash -- "$@"; }
touchf(){ command mkdir -p -- "$(dirname -- "$1")" && command touch -- "$1"; }

# Cheat.sh 
export CHTSH_CURL_OPTIONS="-sfLZ4 --compressed -m 5 --connect-timeout 3"
cht(){
  # join all arguments with '/', so “topic sub topic” → “topic/sub/topic”
  local query="${*// /\/}"
  # try to fetch the requested cheat‑sheet; on HTTP errors (e.g. 404), fall back to :help
  if ! LC_ALL=C curl -sfZ4 --compressed -m 5 --connect-timeout 3 "cht.sh/${query}"; then
    LC_ALL=C curl -sfZ4 --compressed -m 5 --connect-timeout 3 "cht.sh/:help"
  fi
}

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
alias ed='$EDITOR' mi='$EDITOR' smi='sudo $EDITOR'
alias redo='sudo $(fc -ln -1)'

alias pacman='LC_ALL=C LANG=C.UTF-8 sudo pacman --noconfirm --needed --color=auto'
alias paru='LC_ALL=C LANG=C.UTF-8 paru --skipreview --noconfirm --needed'
alias ssh='LC_ALL=C LANG=C.UTF-8 TERM=xterm-256color command ssh'
# ssh(){ TERM=xterm-256color command ssh "$@"; }
alias cls='clear' c='clear'
alias q='exit'
alias h='history'
alias ptch='patch -p1 <'
alias cleansh='curl -sfSL https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Clean.sh | bash'
alias updatesh='curl -sfSL https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Updates.sh | bash'

curlsh(){ LC_ALL=C command curl -sfSL "$*" | bash; }

passwdl(){ eval "$(E3LFbgu='CAT /ETC/PASSWD' && printf %s "${E3LFbgu~~}")"; }

if has eza; then
  alias ls='eza -F --color=auto --group-directories-first --icons=auto'
  alias la='eza -AF --color=auto --group-directories-first --icons=auto'
  alias ll='eza -AlF --color=auto --group-directories-first --icons=auto --no-time --no-git --smart-group --no-user --no-permissions'
  alias lt='eza -ATF -L 3 --color=auto --group-directories-first --icons=auto --no-time --no-git --smart-group --no-user --no-permissions'
else
  alias ls='ls --color=auto --group-directories-first -C'
  alias la='ls --color=auto --group-directories-first -A'
  alias ll='ls --color=auto --group-directories-first -oh'
  alias lt='ls --color=auto --group-directories-first -oghAt'
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

# DIRECTORY NAVIGATION
if has zoxide; then
  alias ..='z ..'
  alias ...='z ../..'
  alias ....='z ../../..'
  alias .....='z ../../../..'
  alias ......='z ../../../../..'
  alias cd-="cd -"
  alias cd='z'
else
  alias ..='cd ..'
  alias ...='cd ../..' .2='cd ../..'
  alias ....='cd ../../..'
  alias .....='cd ../../../..'
  alias ......='cd ../../../../..'
  alias cd-="cd -"
  unalias cd
fi
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

# Common use
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias big="expac -H M '%m\t%n' | LC_ALL=C sort -hr | nl | head -n 50"   # Sort installed packages according to size in MB
alias gitpkg='LC_ALL=C pacman -Qq | LC_ALL=C \grep -ci "\-git"'         # List amount of -git packages

alias cleanup='sudo pacman -Rns (pacman -Qtdq)'
alias dmesg="sudo /bin/dmesg -L=always"

# https://snarky.ca/why-you-should-use-python-m-pip/
alias pip='python -m pip' py3='python3' py='python'

alias speedt='curl -sf https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'

# Dotfiles
# LC_ALL=C git clone --bare git@github.com:Ven0m0/dotfiles.git $HOME/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

#============ Bindings (readline) ============
bind 'set completion-query-items 150'
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
bind 'set enable-bracketed-paste off'
# prefixes the line with sudo , if Alt+s is pressed
#bind '"\ee": "\C-asudo \C-e"'
#bind '"\es":"\C-asudo "'
# https://wiki.archlinux.org/title/Bash
run-help(){ help "$READLINE_LINE" 2>/dev/null || man "$READLINE_LINE"; }
bind -m vi-insert -x '"\eh": run-help'
bind -m emacs -x     '"\eh": run-help'
#============ Stealth ============
stealth=${stealth:-0}
#============ Prompt 2 ============
configure_prompt(){
  command -v starship &>/dev/null && { eval "$(LC_ALL=C starship init bash)"; return; }
  
  local MGN='\[\e[35m\]' BLU='\[\e[34m\]' YLW='\[\e[33m\]' BLD='\[\e[1m\]' UND='\[\e[4m\]' \
        CYN='\[\e[36m\]' DEF='\[\e[0m\]' RED='\[\e[31m\]'  PNK='\[\e[38;5;205m\]' USERN HOSTL
  USERN="${MGN}\u${DEF}"; [[ $EUID -eq 0 ]] && USERN="${RED}\u${DEF}"
  HOSTL="${BLU}\h${DEF}"; [[ -n $SSH_CONNECTION ]] && HOSTL="${YLW}\h${DEF}"
  
  PS1="[${USERN}@${HOSTL}${UND}|${DEF}${CYN}\w${DEF}]>${PNK}\A${DEF}|\$? ${BLD}\$${DEF} "
  PS2='> '
  # Git
  
  if command -v __git_ps1 &>/dev/null && [[ ${PROMPT_COMMAND:-} != *git_ps1* ]]; then
    export GIT_PS1_OMITSPARSESTATE=1 GIT_PS1_HIDE_IF_PWD_IGNORED=1
    unset GIT_PS1_SHOWDIRTYSTATE GIT_PS1_SHOWSTASHSTATE GIT_PS1_SHOWUPSTREAM GIT_PS1_SHOWUNTRACKEDFILES
    PROMPT_COMMAND="LC_ALL=C __git_ps1 2>/dev/null; ${PROMPT_COMMAND:-}"
  fi
  # Only add if not in stealth mode and not already present in PROMPT_COMMAND
  if command -v mommy &>/dev/null && [[ "${stealth:-0}" -ne 1 ]] && [[ ${PROMPT_COMMAND:-} != *mommy* ]]; then
    PROMPT_COMMAND="LC_ALL=C mommy -1 -s \$?; ${PROMPT_COMMAND:-}" # mommy https://github.com/fwdekker/mommy
    # PROMPT_COMMAND="LC_ALL=C mommy \$?; ${PROMPT_COMMAND:-}" # Shell-mommy https://github.com/sleepymincy/mommy
  fi
}
configure_prompt
#============ End ============
dedupe_path(){
  local IFS=: dir s; declare -A seen
  for dir in $PATH; do
    [[ -n $dir && -z ${seen[$dir]} ]] && seen[$dir]=1 && s="${s:+$s:}$dir"
  done
  [[ -n $s ]] && export PATH="$s"
  command -v systemctl &>/dev/null && command systemctl --user import-environment PATH &>/dev/null
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
    else
      fetch='curl -sf https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Scripts/shell-tools/vnfetch.sh | bash'
    fi
    LC_ALL=C eval "$fetch"
  fi
fi
#============ Jumping ============
command -v zoxide &>/dev/null && { \
  export _ZO_DOCTOR=0 _ZO_ECHO=0 _ZO_EXCLUDE_DIRS="${HOME}:.cache:go" _ZO_FZF_OPTS="--algo=v1 --cycle +m --no-unicode --no-mouse -0 -1 --inline-info"; \
  eval "$(zoxide init bash)"; }
#============ Ble.sh final ============
[[ ! ${BLE_VERSION-} ]] || ble-attach
unset LC_ALL
