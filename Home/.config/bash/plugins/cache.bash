command -v sccache &>/dev/null && export RUSTC_WRAPPER=sccache
command -v buildcache &>/dev/null && export BUILDCACHE_COMPRESS_FORMAT=ZSTD BUILDCACHE_DIRECT_MODE=true
command -v ccache &>/dev/null && export CCACHE_COMPRESS=true CCACHE_COMPRESSLEVEL=3 CCACHE_INODECACHE=true

if command -v go &>/dev/null; then
  CGO_ENABLED=0
  GOOS=linux
  GOARCH=amd64
fi

# Java
export JAVA_OPTIONS="-Xmx2G -Dfile.encoding=UTF-8 -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -XX:+IgnoreUnrecognizedVMOptions -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions"
# export JAVA_HOME=""

CC=clang
CC=clang++
AR=llvm-ar
NM=llvm-nm
OBJCOPY=llvm-objcopy
OBJDUMP=llvm-objdump
STRIP=llvm-strip

ARCH="$(uname -m)"
SHELL=/bin/bash

MAKEFLAGS="-j$(nproc)"

# Rust-parallel
command -v rust-parallel &>/dev/null && export PROGRESS_STYLE=simple

# Homebrew
export HOMEBREW_NO_ANALYTICS=true

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
