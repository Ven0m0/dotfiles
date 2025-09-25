#!/usr/bin/env bash
# Copyright (c) 2009 rupa deadwyler. Licensed under the WTFPL license, Version 2.
# https://github.com/rupa/z

_z(){
  # --- Configuration ---
  # All settings are environment-driven. Defaults are set if variables are unbound.
  local datafile="${_Z_DATA:-$HOME/.z}"
  local max_score="${_Z_MAX_SCORE:-9000}"
  # --- Guards ---
  # Ensure datafile is not a directory.
  [[ -d "$datafile" ]] && { printf "z.sh: ERROR: datafile (%s) is a directory.\n" "$datafile" >&2; return 1; }
  # If symlink, dereference.
  [[ -h "$datafile" ]] && datafile="$(readlink "$datafile")"
  # Bail if datafile exists and we don't own it, unless _Z_OWNER is set.
  [[ -z "$_Z_OWNER" && -f "$datafile" && ! -O "$datafile" ]] && return

  # --- Internal Functions ---
  # Safely reads and filters the database, yielding only existing directories.
  _z_db(){
    [[ ! -f "$datafile" ]] && return
    # Use awk for a single-pass filter. It's faster than a shell `while read` loop.
    <"$datafile" awk -F'|' '
      # system() is slow, so we cache results for common parent paths.
      function is_dir(path,   base) {
        if (path in dir_cache) return dir_cache[path]
        base = path
        sub("/[^/]+/?$", "", base)
        if (base in dir_cache && !dir_cache[base]) {
          return dir_cache[path] = 0
        }
        # The stat command is a single external call that tells us if the path is a directory.
        # We use a simple "d" or "f" output to avoid parsing complex stat output.
        "stat -c %F \"" path "\" 2>/dev/null | grep -q directory"
        return dir_cache[path] = (system(":") == 0)
      }
      is_dir($1) { print }
    '
  }

  # Add/update a directory entry.
  _z_add(){
    local path="$1"
    local tempfile="$datafile.$RANDOM"
    local now
    printf -v now '%(%s)T' -1
    # Don't track trivial paths or excluded directories.
    [[ "$path" == "$HOME" || "$path" == "/" ]] && return
    if (( ${#_Z_EXCLUDE_DIRS[@]} > 0 )); then
      local exclude
      for exclude in "${_Z_EXCLUDE_DIRS[@]}"; do
        [[ "$path" == "$exclude"* ]] && return
      done
    fi

    # The awk script is the heart of z.sh. It updates ranks and ages old entries.
    _z_db | awk -v path="$path" -v now="$now" -v score="$max_score" -F'|' '
      BEGIN {
        rank[path] = 1
        time[path] = now
      }
      $1 == path {
        rank[$1] = $2 + 1
        time[$1] = now
        next
      }
      $2 >= 1 {
        rank[$1] = $2
        time[$1] = $3
      }
      END {
        # Aging logic: if total rank > max_score, reduce all ranks.
        for(x in rank) total_rank += rank[x]
        if (total_rank > score) {
          for(x in rank) print x "|" 0.99 * rank[x] "|" time[x]
        } else {
          for(x in rank) print x "|" rank[x] "|" time[x]
        }
      }
    ' > "$tempfile"

    # Atomic and safe file update.
    if [[ $? -eq 0 && -s "$tempfile" ]]; then
      [[ -n "$_Z_OWNER" ]] && chown "$_Z_OWNER:$(id -ng "$_Z_OWNER")" "$tempfile"
      mv -f "$tempfile" "$datafile"
    else
      rm -f "$tempfile"
    fi
  }

  # Handles finding and jumping to a directory.
  _z_jump(){
    local list=0 echo=0 typ args
    local -a fnd
    while (( $# > 0 )); do
      case "$1" in
        -h) printf "%s [-cdehlrtx] args\n" "${_Z_CMD:-z}" >&2; return;;
        -l) list=1;;
        -e) echo=1;;
        -r) typ="rank";;
        -t) typ="recent";;
        -c) fnd+=("^$PWD");;
        -x)
          local tmp
          tmp=$(mktemp)
          grep -v "^${PWD}|" "$datafile" > "$tmp" && mv "$tmp" "$datafile"
          return;;
        *) fnd+=("$1");;
      esac
      shift
    done
    # If no search terms, default to listing.
    (( ${#fnd[@]} == 0 )) && list=1
    # If only arg was `-c`, list subdirs.
    [[ "${fnd[*]}" == "^$PWD" ]] && list=1
    # Join search terms into a regex.
    (IFS='.*'; args="${fnd[*]}")
    # No datafile, nothing to do.
    [[ ! -f "$datafile" ]] && return 1
    local now
    printf -v now '%(%s)T' -1
    local cd_to
    cd_to="$(_z_db | awk -v t="$now" -v list="$list" -v typ="$typ" -v q="$args" -F'|' '
      function frecent(rank, time){
        # The "frecency" algorithm.
        # Combines frequency (rank) and recency (time).
        local dx = t - time
        # Halflife of 40000 seconds (11 hours)
        return int(10000 * rank / (1 + 0.000025 * dx))
      }
      function output(matches, best_match){
        if (list) {
          cmd = "sort -nr >&2"
          for (x in matches) {
            printf "%-10s %s\n", matches[x], x | cmd
          }
          close(cmd)
        } else {
          print best_match
        }
      }
      BEGIN { hi_rank = -1 }
      {
        if (typ == "rank") rank = $2
        else if (typ == "recent") rank = $3
        else rank = frecent($2, $3)
        # Match case-insensitively, but prefer case-sensitive matches.
        # A case-sensitive match gets a x10 rank bonus.
        if (tolower($1) ~ tolower(q)) {
          if ($1 ~ q) rank *= 10
          matches[$1] = rank
          if (rank > hi_rank) {
            best_match = $1
            hi_rank = rank
          }
        }
      }
      END {
        if (best_match) output(matches, best_match)
        else exit 1
      }
    ')"

    if (( $? == 0 && -n "$cd_to" )); then
      if (( echo )); then
        printf "%s\n" "$cd_to"
      else
        cd "$cd_to"
      fi
    fi
  }

  # --- Dispatcher ---
  case "$1" in
    # Run in background to not slow down the prompt
    --add) shift; ( _z_add "$@" & );;
    # Tab completion
    --complete)
      local query="${2#* }"
      _z_db | awk -F'|' -v q="$query" '
        tolower($1) ~ tolower(q) {
          sub(".*/", "", $1); print $1
        }
      ';;
    *) _z_jump "$@";;
  esac
}

