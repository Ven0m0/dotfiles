#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
LC_ALL=C LANG=C

env OBS_USE_EGL=1 OBS_VKCAPTURE=1 obs
