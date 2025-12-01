status -i >/dev/null 2>&1 || return

# XDG
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_STATE_HOME "$HOME/.local/state"

# Fzf
set -Ux FZF_LEGACY_KEYBINDINGS 0

if [ $XDG_SESSION_TYPE = wayland ]
    set -x SDL_VIDEODRIVER wayland
    set -x QT_QPA_PLATFORM wayland
    set -x GDK_BACKEND wayland
    set -gx QT_QPA_PLATFORMTHEME qt6ct
    set -x MOZ_ENABLE_XINPUT2 1
    set -x MOZ_ENABLE_WAYLAND 1
end

# JetBrains IDE
set -gx _JAVA_OPTIONS '-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true'
