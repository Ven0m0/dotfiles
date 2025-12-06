#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
# gamerun - Unified game/program launcher with optimized graphics profiles
# Usage: gamerun [PROFILE] [ENV=val... ] <program> [args...]
# Profiles:
#   sarek       Performance profile with DXVK/VKD3D tweaks (default)
#   skth        Sarek variant (alias)
#   glthread    OpenGL threading optimizations only
#   software    Force software rendering (CPU)
#   default     No tweaks, pass-through
# Example: gamerun sarek wine game. exe
#          gamerun glthread MESA_DEBUG=1 glxgears
#          gamerun software blender
BLD=$'\e[1m' GRN=$'\e[32m' BLU=$'\e[34m' YLW=$'\e[33m' DEF=$'\e[0m'
log(){ printf '%b==>\e[0m %s\n' "${BLD}${BLU}" "$*"; }
warn(){ printf '%b==> WARN:\e[0m %s\n' "${BLD}${YLW}" "$*"; }
die(){
  printf '%b==> ERROR:\e[0m %s\n' "${BLD}${YLW}" "$*" >&2
  exit "${2:-1}"
}
profile=sarek
set_sarek(){
  log "Profile: Sarek (Performance/DXVK)"
  export WINEDEBUG="-all"
  export DXVK_LOG_LEVEL="none" VKD3D_DEBUG="none" VKD3D_SHADER_DEBUG="none"
  export __GL_SHADER_DISK_CACHE="1"
  export __GL_SHADER_DISK_CACHE_SIZE="2147483648"
  export MESA_SHADER_CACHE_DISABLE="false"
  export MESA_SHADER_CACHE_MAX_SIZE="2097152K"
  export __GL_IGNORE_GLSL_EXT_REQS="1"
  export MESA_GL_VERSION_OVERRIDE="4.6"
  export MESA_GLSL_VERSION_OVERRIDE="460"
  export MESA_VK_VERSION_OVERRIDE="1.4"
  export __GL_SYNC_TO_VBLANK="0"
  export __GL_OpenGLImageSettings="3"
  export __GL_FSAA_MODE="0"
  export __GL_ALLOW_FXAA_USAGE="0"
  export __GL_LOG_MAX_ANISO="0"
  export __GL_VRR_ALLOWED="0"
  export MESA_NO_ERROR="true" MESA_NO_DITHER="1"
  export vblank_mode="0"
  export MESA_EXTENSION_OVERRIDE="-GL_EXT_framebuffer_multisample -GL_EXT_framebuffer_multisample_blit_scaled -GL_EXT_texture_filter_anisotropic"
  export __GL_THREADED_OPTIMIZATIONS="1"
  export mesa_glthread="true"
  export DXVK_CONFIG="dxgi.syncInterval=0;d3d9.presentInterval=0;d3d11.maxTessFactor=8;d3d11.relaxedBarriers=True;d3d11.ignoreGraphicsBarriers=True;d3d11. samplerAnisotropy=0;d3d9.samplerAnisotropy=0;d3d9.maxAvailableMemory=4096;dxgi.maxFrameLatency=1"
  export DXVK_ASYNC="1"
  export DXVK_STATE_CACHE_PATH="${XDG_CACHE_HOME:-$HOME/.cache}/dxvk"
  export MESA_VK_WSI_PRESENT_MODE="immediate"
}
set_glthread(){
  log "Profile: GLThread (OpenGL threading)"
  export __GL_THREADED_OPTIMIZATIONS="1" mesa_glthread="true"
}
set_software(){
  log "Profile: Software (CPU rendering)"
  export LIBGL_ALWAYS_SOFTWARE="1" __GLX_VENDOR_LIBRARY_NAME="mesa" \
    VK_ICD_FILENAMES="/usr/share/vulkan/icd. d/lvp_icd.x86_64.json"
}
set_default(){ log "Profile: Default (no tweaks)"; }
main(){
  [[ $# -eq 0 ]] && die "Usage: gamerun [PROFILE] [ENV=val...] <program> [args...]"
  case ${1:-} in
  sarek | skth | skthrun | sarekrun)
    profile=sarek
    shift
    ;;
  glthread)
    profile=glthread
    shift
    ;;
  software | softwarerun)
    profile=software
    shift
    ;;
  default)
    profile=default
    shift
    ;;
  -h | --help)
    printf 'Usage: %s [PROFILE] [ENV=val...] <program> [args...]\n' "$0" >&2
    printf 'See script header for profiles\n' >&2
    exit 0
    ;;
  esac
  case $profile in
  sarek) set_sarek ;;
  glthread) set_glthread ;;
  software) set_software ;;
  default) set_default ;;
  esac
  while [[ ${1:-} =~ = ]]; do
    log "Custom env: $1"
    export "$1"
    shift
  done
  [[ $# -eq 0 ]] && die "No program specified"
  log "Exec: $*"
  exec "$@"
}
main "$@"
