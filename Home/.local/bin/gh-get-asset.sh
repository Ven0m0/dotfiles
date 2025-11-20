#!/usr/bin/env bash
# Copyright 2022 Chmouel Boudjnah <chmouel@chmouel.com>
set -eufo pipefail
TMP=$(mktemp /tmp/.mm.XXXXXX)
clean() { rm -f ${TMP}; }
trap clean EXIT

curlargs=(-L)
release=
output=(-O)

print_help() {
	cat <<EOF
USAGE: gh get-asset owner/repo substring_in_assset

 -o OUTPUT_FILE to output to that file instead of the asset name in curdir
 -r RELEASE to grab this specific release (default to latest)
 -s make it silent

Example:
  gh-get-release -o /tmp/gosmee.rpm chmouel/gosmee Linux-ARM64.rpm

Author:
    Chmouel Boudjnah - https://fosstodon.org/web/@chmouel

Homepage:
    https://github.com/chmouel/gh-get-asset
EOF
}

while getopts "r:so:" o; do
	case "${o}" in
	r)
		release=${OPTARG}
		;;
	s)
		curlargs+=(-s)
		;;
	o)
		output=(-o "${OPTARG}")
		;;
	h)
		print_help
		exit 0
		;;
	*)
		echo "Invalid option"
		print_help
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))

[[ -z ${1-""} || -z ${2:-""} ]] && {
	print_help
	exit 1
}

gh_get_release() {
	curl -o ${TMP} -s https://api.github.com/repos/${1}/releases
	s='.[0]'
	if [[ -n ${release} ]]; then
		s=".[] | select(.tag_name==\"${release}\")"
	fi
	binary=$(jq -rM "${s}.assets[]|select(.name| contains(\"${2}\"))? | .browser_download_url" <${TMP})
	echo ${binary}
}

assets=$(gh_get_release ${1} ${2})
[[ -z ${assets} ]] && {
	echo "coudl not find asset"
	exit 1
}

for asset in ${assets}; do
	curl "${output[@]}" "${curlargs[@]}" $asset
done
