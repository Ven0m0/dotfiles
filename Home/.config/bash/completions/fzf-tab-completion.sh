#!/usr/bin/env bash
# FZF Tab Completion - Unified & Optimized
# Combines fzf-simple-completion.sh + fzf-bash-tab-completion.sh
# Focus: speed, usability, minimal overhead

source "${HOME}/.local/lib/shell-common.sh" || {
  echo "Error: Failed to load shell-common.sh" >&2
  exit 1
}
set_c_locale

# ─── Config ───────────────────────────────────────────────────────────────────
export FZF_DEFAULT_OPTS="--bind=tab:down,btab:up --cycle"
export FZF_COMPLETION_OPTS="${FZF_COMPLETION_OPTS:---height 40% --reverse --ansi}"
export FZF_COMPLETION_PROMPT="${FZF_COMPLETION_PROMPT:-> }"
FZF_SEP=$'\x01'

# ─── Utils ────────────────────────────────────────────────────────────────────
has(){ command -v "$1" &>/dev/null; }
_fzf_cmd(){ __fzfcmd 2>/dev/null || echo fzf; }

# Cache tool lookups
[[ -z $_fzf_awk ]] && _fzf_awk=$(has mawk && echo mawk || echo awk)
[[ -z $_fzf_grep ]] && _fzf_grep=$(has rg && echo rg || echo grep)

bind '"\e[0n": redraw-current-line'

# ─── Core Parsing ─────────────────────────────────────────────────────────────
_fzf_shell_split(){
  local wordbreaks="$COMP_WORDBREAKS"
  wordbreaks="${wordbreaks//[]^]/\\&}"
  wordbreaks="${wordbreaks//[[:space:]]/}"
  $_fzf_grep -Eo \
    -e '\|+|&+|<+|>+' \
    -e '[;(){}&\|]' \
    -e '(\\.|\$[-[:alnum:]_*@#?$!]|(\$\{[^}]*(\}|$))|[^$\|"[:space:];(){}&<>'"'${wordbreaks}])+" \
    -e "\\\$'(\\\\.|[^'])*('|$)" \
    -e "'[^']*('|$)" \
    -e '"(\\.|\$($|[^(])|[^"$])*("|$)' \
    -e '".*' \
    -e '[[:space:]]+' \
    -e .
}

_fzf_parse_line(){
  _fzf_shell_split \
    | tr \\n \\0 \
    | sd -z '\x00\x00' '\x00' \
    | sd -z '\x00(\s*)$' '\n$1' \
    | sd -z '([^&\n\x00])&([^&\n\x00])' '$1\n&\n$2' \
    | sd -z '([\n\x00\z])([<>]+)([^\n\x00])' '$1$2\n$3' \
    | sd -z '([<>][\n\x00])$' '$1\n' \
    | sd -z '^(.*[\x00\n])?(\[\[|case|do|done|elif|else|esac|fi|for|function|if|in|select|then|time|until|while|&|;|&&|\|[|&]?)\x00' '' \
    | sd -z '^(\s*[\n\x00]|\w+=[^\n\x00]*[\n\x00])*' '' \
    | tr \\0 \\n
}

