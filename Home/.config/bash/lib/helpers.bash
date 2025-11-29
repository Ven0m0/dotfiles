#================================= [Helpers] ==================================
has() { command -v -- "$1" &>/dev/null; }
ifsource() { [[ -r "${1/#\~\//${HOME}/}" ]] && . "${1/#\~\//${HOME}/}"; }
exportif() { [[ -e "$2" ]] && export "$1=$2"; }
prepend_var() {
	local -n p="$1"
	[[ -d "$2" && ":$p:" != *":$2:"* ]] && p="$2${p:+:$p}"
}
prependpath() { prepend_var PATH "$1"; }
