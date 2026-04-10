status -i >/dev/null 2>&1 || return

# XDG
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_STATE_HOME "$HOME/.local/state"

if [ $XDG_SESSION_TYPE = wayland ]
    set -gx SDL_VIDEODRIVER wayland
    set -gx QT_QPA_PLATFORM wayland
    set -gx GDK_BACKEND wayland
    set -gx QT_QPA_PLATFORMTHEME qt6ct
    set -gx MOZ_ENABLE_XINPUT2 1
    set -gx MOZ_ENABLE_WAYLAND 1
end

# JetBrains IDE
set -gx _JAVA_OPTIONS '-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true'
