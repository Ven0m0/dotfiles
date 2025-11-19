#!/bin/sh
LC_ALL=C LANG=C.UTF-8
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-~/.config}
ELECTRON_LAUNCH_FLAGS="--enable-source-maps --ozone-platform-hint=auto"
# Allow users to override command-line options
if [ -f "$XDG_CONFIG_HOME/vesktop-flags.conf" ]; then
    VESKTOP_USER_FLAGS="$(grep -v '^#' "$XDG_CONFIG_HOME/vesktop-flags.conf")"
fi

# Launch (each word in VESKTOP_USER_FLAGS must be split)
# shellcheck disable=SC2086
exec /usr/lib/vesktop/vesktop $VESKTOP_USER_FLAGS "$@"
