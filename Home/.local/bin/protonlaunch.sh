#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C
has(){ command -v -- "$1" &>/dev/null; }
msg(){ printf '%s\n' "$@"; }
log(){ printf '%s\n' "$@" >&2; }
die(){ printf '%s\n' "$1" >&2; exit "${2:-1}"; }

readonly VERSION=0.11

show_usage(){
	cat <<-EOF
	Usage: ${0##*/} [option] program [arguments...]

	Options:
	  --help                   Display this message and exit
	  --version                Display version and exit
	  --steam-path PATH        Path to Steam installation (overrides env)
	  --proton-version VER     Proton version to use
	  --proton-version-list    List all found Proton versions
	  --quiet                  Suppress info messages
	  --debug                  Enable debug messages

	Environment Variables:
	  PROTONPREFIX            Prefix path (default: ~/.proton)
	  STEAM_COMPAT_DATA_PATH  Overrides PROTONPREFIX
	  STEAM_COMPAT_CLIENT_INSTALL_PATH  Steam installation path
	  PL_STEAM_PATH           Alternative to STEAM_COMPAT_CLIENT_INSTALL_PATH
	  PL_LIBRARY_PATH         Steam library folder path
	  PL_PROTON_VERSION       Proton version to use
	EOF
}

show_version(){
	msg "ProtonLaunch version ${VERSION}" \
	    "Licensed under BSD 3-Clause License <https://opensource.org/licenses/BSD-3-Clause>" \
	    "" "This is free software; you are free to change and redistribute it." \
	    "There is NO WARRANTY, to the extent permitted by law."
}

dbg(){ [[ ${PL_DEBUG:-0} == 1 ]] && log "debug: $1"; }
info(){ [[ ${PL_QUIET:-0} == 0 ]] && log "$1"; }
warn(){ log "warning: $1"; }

# Find Steam installation
find_steam(){
	dbg "locating steam installation path"
	[[ -n ${STEAM_COMPAT_CLIENT_INSTALL_PATH:-} ]] && return 0
	
	local -a candidates=(
		"${PL_STEAM_PATH:-}"
		"${HOME}/.local/share/Steam"
		"${HOME}/.steam/debian-installation"
		"$(readlink -f "${HOME}/.steam/steam" 2>/dev/null || :)"
		"${HOME}/.steam/steam"
	)
	
	for path in "${candidates[@]}"; do
		[[ -n ${path} && -e ${path}/steam.sh ]] && { export STEAM_COMPAT_CLIENT_INSTALL_PATH=${path}; return 0; }
	done
	die "unable to find Steam path, please set PL_STEAM_PATH or STEAM_COMPAT_CLIENT_INSTALL_PATH"
}

# Find Steam libraries
find_libraries(){
	dbg "locating steam library paths"
	local vdf=${STEAM_COMPAT_CLIENT_INSTALL_PATH}/config/libraryfolders.vdf
	local -a paths=()
	
	if [[ -f ${vdf} ]]; then
		while IFS= read -r line; do
			[[ ${line,,} == *path* ]] || continue
			local p=${line#*\"}; p=${p%%\"*}
			[[ -d ${p}/steamapps/common ]] && paths+=("${p}")
		done <"${vdf}"
	fi
	
	[[ ${#paths[@]} -eq 0 && -d ${STEAM_COMPAT_CLIENT_INSTALL_PATH}/steamapps/common ]] && \
		paths=("${STEAM_COMPAT_CLIENT_INSTALL_PATH}")
	
	[[ ${#paths[@]} -eq 0 ]] && die "unable to find Steam library, ensure Proton is installed"
	
	PL_LIBRARY_PATH=$(IFS=:; printf '%s' "${paths[*]}")
	export PL_LIBRARY_PATH
	dbg "steam library path found: ${PL_LIBRARY_PATH}"
}

# Find all Proton installations
find_proton_versions(){
	dbg "locating steam proton installations"
	local -a protons=()
	IFS=: read -ra libs <<<"${PL_LIBRARY_PATH}"
	
	for lib in "${libs[@]}"; do
		local common=${lib}/steamapps/common
		[[ -d ${common} ]] || continue
		for p in "${common}"/*; do
			[[ ${p,,} == *proton* && -f ${p}/proton ]] && protons+=("${p}")
		done
	done
	
	[[ ${#protons[@]} -eq 0 ]] && die "no Proton installation found, install Proton through Steam"
	
	PL_PROTON_LIST=$(IFS=:; printf '%s' "${protons[*]}")
	export PL_PROTON_LIST
}

# Select Proton version
select_proton(){
	dbg "getting a usable proton version"
	IFS=: read -ra protons <<<"${PL_PROTON_LIST}"
	local selected_path=
	
	for p in "${protons[@]}"; do
		local name=${p##*/}
		if [[ -z ${PL_PROTON_VERSION:-} ]]; then
			[[ ${name} != "Proton - Experimental" ]] && { PL_PROTON_VERSION=${name}; selected_path=${p}; break; }
		elif [[ ${name} == "${PL_PROTON_VERSION}" ]]; then
			selected_path=${p}; break
		fi
	done
	
	[[ -z ${selected_path} ]] && die "unable to find Proton installation${PL_PROTON_VERSION:+ of '${PL_PROTON_VERSION}'}"
	
	PROTON_PATH=${selected_path}
	export PROTON_PATH PL_PROTON_VERSION
}

# Set up prefix
setup_prefix(){
	dbg "locating current prefix"
	[[ -z ${STEAM_COMPAT_DATA_PATH:-} ]] && STEAM_COMPAT_DATA_PATH=${PROTONPREFIX:-${HOME}/.proton}
	export STEAM_COMPAT_DATA_PATH
	
	[[ -d ${STEAM_COMPAT_DATA_PATH} ]] || mkdir -p "${STEAM_COMPAT_DATA_PATH}" || die "failed to create prefix '${STEAM_COMPAT_DATA_PATH}'"
	
	if [[ ! -d ${STEAM_COMPAT_DATA_PATH}/pfx/drive_c ]]; then
		info "bootstrapping '${STEAM_COMPAT_DATA_PATH}'"
		"${PROTON_PATH}/proton" run wineboot || die "failed to bootstrap '${STEAM_COMPAT_DATA_PATH}'"
	fi
}

# Parse options
while [[ ${1:-} == --* ]]; do
	case $1 in
		--help) show_usage; exit 0 ;;
		--version) show_version; exit 0 ;;
		--steam-path) STEAM_COMPAT_CLIENT_INSTALL_PATH=$2; shift 2 ;;
		--proton-version) PL_PROTON_VERSION=$2; shift 2 ;;
		--proton-version-list) LIST_VERSIONS=1; shift ;;
		--quiet) PL_QUIET=1; shift ;;
		--debug) PL_DEBUG=1; shift ;;
		*) die "$1 is not a valid argument, try ${0##*/} --help" ;;
	esac
done

[[ -z ${1:-} && -z ${LIST_VERSIONS:-} ]] && die "expecting a program name or argument, try --help"

# Initialize
find_steam
info "steam installation path is '${STEAM_COMPAT_CLIENT_INSTALL_PATH}'"

find_libraries
find_proton_versions

if [[ ${LIST_VERSIONS:-0} == 1 ]]; then
	IFS=: read -ra protons <<<"${PL_PROTON_LIST}"
	printf '%s\n' "${protons[@]##*/}"
	exit 0
fi

select_proton
info "proton version '${PL_PROTON_VERSION}'"

setup_prefix
info "prefix '${STEAM_COMPAT_DATA_PATH}'"

# Run
info "program is '${1}'"
if [[ $# -eq 1 ]]; then
	dbg "running: ${PROTON_PATH}/proton run $1"
	exec "${PROTON_PATH}/proton" run "$1"
else
	dbg "running: ${PROTON_PATH}/proton runinprefix $*"
	exec "${PROTON_PATH}/proton" runinprefix "$@"
fi
