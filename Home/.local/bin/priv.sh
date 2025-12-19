#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar
export LC_ALL=C; IFS=$'\n\t'
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
has(){ command -v -- "$1" &>/dev/null; }
sleepy(){ read -rt "${1:-1}" -- <> <(:) &>/dev/null || :; }
die(){ printf 'priv: %s\n' "$*" >&2; exit 1; }
usage(){
  cat <<'EOF'
priv - Privilege escalation wrapper
USAGE: priv COMMAND [ARGS...]
COMMANDS:
  edit FILE...        Edit files as root (validates doas configs in loop)
  sudo [OPTS] CMD     Doas-based sudo shim
  -h, --help          Show help
EDIT:
  - Uses unprivileged $EDITOR (or doas if needed)
  - Validates doas.conf syntax (loops until valid)
  - Works as root or non-root
  - Auto-detects: /etc/doas.conf /etc/doas.d/*.conf
SUDO: Translates sudo to doas (-i, -n, -s, -u, -k, -v)
EXAMPLES:
  priv edit /etc/doas.conf        # Loop validation
  priv edit /etc/hosts            # Single validation
  priv sudo -u nobody whoami
EOF
}
cmd_edit(){
  [[ ${#} -eq 0 ]] && die "Usage: priv edit FILE..."
  local user_id=$(id -u) editor_cmd
  for editor_cmd in "$DOAS_EDITOR" "$VISUAL" "$EDITOR" nano vim vi; do has "$editor_cmd" && break; done
  has "$editor_cmd" || die "No editor found (set \$EDITOR or \$DOAS_EDITOR)"
  local tmpdir=$(mktemp -dt 'priv-edit-XXXXXX')
  trap 'rm -rf "$tmpdir"' EXIT HUP QUIT TERM INT ABRT
  for file; do
    local tmpfile="${tmpdir}/${file##*/}" is_doas=0
    [[ $file =~ ^/etc/doas(\.d/.*)?\.conf$ ]] && is_doas=1
    : >"$tmpfile"; chmod 0600 "$tmpfile"
    if [[ -f $file ]]; then
      if [[ -r $file ]]; then
        cat -- "$file" >"$tmpfile"
      else
        ((user_id==0)) && cat -- "$file" >"$tmpfile" || doas cat -- "$file" >"$tmpfile" || die "Permission denied: $file"
      fi
    fi
    "$editor_cmd" "$tmpfile"
    if ((is_doas)); then
      while ! doas -C "$tmpfile"; do
        printf 'vidoas: Syntax Error! Reopening in 3s...\n' >&2
        sleepy 3
        "$editor_cmd" "$tmpfile"
      done
    fi
    if [[ -w $file ]]; then
      dd status=none if="$tmpfile" of="$file"
    else
      ((user_id==0)) && dd status=none if="$tmpfile" of="$file" || doas dd status=none if="$tmpfile" of="$file" || die "Write failed: $file"
    fi
    ((is_doas)) && { chown root:root "$file" 2>/dev/null || doas chown root:root "$file"; chmod 0400 "$file" 2>/dev/null || doas chmod 0400 "$file"; }
    printf 'priv: %s: updated\n' "$file"
  done
}
cmd_sudo(){
  local flag_i= flag_n= flag_s= flag_k= user=
  local -a args=()
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
      -*) die "Unknown option: $1" ;;
      *) args+=("$1"); shift ;;
    esac
  done
  set -- "${args[@]}" "$@"
  [[ -n $flag_i && -n $flag_s ]] && die "Cannot use -i and -s together"
  _doas(){ exec doas "$flag_n" "${user:+-u "$user"}" "$@"; }
  user_shell(){ has getent && getent passwd "${user:-root}"|awk -F: 'END{print $NF?$NF:"sh"}' || awk -F: '$1=="'"${user:-root}"'"{print $NF;m=1}END{if(!m)print"sh"}' /etc/passwd; }
  export SUDO_GID=$(id -g) SUDO_UID=$(id -u) SUDO_USER=$(id -un)
  if [[ $# -eq 0 ]]; then
    [[ -n $flag_i ]] && _doas -- "$(user_shell)" -c 'cd "$HOME";exec "$0" -l'
    [[ -n $flag_k ]] && exec doas "$flag_k" "${user:+-u "$user"}"
    _doas "$flag_s"
  elif [[ -n $flag_i ]]; then
    _doas -- "$(user_shell)" -l -c 'cd "$HOME";"$0" "$@"' "$@"
  elif [[ -n $flag_s ]]; then
    _doas -- "${SHELL:-$(user_shell)}" -c '"$0" "$@"' "$@"
  else
    _doas -- "$@"
  fi
}
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
