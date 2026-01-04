#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C
has(){ command -v -- "$1" &>/dev/null; }
msg(){ printf '%s\n' "$@"; }
log(){ printf '%s\n' "$@" >&2; }
die(){ printf '%s\n' "$1" >&2; exit "${2:-1}"; }

readonly PROTON=/usr/share/steam/compatibilitytools.d/proton-cachyos/proton
readonly PFX=${XDG_DATA_HOME:-~/.local/share}/proton-pfx
readonly CACHE=${XDG_CACHE_HOME:-~/.cache}/dxvk-cache-pool
readonly STEAM=${XDG_DATA_HOME:-~/.local/share}/Steam
readonly MODE=waitforexitandrun
readonly APPID=0

print_env(){
	printf '\nCurrent ENVIRONMENT variables:\n\n'
	printf 'STEAM_COMPAT_CLIENT_INSTALL_PATH  %s\n' "${STEAM_COMPAT_CLIENT_INSTALL_PATH:-Empty or not set.}"
	printf 'STEAM_COMPAT_DATA_PATH            %s\n' "${STEAM_COMPAT_DATA_PATH:-Empty or not set.}"
	printf 'DXVK_STATE_CACHE_PATH             %s\n' "${DXVK_STATE_CACHE_PATH:-Empty or not set.}"
	printf 'SteamAppId                        %s\n' "${SteamAppId:-Empty or not set.}"
	printf 'SteamGameId                       %s\n' "${SteamGameId:-Empty or not set.}"
}

setup_env(){
	local appid=${SteamAppId:-${APPID}}
	
	if [[ -z ${STEAM_COMPAT_CLIENT_INSTALL_PATH+x} ]]; then
		export STEAM_COMPAT_CLIENT_INSTALL_PATH=${STEAM}
		log "ProtonLauncher[$$] INFO: empty STEAM_COMPAT_CLIENT_INSTALL_PATH set to ${STEAM}"
	fi
	[[ -d ${STEAM_COMPAT_CLIENT_INSTALL_PATH} ]] || log "ProtonLauncher[$$] WARN: directory ${STEAM_COMPAT_CLIENT_INSTALL_PATH} does not exist"

	if [[ -z ${STEAM_COMPAT_DATA_PATH+x} ]]; then
		export STEAM_COMPAT_DATA_PATH=${PFX}/${appid}
		log "ProtonLauncher[$$] INFO: empty STEAM_COMPAT_DATA_PATH set to ${STEAM_COMPAT_DATA_PATH}"
	elif ! [[ ${SteamGameId} =~ ^[0-9]+$ || ${SteamAppId} =~ ^[0-9]+$ || $(basename "${STEAM_COMPAT_DATA_PATH}") =~ ^[0-9]+$ ]]; then
		export SteamAppId=${APPID}
		log "ProtonLauncher[$$] INFO: empty SteamAppId set to ${APPID}"
	fi
	if [[ ! -d ${STEAM_COMPAT_DATA_PATH} ]]; then
		mkdir -p "${STEAM_COMPAT_DATA_PATH}" || die "Failed to create ${STEAM_COMPAT_DATA_PATH}"
		log "ProtonLauncher[$$] INFO: directory ${STEAM_COMPAT_DATA_PATH} created"
	fi

	if [[ -z ${DXVK_STATE_CACHE_PATH+x} ]]; then
		export DXVK_STATE_CACHE_PATH=${CACHE}
		log "ProtonLauncher[$$] INFO: empty DXVK_STATE_CACHE_PATH set to ${CACHE}"
	fi
	if [[ ! -d ${DXVK_STATE_CACHE_PATH} ]]; then
		mkdir -p "${DXVK_STATE_CACHE_PATH}" || die "Failed to create ${DXVK_STATE_CACHE_PATH}"
		log "ProtonLauncher[$$] INFO: directory ${DXVK_STATE_CACHE_PATH} created"
	fi

	[[ -f ${STEAM_COMPAT_DATA_PATH}/tracked_files ]] || [[ ! -f ${STEAM_COMPAT_DATA_PATH}/version ]] || \
		log "ProtonLauncher[$$] WARN: file ${STEAM_COMPAT_DATA_PATH}/tracked_files missing! Please report to AUR maintainer"

	[[ ${_printenv:-} == true ]] && print_env
}

show_help(){
	cat <<-'EOF'
	USAGE:  proton [--environment|-e] executable.exe
	        proton [--environment|-e] [mode]  executable.exe
	        proton [--environment|-e] [appid] executable.exe
	        proton [--help|-h]

	ENV:    STEAM_COMPAT_DATA_PATH STEAM_COMPAT_CLIENT_INSTALL_PATH
	        DXVK_STATE_CACHE_PATH SteamAppId SteamGameId

	Default prefix: ~/.local/share/proton-pfx/0
	Default mode: waitforexitandrun
	Modes: waitforexitandrun, run, getcompatpath, getnativepath

	AppId handling:
	  - Protonfixes uses STEAM_COMPAT_DATA_PATH basename or SteamAppId/SteamGameId
	  - First numeric arg forces AppId and alters default prefix
	  - See https://steamdb.info/apps/ for AppIds

	DXVK cache: Defaults to ~/.cache/dxvk-cache-pool (survives reinstalls)
	  Download caches: https://github.com/begin-theadventure/dxvk-caches/

	Examples:
	  proton winecfg                          # Default prefix/mode
	  proton -e winecfg                       # Dump environment
	  proton 17300 winecfg                    # AppId 17300 (Crysis)
	  proton getnativepath "C:\Windows"       # Path conversion
	  STEAM_COMPAT_DATA_PATH=~/custom proton winecfg
	EOF
}

[[ ${1:-} =~ ^(-h|--help)$ ]] && { show_help; exit 0; }
[[ ${1:-} =~ ^(-e|--environment)$ ]] && { _printenv=true; shift; }

case $# in
	0) msg "USAGE:  proton [--environment|-e] executable.exe" "        proton [--environment|-e] [mode]  executable.exe" \
	         "        proton [--environment|-e] [appid] executable.exe" "        proton [--help|-h]" ;;
	1) setup_env; exec "${PROTON}" "${MODE}" "$1" ;;
	*) if [[ $1 =~ ^[0-9]+$ ]]; then
		export SteamAppId=$1
		log "ProtonLauncher[$$] INFO: forcing SteamAppId to $1"
		setup_env; exec "${PROTON}" "${MODE}" "${@:2}"
	   else
		setup_env; exec "${PROTON}" "$@"
	   fi ;;
esac
