#!/bin/bash
# shellcheck shell=bash

# https://github.com/CodesOfRishi/dotfiles/blob/main/Bash/.bashrc.d/environment.sh
# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

export PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel

# Vivid (https://github.com/sharkdp/vivid)
if command -v vivid &>/dev/null; then
  export VIVID_THEME="molokai"
  LS_COLORS="$(vivid generate)"
  export LS_COLORS
fi

# Rust
if command -v cargo &>/dev/null; then
  export CARGO_HOME="${HOME}/.cargo" RUSTUP_HOME="${HOME}/.rustup"
  export CARGO_HTTP_MULTIPLEXING=true CARGO_NET_GIT_FETCH_WITH_CLI=true
  export CARGO_HTTP_SSL_VERSION=tlsv1.3 CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
fi

export FIGNORE=Cargo.lock
export RUST_LOG=off

command -v sccache &>/dev/null && export RUSTC_WRAPPER=sccache
command -v gix &>/dev/null && export GITOXIDE_CORE_MULTIPACKINDEX=true GITOXIDE_HTTP_SSLVERSIONMAX=tls1.3 GITOXIDE_HTTP_SSLVERSIONMIN=tls1.2

export CC=clang CXX=clang++ AR=llvm-ar NM=llvm-nm STRIP=llvm-strip OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump

# Wayland
if [[ ${XDG_SESSION_TYPE:-} = "wayland" ]]; then
  export QT_QPA_PLATFORMTHEME=qt6ct
  export GDK_BACKEND=wayland
  export QT_QPA_PLATFORM=wayland
  export ELECTRON_OZONE_PLATFORM_HINT=auto
  export SDL_VIDEODRIVER=wayland
  export MOZ_ENABLE_XINPUT2=1
  export MOZ_ENABLE_WAYLAND=1
  # To use KDE file dialog with firefox https://daniele.tech/2019/02/how-to-execute-firefox-with-support-for-kde-filepicker/
  export GTK_USE_PORTAL=1
fi

# Java
# export JAVA_OPTIONS="-Dfile.encoding=UTF-8 -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -XX:+IgnoreUnrecognizedVMOptions"
# export JAVA_HOME=""

# Homebrew
export HOMEBREW_NO_ANALYTICS=true

# Rust-parallel
command -v rust-parallel &>/dev/null && export PROGRESS_STYLE=simple

# Path dedupe
#PATH=$(echo "$PATH" | awk -v RS=: '!($0 in a) {a[$0]; printf("%s%s", length(a) > 1 ? ":" : "", $0)}')
#export PATH

# Cache
command -v buildcache &>/dev/null && export BUILDCACHE_COMPRESS_FORMAT=ZSTD BUILDCACHE_DIRECT_MODE=true
command -v ccache &>/dev/null && export CCACHE_COMPRESS=true CCACHE_COMPRESSLEVEL=3 CCACHE_INODECACHE=true

export ARCH="$(uname -m)"
export MAKEFLAGS="-j$(nproc)"

# NVIDIA
export __GL_THREADED_OPTIMIZATION=1
export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
export mesa_glthread=true

if command -v proton &>/dev/null; then
  export PROTON_ENABLE_WAYLAND=1
  export PROTON_NO_WM_DECORATION=1
  export PROTON_USE_NTSYNC=1
  unset PROTON_LOCAL_SHADER_CACHE

  # sudo pacman -S --noconform --needed vk-hdr-layer-kwin6-git
  # export PROTON_PREFER_SDL=1 PROTON_NO_STEAMINPUT=1 PROTON_ENABLE_HDR=1 ENABLE_HDR_WSI=1

  export LIBVA_DRIVER_NAME=nvidia
  export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
  export __GL_SHADER_DISK_CACHE_SIZE=12000000000
  export PROTON_DLSS_UPGRADE=1
  export PROTON_FSR4_UPGRADE=1
  export PROTON_XESS_UPGRADE=1

  #export PROTON_NVIDIA_LIBS=1
  export PROTON_NVIDIA_LIBS_NO_32BIT=1
  export PROTON_NVIDIA_NVENC=1
  export PROTON_NVIDIA_NVCUDA=1
  #export PROTON_NVIDIA_NVML=1
  #export PROTON_NVIDIA_NVOPTIX=1

  export PROTON_ENABLE_NGX_UPDATER=1
  export DXVK_NVAPI_DRS_NGX_DLSS_RR_OVERRIDE=on
  export DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE=on
  export DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE=on
  export DXVK_NVAPI_DRS_NGX_DLSS_RR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest
  export DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest
fi

if command -v wine &>/dev/null; then
  export WINE_NO_WM_DECORATION=1
  export WINE_PREFER_SDL_INPUT=1
fi