_fzf_unquote(){
  local line
  while IFS= read -r line; do
    if [[ $line =~ ^\'[^\']*\'?$ ]]; then
      line="${line%%"'"}"
      printf '%s\n' "${line:1}"
    elif [[ $line =~ ^\"(\\.|[^\"$])*\"?$ ]]; then
      sd '\\(.)' '$1' <<<"${line:1:-1}"
    elif [[ $line == *\\* && $line =~ ^(\\.|[a-zA-Z0-9_])*$ ]]; then
      sd '\\(.)' '$1' <<<"$line"
    else
      printf '%s\n' "$line"
    fi
  done
}

# ─── Compspec Resolver ────────────────────────────────────────────────────────
_fzf_compspec(){
  if [[ $2 =~ .*\$(\{?)([A-Za-z0-9_]*)$ ]]; then
    printf '%s\n' 'complete -F _fzf_complete_vars'
  elif [[ $COMP_CWORD == 0 && -z $2 ]]; then
    complete -p -E || { ! shopt -q no_empty_cmd_completion && printf '%s\n' 'complete -F _fzf_complete_cmds -E'; }
  elif [[ $COMP_CWORD == 0 ]]; then
    complete -p -I || printf '%s\n' 'complete -F _fzf_complete_cmds -I'
  else
    complete -p -- "$1" || complete -p -- "${1##*/}" || complete -p -D || printf '%s\n' 'complete -o filenames -F _fzf_fallback'
  fi
}

# ─── Fallback Completers ──────────────────────────────────────────────────────
_fzf_fallback(){
  if [[ $1 == \~* && $1 != */* ]]; then
    mapfile -t COMPREPLY < <(compgen -P '~' -u -- "${1#\~}")
  else
    mapfile -t COMPREPLY < <(compgen -f -- "$1")
  fi
}

_fzf_complete_cmds(){
  compopt -o filenames
  mapfile -t COMPREPLY < <(compgen -abc -- "$2")
}

_fzf_complete_vars(){
  if [[ $2 =~ .*\$(\{?)([A-Za-z0-9_]*)$ ]]; then
    local brace="${BASH_REMATCH[1]}" filter="${BASH_REMATCH[2]}"
    local prefix="${2::-${#filter}}"
    [[ -z $filter ]] && prefix="$2"
    mapfile -t COMPREPLY < <(compgen -v -P "$prefix" -S "${brace:+\}}" -- "$filter")
  fi
}

# ─── FZF Selector ─────────────────────────────────────────────────────────────
_fzf_selector(){
  local fzf="$(_fzf_cmd)"
  local height="${FZF_TMUX_HEIGHT:-40%}"

  # Auto-adjust height based on cursor pos
  if [[ -z $FZF_TMUX_HEIGHT && $fzf == fzf ]]; then
    printf '\e[6n' >/dev/tty
    local buf c
    until [[ $buf =~ $'\x1b'\[([0-9]+)\;[0-9]+R ]]; do
      read -rs -n1 c </dev/tty && buf+="$c"
    done
    (( LINES - BASH_REMATCH[1] > LINES * 4 / 10 )) && height="$(( LINES - BASH_REMATCH[1] ))"
  fi

  local lines=() REPLY
  while (( ${#lines[@]} < 2 )); do
    if IFS= read -r; then
      lines+=( "$REPLY" )
    elif (( ${#lines[@]} == 1 )); then
      printf '%s\n' "${lines[0]}"
      return
    else
      return 1
    fi
  done

  < <( (( ${#lines[@]} )) && printf '%s\n' "${lines[@]}"; cat) \
  FZF_DEFAULT_OPTS="--height $height --reverse $FZF_DEFAULT_OPTS $FZF_COMPLETION_OPTS" \
    "$fzf" -1 -0 --prompt "$FZF_COMPLETION_PROMPT$1" --nth=2 --with-nth=2,3 -d "$FZF_SEP" --ansi \
  | cut -d "$FZF_SEP" -f1
}

# ─── Colorize Files ───────────────────────────────────────────────────────────
_fzf_colorize(){
  local item
  while IFS= read -r item; do
    if [[ -e ${item/#\~/$HOME} ]]; then
      eza -dF --color=always "${item/#\~/$HOME}" 2>/dev/null || printf '%s\n' "$item"
    else
      printf '%s\n' "$item"
    fi
  done
}

# ─── Main Completion ──────────────────────────────────────────────────────────
_fzf_completion(){
  [[ $COMP_POINT -ne ${#COMP_LINE} ]] && return

  printf '\r\e[K\0337Loading...\0338'

  local raw_comp_words=() COMP_WORDS=() COMP_CWORD COMP_POINT COMP_LINE
  local COMP_TYPE=37 line="${READLINE_LINE:0:READLINE_POINT}"
  local wordbreaks="$COMP_WORDBREAKS"
  wordbreaks="${wordbreaks//[]^]/\\&}"
  wordbreaks="${wordbreaks//[[:space:]]/}"

  [[ $line =~ [^[:space:]] ]] && mapfile -t raw_comp_words < <(_fzf_parse_line <<<"$line")

  mapfile -t COMP_WORDS < <(printf '%s\n' "${raw_comp_words[@]}" | _fzf_unquote)
  printf -v COMP_LINE '%s' "${COMP_WORDS[@]}"
  COMP_POINT="${#COMP_LINE}"

  # Clean empty words
  local i
  for (( i=${#COMP_WORDS[@]}-2; i>=0; i-- )); do
    [[ ! ${COMP_WORDS[i]} =~ [^[:space:]] ]] && COMP_WORDS=( "${COMP_WORDS[@]:0:i}" "${COMP_WORDS[@]:i+1}" )
  done

  [[ ${#COMP_WORDS[@]} == 0 ]] && COMP_WORDS+=( '' )
  [[ ! ${COMP_WORDS[${#COMP_WORDS[@]}-1]} =~ [^[:space:]] ]] && COMP_WORDS[${#COMP_WORDS[@]}-1]=''

  COMP_CWORD="${#COMP_WORDS[@]}"
  (( COMP_CWORD-- ))

  local cmd="${COMP_WORDS[0]}" cur="${COMP_WORDS[COMP_CWORD]}" prev
  [[ $COMP_CWORD == 0 ]] && prev= || prev="${COMP_WORDS[COMP_CWORD-1]}"
  [[ $cur =~ ^[$wordbreaks]$ ]] && cur=
  local raw_cur="${cur:+${raw_comp_words[-1]}}"

  local COMPREPLY=
  _fzf_completer "$cmd" "$cur" "$prev"

  if [[ -n $COMPREPLY ]]; then
    [[ -n $raw_cur ]] && line="${line::-${#raw_cur}}"
    READLINE_LINE="${line}${COMPREPLY}${READLINE_LINE:$READLINE_POINT}"
    (( READLINE_POINT+=${#COMPREPLY} - ${#raw_cur} ))
  fi

  printf '\r\e[K'
}

# ─── Completer ────────────────────────────────────────────────────────────────
_fzf_completer(){
  { complete -p -- "$1" || __load_completion "$1"; } &>/dev/null
  local compspec
  compspec="$(_fzf_compspec "$@" 2>/dev/null)" || return

  eval "compspec=( $compspec )"
  set -- "${compspec[@]}"
  shift

  local compl_function compl_filenames=0 compl_nospace=0
  while (( $# > 1 )); do
    case "$1" in
      -F) compl_function="$2"; shift ;;
      -o) [[ $2 == filenames ]] && compl_filenames=1
          [[ $2 == nospace ]] && compl_nospace=1
          shift ;;
      *) shift ;;
    esac
    shift
  done

  local COMPREPLY=()
  [[ -n $compl_function ]] && "$compl_function" "$@" &>/dev/null

  local result
  result=$( (
    if (( ${#COMPREPLY[@]} )); then
      printf '%s\n' "${COMPREPLY[@]}"
    else
      compgen -f -- "$2"
    fi
  ) | LC_ALL=C sort -u | _fzf_colorize | _fzf_selector "$1" "$2" "$3" )

  [[ -n $result ]] || return 1
  result="${result// /}"
  COMPREPLY="$result"
  [[ $compl_nospace != 1 ]] && COMPREPLY="$COMPREPLY "
  [[ $compl_filenames == 1 && $COMPREPLY =~ /$ ]] && COMPREPLY="${COMPREPLY% } "
}

# ─── Key Binding ──────────────────────────────────────────────────────────────
bind -x '"\t": _fzf_completion'
bind 'set completion-ignore-case on'

reset_locale
