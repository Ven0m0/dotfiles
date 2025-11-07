#============================= [Environment Vars] =============================
# --- Base Environment
export EDITOR='micro' VISUAL="$EDITOR" GIT_EDITOR="$EDITOR" SUDO_EDITOR="$EDITOR"
export BROWSER='firefox' TERMINAL='ghostty' SUDO='doas'
export LANG='C.UTF-8' LC_COLLATE='C'
export TZ='Europe/Berlin' TIME_STYLE='+%d-%m %H:%M'
export GPG_TTY="$(tty)"

# --- Tooling
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export NODE_OPTIONS='--max-old-space-size=4096'

# --- Path Setup
prependpath "$HOME/.local/bin"
prependpath "$HOME/bin"
exportif BUN_INSTALL "$HOME/.bun" && prependpath "$BUN_INSTALL/bin"

# --- Wayland/Graphics Session
if [[ "${XDG_SESSION_TYPE-}" == "wayland" ]]; then
  export GDK_BACKEND=wayland QT_QPA_PLATFORM=wayland SDL_VIDEODRIVER=wayland
  export MOZ_ENABLE_WAYLAND=1 QT_WAYLAND_DISABLE_WINDOWDECORATION=1
  export NVD_BACKEND=direct LIBVA_DRIVER_NAME=nvidia VDPAU_DRIVER=nvidia
  export __GLX_VENDOR_LIBRARY_NAME=nvidia __GL_THREADED_OPTIMIZATIONS=1
  exportif __GL_SHADER_DISK_CACHE_PATH "$HOME/.cache/nvidia/GLCache"
fi
has dbus-launch && export "$(dbus-launch 2>/dev/null)"