# --- Shell Integration ---
_z_install(){
  local cmd="${_Z_CMD:-z}"
  alias "$cmd"='_z 2>&1'
  # ZSH setup
  if [[ -n "$ZSH_VERSION" ]]; then
    if [[ -z "$_Z_NO_PROMPT_COMMAND" ]]; then
      # Use an anonymous function for cleaner precmd array
      _z_precmd_hook(){ _z --add "${PWD:A}"; }
      # Add hook if not already present
      [[ -n "${precmd_functions[(r)_z_precmd_hook]}" ]] || { precmd_functions+=( _z_precmd_hook ); }
    fi
    # ZSH completion
    _z_zsh_tab_complete(){ reply=(${(f)"$(_z --complete "$REPLY")"}); }
    compctl -K _z_zsh_tab_complete "$cmd"

  # BASH setup
  elif [[ -n "$BASH_VERSION" ]]; then
    if [[ -z "$_Z_NO_PROMPT_COMMAND" ]]; then
      # Add hook to PROMPT_COMMAND if not already present.
      case "$PROMPT_COMMAND" in
        *_z_bash_prompt_command*) ;;
        *) PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}_z_bash_prompt_command" ;;
      esac
    fi
    # BASH completion
    complete -o nospace -C '_z --complete "$COMP_LINE"' "$cmd"
  fi
}

_z_bash_prompt_command(){ _z --add "$(pwd -P)"; }
# Run installation
_z_install
