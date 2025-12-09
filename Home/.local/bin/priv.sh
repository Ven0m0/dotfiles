#!/usr/bin/env bash
set -euo pipefail;shopt -s nullglob globstar;IFS=$'\n\t';LC_ALL=C;LANG=C
has(){ command -v "$1" &>/dev/null;}
die(){ printf 'priv: %s\n' "$*" >&2;exit 1;}
usage(){
  cat <<'EOF'
priv - Privilege escalation wrapper (doas/sudo/vidoas)
USAGE: priv COMMAND [ARGS...]
COMMANDS:
  edit FILE...        Edit files as root (doasedit)
  vidoas [FILE]       Safely edit doas.conf with validation (like visudo)
  sudo [OPTS] CMD     Doas-based sudo shim
  -h, --help          Show help
EDIT: Uses unprivileged $EDITOR to edit root files safely
VIDOAS: Root-only, validates syntax in loop until correct (default: /etc/doas.conf)
SUDO: Translates sudo options to doas (-i, -n, -s, -u, -k, -v)
EXAMPLES:
  priv edit /etc/hosts
  priv vidoas
  priv vidoas /etc/doas.d/custom.conf
  priv sudo -u nobody whoami
EOF
}
cmd_edit(){
  [[ ${#} -eq 0 ]] && die "Usage: priv edit FILE..."
  [[ $(id -u) -eq 0 ]] && die "Using as root not permitted"
  for editor_cmd in "$DOAS_EDITOR" "$VISUAL" "$EDITOR";do [[ -n $editor_cmd ]] && break;done
  [[ -z $editor_cmd ]] && editor_cmd=vi
  has "$editor_cmd"||die "Invalid editor: $editor_cmd"
  local tmpdir=$(mktemp -dt 'priv-edit-XXXXXX')
  trap 'rm -rf "$tmpdir"' EXIT
  for file;do
    local tmpfile="${tmpdir}/${file##*/}"
    : >"$tmpfile";chmod 0600 "$tmpfile"
    if [[ -f $file ]];then [[ -r $file ]] && cat -- "$file" >"$tmpfile"||doas cat -- "$file" >"$tmpfile"||die "Permission denied: $file";fi
    "$editor_cmd" "$tmpfile"
    [[ $file =~ ^/etc/doas(\.d/.*)?\.conf$ ]] && { doas -C "$tmpfile"||die "Invalid doas.conf syntax";}
    [[ -w $file ]] && dd status=none if="$tmpfile" of="$file"||doas dd status=none if="$tmpfile" of="$file"||die "Write failed: $file"
  done
}
cmd_vidoas(){
  [[ $(id -u) -ne 0 ]] && die "Must be root (like visudo)"
  local conf="${1:-/etc/doas.conf}" tmp tmpcopy
  [[ ! -f $conf ]] && die "Not found: $conf"
  [[ ! $conf =~ ^/etc/doas(\.d/.*)?\.conf$ ]] && die "Invalid doas config path: $conf"
  for editor_cmd in "$DOAS_EDITOR" "$EDITOR" nano vim vi;do has "$editor_cmd" && break;done
  has "$editor_cmd"||die "No editor found (set \$EDITOR or \$DOAS_EDITOR)"
  tmp=$(mktemp);tmpcopy=$(mktemp)
  trap 'rm -f "$tmp" "$tmpcopy"' EXIT HUP QUIT TERM INT ABRT
  cat "$conf" >"$tmp";cat "$tmp" >"$tmpcopy"
  "$editor_cmd" "$tmp"
  while ! doas -C "$tmp";do
    printf 'Syntax Error! Reopening in 3s...\n' >&2
    sleep 3;"$editor_cmd" "$tmp"
  done
  if cmp -s "$tmp" "$tmpcopy";then
    printf 'vidoas: %s: unchanged\n' "$conf"
  else
    chown root:root "$tmp";chmod 0400 "$tmp";cp -fp "$tmp" "$conf"
    printf 'vidoas: %s: updated\n' "$conf"
  fi
}
cmd_sudo(){
  has getopt||die "getopt required"
  local opts=$(getopt -n priv-sudo -o +insu:kvh -l login,non-interactive,shell,user:,reset-timestamp,validate,help -- "$@")||die "Invalid options"
  eval set -- "$opts"
  local flag_i= flag_n= flag_s= flag_k= user=
  while [[ $# -gt 0 ]];do
    case "$1" in
      -i|--login) flag_i='-i';shift;;
      -n|--non-interactive) flag_n='-n';shift;;
      -s|--shell) flag_s='-s';shift;;
      -u|--user) user=${2#\#};shift 2;;
      -k|--reset-timestamp) flag_k='-L';shift;;
      -v|--validate) flag_s="true";shift;;
      -h|--help) usage;exit 0;;
      --) shift;break;;
    esac
  done
  [[ -n $flag_i && -n $flag_s ]] && die "Cannot use -i and -s together"
  _doas(){ exec doas "$flag_n" "${user:+-u "$user"}" "$@";}
  user_shell(){ has getent && getent passwd "${user:-root}"|awk -F: 'END{print $NF?$NF:"sh"}'||awk -F: '$1=="'"${user:-root}"'"{print $NF;m=1}END{if(!m)print"sh"}' /etc/passwd;}
  export SUDO_GID=$(id -g) SUDO_UID=$(id -u) SUDO_USER=$(id -un)
  if [[ $# -eq 0 ]];then
    [[ -n $flag_i ]] && _doas -- "$(user_shell)" -c 'cd "$HOME";exec "$0" -l'
    [[ -n $flag_k ]] && exec doas "$flag_k" "${user:+-u "$user"}"
    _doas "$flag_s"
  elif [[ -n $flag_i ]];then
    _doas -- "$(user_shell)" -l -c 'cd "$HOME";"$0" "$@"' "$@"
  elif [[ -n $flag_s ]];then
    _doas -- "${SHELL:-$(user_shell)}" -c '"$0" "$@"' "$@"
  else
    _doas -- "$@"
  fi
}
main(){
  local cmd="${1:-}";shift||:
  case "$cmd" in
    edit|e) cmd_edit "$@";;
    vidoas|vd|v) cmd_vidoas "$@";;
    sudo|s) cmd_sudo "$@";;
    -h|--help|help|"") usage;;
    *) die "Unknown: $cmd";;
  esac
}
main "$@"
