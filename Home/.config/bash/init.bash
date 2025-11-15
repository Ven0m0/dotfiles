#!/usr/bin/env bash
[[ $- != *i* ]] && return
shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C 
#============================== [Framework Init] ==============================
export BASH_CONFIG_DIR="${XDG_CONFIG_HOME}/bash" BASH_CACHE_DIR="${XDG_CACHE_HOME}/bash"
# --- Ensure Core Directories Exist
mkdir -p "${BASH_CONFIG_DIR}/{lib,plugins,functions}" "$BASH_CACHE_DIR"

# --- Load Core Libraries
. "${BASH_CONFIG_DIR}/lib/helpers.bash"
. "${BASH_CONFIG_DIR}/lib/lazy.bash"
. "${BASH_CONFIG_DIR}/lib/async.bash"

# --- Load Plugins
# Plugins are sourced in order. Naming convention 'NN-name.bash' controls load order.
for plugin in "${BASH_CONFIG_DIR}/plugins/"*.{bash,sh}; do . "$plugin"; done; unset $plugin

# --- Completions
ifsource ~/.config/bash/completer.sh
ifsource ~/.config/bash/completions/fzf-completion.sh

# --- Initialize Lazy Loading for Functions
# Scans function directories and creates stubs for on-demand loading.
lazy_init "${BASH_CONFIG_DIR}/functions"

# --- Asynchronous Post-Startup Tasks
# These run in the background after the prompt is ready.
async_exec path_dedupe # Deduplicates PATH variable.
async_exec welcome_fetch # Displays welcome message (e.g., hyfetch).

# --- Final Cleanup
# Unset functions that are no longer needed.
unset -f lazy_init lazy_build_cache lazy_fn plugin_source async_exec welcome_fetch path_dedupe
