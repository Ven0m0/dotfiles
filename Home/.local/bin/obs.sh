#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
LC_ALL=C LANG=C

OBS_USE_EGL=1 obs
