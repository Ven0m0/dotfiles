#============================= [Environment Vars] =============================
# --- Base Environment
has micro && export EDITOR='micro' MICRO_TRUECOLOR=1
export EDITOR="${EDITOR:-nano}" GIT_EDITOR="$EDITOR" SUDO_EDITOR="$EDITOR"

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
  export SUDO='sudo-rs'
elif has doas; then
  export SUDO='doas'
else
  export SUDO='sudo'
fi

if has ghostty; then
  [[ "$TERM" == "xterm-ghostty" ]] && ifsource "${GHOSTTY_RESOURCES_DIR:-/usr/share/ghostty}/shell-integration/bash/ghostty.bash"
  export TERMINAL="ghostty +ssh-cache --wait-after-command"
fi

export LANG='C.UTF-8' LC_COLLATE=C TZ='Europe/Berlin' TIME_STYLE='+%d-%m %H:%M'
export GPG_TTY="$(tty)"

# --- Tooling
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export NODE_OPTIONS='--max-old-space-size=4096'
export HOMEBREW_NO_ANALYTICS=1

# --- Path Setup
prependpath "$HOME/.local/bin"
prependpath "$HOME/bin"
exportif BUN_INSTALL "$HOME/.bun"
[[ -n "$BUN_INSTALL" ]] && prependpath "$BUN_INSTALL/bin"

# --- Wayland/Graphics Session
if [[ "${XDG_SESSION_TYPE-}" == "wayland" ]]; then
  export GDK_BACKEND=wayland QT_QPA_PLATFORM=wayland SDL_VIDEODRIVER=wayland
  export MOZ_ENABLE_WAYLAND=1 MOZ_DBUS_REMOTE=1 MOZ_ENABLE_XINPUT2=1 MOZ_DISABLE_RDD_SANDBOX=1
  export QT_WAYLAND_DISABLE_WINDOWDECORATION=1 QT_ENABLE_HIGHDPI_SCALING=1 QT_AUTO_SCREEN_SCALE_FACTOR=1 QT_NO_SYNTHESIZED_BOLD=1
  export _JAVA_AWT_WM_NONREPARENTING=1 _NROFF_U=1 GTK_USE_PORTAL=1
  # NVIDIA-specific Wayland settings
  if has nvidia-smi; then
    export NVD_BACKEND=direct LIBVA_DRIVER_NAME=nvidia VDPAU_DRIVER=nvidia
    export __GLX_VENDOR_LIBRARY_NAME=nvidia __GL_THREADED_OPTIMIZATIONS=1
    exportif __GL_SHADER_DISK_CACHE_PATH "$HOME/.cache/nvidia/GLCache"
  fi
fi

has dbus-launch && export "$(dbus-launch 2>/dev/null)"

# --- Performance Tuning
export GLIBC_TUNABLES="glibc.malloc.hugetlb=1"
export MALLOC_CONF="metadata_thp:auto,tcache:true,background_thread:true,percpu_arena:percpu"
export _RJEM_MALLOC_CONF="$MALLOC_CONF"
export MIMALLOC_ALLOW_LARGE_OS_PAGES=1 MIMALLOC_VERBOSE=0 MIMALLOC_SHOW_ERRORS=0
export PYTHONOPTIMIZE=2
