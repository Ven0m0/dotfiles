#!/usr/bin/env bash
#============================= [Environment Vars] =============================

# --- Locale & Timezone
export LANG='C.UTF-8' TZ='Europe/Berlin' TIME_STYLE='+%d-%m %H:%M'
export GPG_TTY="$(tty)"
unset LC_ALL

# --- Editors
has micro && export EDITOR='micro' MICRO_TRUECOLOR=1
export EDITOR="${EDITOR:-nano}" GIT_EDITOR="$EDITOR" SUDO_EDITOR="$EDITOR" FCEDIT="$EDITOR"

if has code; then
  export VISUAL="code -w"
elif has vscode; then
  export VISUAL="vscode -w"
elif has kate; then
  export VISUAL="kate"
else
  export VISUAL="${EDITOR:-nano}"
fi

# --- Browser
if has firefox; then
  export BROWSER='firefox' GTK_USE_PORTAL=1
  export MOZ_ENABLE_WAYLAND=1 MOZ_DBUS_REMOTE=1 MOZ_ENABLE_XINPUT2=1 MOZ_DISABLE_RDD_SANDBOX=1
else
  export BROWSER='xdg-open'
fi

# --- Terminal
if has ghostty; then
  [[ "$TERM" == "xterm-ghostty" ]] && ifsource "${GHOSTTY_RESOURCES_DIR:-/usr/share/ghostty}/shell-integration/bash/ghostty.bash"
  export TERMINAL="ghostty +ssh-cache --wait-after-command"
fi

# --- Privilege Escalation
if has sudo-rs; then
  export SUDO='sudo-rs'
elif has doas; then
  export SUDO='doas'
else
  export SUDO='sudo'
fi

# --- Path Setup
prependpath "$HOME/.local/bin"
prependpath "$HOME/bin"

# --- Tool Settings
export HOMEBREW_NO_ANALYTICS=1
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"

# --- Wayland/Graphics
if [[ "${XDG_SESSION_TYPE-}" == "wayland" ]]; then
  export GDK_BACKEND=wayland QT_QPA_PLATFORM=wayland SDL_VIDEODRIVER=wayland
  export QT_WAYLAND_DISABLE_WINDOWDECORATION=1 QT_ENABLE_HIGHDPI_SCALING=1
  export QT_AUTO_SCREEN_SCALE_FACTOR=1 QT_NO_SYNTHESIZED_BOLD=1
  export _JAVA_AWT_WM_NONREPARENTING=1 _NROFF_U=1

  # NVIDIA-specific settings
  if has nvidia-smi; then
    export NVD_BACKEND=direct LIBVA_DRIVER_NAME=nvidia VDPAU_DRIVER=nvidia
    export __GLX_VENDOR_LIBRARY_NAME=nvidia mesa_glthread=true
    export __GL_THREADED_OPTIMIZATIONS=1 __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
    export __GL_SHADER_DISK_CACHE_SIZE=12000000000
    exportif __GL_SHADER_DISK_CACHE_PATH "$HOME/.cache/nvidia/GLCache"
  fi
fi
has dbus-launch && export "$(dbus-launch 2>/dev/null)"

# --- Performance Tuning
export GLIBC_TUNABLES="glibc.malloc.hugetlb=1"
export MALLOC_CONF="metadata_thp:auto,tcache:true,background_thread:true,percpu_arena:percpu"
export _RJEM_MALLOC_CONF="$MALLOC_CONF"
export MIMALLOC_ALLOW_LARGE_OS_PAGES=1 MIMALLOC_VERBOSE=0 MIMALLOC_SHOW_ERRORS=0

has ccache && export CCACHE_COMPRESS=true CCACHE_COMPRESSLEVEL=3 CCACHE_INODECACHE=true
has buildcache && export BUILDCACHE_COMPRESS_FORMAT=ZSTD BUILDCACHE_DIRECT_MODE=true

# --- Gaming (Proton/Wine)
if has proton; then
  export PROTON_ENABLE_WAYLAND=1 PROTON_NO_WM_DECORATION=1 PROTON_USE_NTSYNC=1
  export PROTON_PREFER_SDL=1 PROTON_ENABLE_HDR=1
  export PROTON_DLSS_UPGRADE=1 PROTON_FSR4_UPGRADE=1 PROTON_XESS_UPGRADE=1
  export PROTON_NVIDIA_LIBS_NO_32BIT=1 PROTON_NVIDIA_NVENC=1 PROTON_ENABLE_NGX_UPDATER=1
  export DXVK_NVAPI_DRS_NGX_DLSS_RR_OVERRIDE=on DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE=on
  export DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE=on
  export DXVK_NVAPI_DRS_NGX_DLSS_RR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest
  export DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest
fi

if has wine; then
  export WINE_NO_WM_DECORATION=1 WINE_PREFER_SDL_INPUT=1
  export WINEPREFIX="$XDG_DATA_HOME/wine"
fi
