#!/bin/bash
# Workaround for dbus fatal termination related coredumps (SIGABRT)
# https://github.com/ValveSoftware/steam-for-linux/issues/4464
export STEAM_RUNTIME=0 STEAM_RUNTIME_HEAVY=0 DBUS_FATAL_WARNINGS=0 PULSE_LATENCY_MSEC=20 SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0
# Override some libraries as these are what games linked against.
export LD_LIBRARY_PATH="/usr/lib/steam:/usr/lib32/steam${LD_LIBRARY_PATH:+:}$LD_LIBRARY_PATH"
# -compat-force-slr off disables the forced Scount runtime on all games
exec /usr/lib/steam/steam -no-cef-sandbox -compat-force-slr off -enable-features=WaylandWindowDecorations -window-system=wayland 
  -cef-disable-js-logging -nocrashmonitor "$@"
