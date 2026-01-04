#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C
has(){ command -v -- "$1" &>/dev/null; }
msg(){ printf '%s\n' "$@"; }
log(){ printf '%s\n' "$@" >&2; }
die(){ printf '%s\n' "$1" >&2; exit "${2:-1}"; }

readonly PHD=${XDG_RUNTIME_DIR:-/run/user/$UID}/protonhax

show_usage(){
	cat <<-'EOF'
	Usage:
	  protonhax init <cmd>     Called by Steam with "protonhax init %COMMAND%"
	  protonhax ls             Lists all currently running games
	  protonhax run <appid> <cmd>   Runs <cmd> in <appid> context with proton
	  protonhax cmd <appid>    Runs cmd.exe in <appid> context
	  protonhax exec <appid> <cmd>  Runs <cmd> in <appid> context
	EOF
}

(($#<1)) && { show_usage; exit 1; }

cmd=$1; shift

case ${cmd} in
	init)
		mkdir -p "${PHD}/${SteamAppId}"
		printf '%s\n' "$@" | grep -m1 /proton >"${PHD}/${SteamAppId}/exe"
		printf '%s' "${STEAM_COMPAT_DATA_PATH}/pfx" >"${PHD}/${SteamAppId}/pfx"
		declare -px >"${PHD}/${SteamAppId}/env"
		"$@"; ec=$?
		rm -rf "${PHD:?}/${SteamAppId}"
		exit ${ec}
		;;
	ls)
		[[ -d ${PHD} ]] && ls -1 "${PHD}"
		;;
	run|cmd|exec)
		(($#<1)) && { show_usage; exit 1; }
		[[ -d ${PHD}/$1 ]] || die "No app running with appid \"$1\"" 2
		appid=$1; shift
		# shellcheck source=/dev/null
		source "${PHD}/${appid}/env"
		case ${cmd} in
			run)  (($#<1)) && { show_usage; exit 1; }; exec "$(<"${PHD}/${appid}/exe")" run "$@" ;;
			cmd)  exec "$(<"${PHD}/${appid}/exe")" run "$(<"${PHD}/${appid}/pfx")/drive_c/windows/system32/cmd.exe" ;;
			exec) (($#<1)) && { show_usage; exit 1; }; exec "$@" ;;
		esac
		;;
	*)
		die "Unknown command ${cmd}" 1
		;;
esac
