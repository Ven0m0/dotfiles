#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
export LC_ALL=C LANG=C

has(){ command -v "$1" &>/dev/null; }
die(){ printf 'priv: %s\n' "$*" >&2; exit 1; }

usage(){
  cat <<'EOF'
priv - Privilege escalation wrapper (doas/sudo)

USAGE:
  priv COMMAND [ARGS...]

COMMANDS:
  edit FILE...        Edit files as root (doasedit)
  sudo [OPTS] CMD    Doas-based sudo shim
  -h, --help         Show help

EDIT:
  Uses unprivileged $EDITOR to edit root files safely.
  Validates doas. conf syntax.

SUDO SHIM:
  Translates sudo options to doas equivalents.
  Supports: -i, -n, -s, -u, -k, -v

EXAMPLES:
  priv edit /etc/doas.conf
  priv sudo -u nobody whoami
  priv sudo -i

DEPENDENCIES:
  doas (required)
  $EDITOR or vi (for edit)
EOF
}

# ============================================================================
# EDIT
# ============================================================================
cmd_edit(){
  [[ ${#} -eq 0 ]] && die "Usage: priv edit FILE..."
  local user_id=$(id -u)
  [[ $user_id -eq 0 ]] && die "Using as root not permitted"

  for editor_cmd in "$DOAS_EDITOR" "$VISUAL" "$EDITOR"; do
    [[ -n $editor_cmd ]] && break
  done
  [[ -z $editor_cmd ]] && editor_cmd=vi
  has "$editor_cmd" || die "Invalid editor: $editor_cmd"

  local tmpdir=$(mktemp -dt 'priv-edit-XXXXXX')
  trap 'rm -rf "$tmpdir"' EXIT

  for file; do
    local dir=$(dirname -- "$file")
    local tmpfile="${tmpdir}/${file##*/}"
    printf '' | tee "$tmpfile" >/dev/null
    chmod 0600 "$tmpfile"

    if [[ -f $file ]]; then
      if [[ -r $file ]]; then
        cat -- "$file" >"$tmpfile"
      else
        doas cat -- "$file" >"$tmpfile" || die "Permission denied: $file"
      fi
    fi

    "$editor_cmd" "$tmpfile"

    # Validate doas.conf
    if [[ $file =~ ^/etc/doas(\. d/.*)?\. conf$ ]]; then
      doas -C "$tmpfile" || die "Invalid doas.conf syntax"
    fi

    if [[ -w $file ]]; then
      dd status=none if="$tmpfile" of="$file"
    else
      doas dd status=none if="$tmpfile" of="$file" || die "Write failed: $file"
    fi
  done
}

# ============================================================================
# SUDO SHIM
# ============================================================================
cmd_sudo(){
  has getopt || die "getopt required"
  local opts=$(getopt -n priv-sudo -o +insu:kvh -l login,non-interactive,shell,user:,reset-timestamp,validate,help -- "$@") || die "Invalid options"
  eval set -- "$opts"

  local flag_i= flag_n= flag_s= flag_k= user=
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i|--login) flag_i='-i'; shift ;;
      -n|--non-interactive) flag_n='-n'; shift ;;
      -s|--shell) flag_s='-s'; shift ;;
      -u|--user) user=${2#\#}; shift 2 ;;
      -k|--reset-timestamp) flag_k='-L'; shift ;;
      -v|--validate) flag_s="true"; shift ;;
      -h|--help) usage; exit 0 ;;
      --) shift; break ;;
    esac
  done

  [[ -n $flag_i && -n $flag_s ]] && die "Cannot use -i and -s together"

  _doas(){ exec doas "$flag_n" "${user:+-u "$user"}" "$@"; }
  user_shell(){ has getent && getent passwd "${user:-root}" | awk -F: 'END{print $NF? $NF:"sh"}' || awk -F: '$1=="'"${user:-root}"'"{print $NF;m=1}END{if(! m)print"sh"}' /etc/passwd; }

  export SUDO_GID=$(id -g) SUDO_UID=$(id -u) SUDO_USER=$(id -un)

  if [[ $# -eq 0 ]]; then
    if [[ -n $flag_i ]]; then
      _doas -- "$(user_shell)" -c 'cd "$HOME"; exec "$0" -l'
    elif [[ -n $flag_k ]]; then
      exec doas "$flag_k" "${user:+-u "$user"}"
    else
      _doas "$flag_s"
    fi
  elif [[ -n $flag_i ]]; then
    _doas -- "$(user_shell)" -l -c 'cd "$HOME"; "$0" "$@"' "$@"
  elif [[ -n $flag_s ]]; then
    _doas -- "${SHELL:-$(user_shell)}" -c '"$0" "$@"' "$@"
  else
    _doas -- "$@"
  fi
}

# ============================================================================
# MAIN
# ============================================================================
main(){
  local cmd="${1:-}"
  shift || :
  case "$cmd" in
    edit|e) cmd_edit "$@" ;;
    sudo|s) cmd_sudo "$@" ;;
    -h|--help|help|"") usage ;;
    *) die "Unknown: $cmd" ;;
  esac
}

main "$@"
