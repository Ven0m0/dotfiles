#!/usr/bin/env bash
# Only run for interactive shells
[[ $- != *i* ]] && return

#============================== [Framework Init] ==============================
export BASH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bash"
export BASH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/bash"

# Ensure core directories exist
mkdir -p "$BASH_CONFIG_DIR"/{lib,plugins,functions} "$BASH_CACHE_DIR"

# Load core libraries
. "${BASH_CONFIG_DIR}/lib/helpers.bash"
. "${BASH_CONFIG_DIR}/lib/lazy.bash"
. "${BASH_CONFIG_DIR}/lib/async.bash"

# Load plugins (sourced in order by filename)
shopt -s nullglob globstar
for plugin in "${BASH_CONFIG_DIR}/plugins/"*.{bash,sh}; do
	. "$plugin"
done
unset plugin

# Load completions
ifsource "${BASH_CONFIG_DIR}/completer.sh"

# Initialize lazy-loaded functions
lazy_init "${BASH_CONFIG_DIR}/functions"

# Run async post-startup tasks
async_exec path_dedupe
async_exec welcome_fetch

# Cleanup
unset -f lazy_init lazy_build_cache lazy_fn async_exec welcome_fetch path_dedupe
