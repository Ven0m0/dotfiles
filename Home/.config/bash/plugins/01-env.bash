#============================= [Environment Vars] =============================
# --- Base Environment
command -v micro &>/dev/null && EDITOR='micro' 
export GIT_EDITOR="$EDITOR" SUDO_EDITOR="$EDITOR" EDITOR="${EDITOR:-nano}"
if command -v code; then
  export VISUAL="code -w"
elif command -v vscode; then
  export VISUAL="vscode -w"
elif command -v kate; then
  export VISUAL="kate"
else
  export VISUAL="$EDITOR"
fi
if has firefox; then
  export BROWSER='firefox' MOZ_ENABLE_WAYLAND=1 MOZ_DBUS_REMOTE=1 MOZ_ENABLE_XINPUT2=1 MOZ_DISABLE_RDD_SANDBOX=1
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
if command -v ghostty &>/dev/null; then
  [[ "$TERM" == "xterm-ghostty" ]] && ifsource "${GHOSTTY_RESOURCES_DIR:-/usr/share/ghostty}/shell-integration/bash/ghostty.bash"
  export TERMINAL="ghostty +ssh-cache --wait-after-command"
fi
export LANG='C.UTF-8' LC_COLLATE=C LC_CTYPE=C
export TZ='Europe/Berlin' TIME_STYLE='+%d-%m %H:%M'
export GPG_TTY="$(tty)"

# --- Tooling
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export NODE_OPTIONS='--max-old-space-size=4096'
export HOMEBREW_NO_ANALYTICS=true

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
if [[ "${XDG_SESSION_TYPE-}" == "wayland" ]]; then
  export GDK_BACKEND=wayland QT_QPA_PLATFORM=wayland SDL_VIDEODRIVER=wayland
  export MOZ_ENABLE_WAYLAND=1 MOZ_DBUS_REMOTE=1 MOZ_ENABLE_XINPUT2=1 MOZ_DISABLE_RDD_SANDBOX=1
  export QT_WAYLAND_DISABLE_WINDOWDECORATION=1 QT_ENABLE_HIGHDPI_SCALING=1 QT_AUTO_SCREEN_SCALE_FACTOR=1 QT_NO_SYNTHESIZED_BOLD=1
  export _JAVA_AWT_WM_NONREPARENTING=1 _NROFF_U=1 GTK_USE_PORTAL=1
fi
command -v dbus-launch &>/dev/null && export "$(dbus-launch 2>/dev/null)"
