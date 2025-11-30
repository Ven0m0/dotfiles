#!/usr/bin/env bash
LC_ALL=C LANG=C

# https://codeberg.org/TotallyLeGIT/doasedit/
help() {
	cat - >&2 <<EOF
doasedit - edit files as root using an unprivileged editor

usage: doasedit file...
       doasedit -h | -V
Options:
  -h, --help     display help message and exit
  -V, --version  display version information and exit
  --             stop processing command line arguments
EOF
}
# Checks for syntax errors in doas' config
# check_doas_conf <target> <tmp_target>

check_doas_conf() {
	if printf '%s' "${1}" | grep -q '^/etc/doas\(\.d/.*\)\?\.conf$'; then
		while ! doas -C "${2}"; do
			printf "doasedit: Replacing '%s' would " "$file"
			printf 'introduce the above error and break doas.\n'
			printf '(E)dit again, (O)verwrite anyway, (A)bort: [E/o/a]? '
			read -r choice
			case "$choice" in
			o | O) return 0 ;;
			a | A) return 1 ;;
			e | E | *) "$editor_cmd" "$tmpfile" ;;
			esac
		done
	fi
	return 0
}
error() { printf 'doasedit: %s\n' "${@}" 1>&2; }
_exit() {
	rm -rf "$tmpdir"
	trap - EXIT HUP QUIT TERM INT ABRT
	exit "${1:-0}"
}
# no argument passed
[ "${#}" -eq 0 ] && help && exit 1
while [ "${#}" -ne 0 ]; do
	case "${1}" in
	--)
		shift
		break
		;;
	--help | -h)
		help
		exit 0
		;;
	--version | -V)
		printf 'doasedit version 1.0.8\n'
		exit 0
		;;
	-*)
		printf "doasedit: invalid option: '%s'\n" "${1}"
		help
		exit 1
		;;
	*) break ;;
	esac
done
user_id="$(LC_ALL=C id -u)"
if [ "$user_id" -eq 0 ]; then
	error "using this program as root is not permitted"
	exit 1
fi
for editor_cmd in "$DOAS_EDITOR" "$VISUAL" "$EDITOR"; do
	[ "$editor_cmd" != "" ] && break
done
# shellcheck disable=SC2086
if [ "$editor_cmd" = "" ]; then
	if command -v vi &>/dev/null; then
		editor_cmd='vi'
	else
		error 'no editor specified'
		exit 1
	fi
elif ! command -v "$editor_cmd" &>/dev/null; then
	error "invalid editor command: '${editor_cmd}'"
	exit 1
fi
exit_code=1
trap '_exit "${exit_code}"' EXIT
trap '_exit 130' HUP QUIT TERM INT ABRT
tmpdir="$(mktemp -dt 'doasedit-XXXXXX')"
for file; do
	unset exists readable writable
	dir="$(dirname -- "$file")"
	tmpfile="${tmpdir}/${file##*/}"
	tmpfile_copy="${tmpdir}/copy-of-${file##*/}"
	printf '' | tee "$tmpfile" >"$tmpfile_copy"
	chmod 0600 "$tmpfile" "$tmpfile_copy"
	if [[ -e "$file" ]]; then
		if ! [[ -f "$file" ]]; then
			error "${file}: not a regular file"
			continue
		fi
		if [ "$(find "$file" -prune -user "$user_id")" != "" ]; then
			error "${file}: editing your own files is not permitted"
			continue
		fi
		exists=1
	elif doas [[ -e "$file" ]]; then
		if ! doas [[ -f "$file" ]]; then
			error "${file}: not a regular file"
			continue
		fi
		exists=0
	else
		# New file?
		if [ "$(find "$dir" -prune -user "$user_id")" != "" ]; then
			error "${file}: creating files in your own directory is not permitted"
			continue
		elif [ -x "$dir" ] && [ -w "$dir" ]; then
			error "${file}: creating files in a user-writable directory is not permitted"
			continue
		elif ! doas [ -e "$dir" ]; then
			error "${file}: no such directory"
			continue
		fi
	fi
	# If this test is true, it's an existent regular file
	if [[ -n "$exists" ]]; then
		if [[ -w "$file" ]]; then
			writable=1
		# Check in advance to make sure that it won't fail after editing.
		elif ! doas dd status=none count=0 of=/dev/null; then
			error "unable to run 'doas dd'"
			continue
		fi
		if [[ -r "$file" ]]; then
			if [[ -n "$writable" ]]; then
				error "${file}: editing user-readable and -writable files is not permitted"
				continue
			fi
			cat -- "$file" >"$tmpfile"
		# Better not suppress stderr here as there might be something of importance.
		elif ! doas cat -- "$file" >"$tmpfile"; then
			error "you are not permitted to call 'doas cat'"
			continue
		fi
		cat "$tmpfile" >"$tmpfile_copy"
	fi
	"$editor_cmd" "$tmpfile"
	check_doas_conf "$file" "$tmpfile" || continue
	if cmp -s "$tmpfile" "$tmpfile_copy"; then
		printf 'doasedit: %s: unchanged\n' "$file"
	else
		if [[ -n "$writable" ]]; then
			dd status=none if="$tmpfile" of="$file"
		else
			for de_tries in 2 1 0; do
				if doas dd status=none if="$tmpfile" of="$file"; then
					break
				elif [[ "$de_tries" -eq 0 ]]; then
					error '3 incorrect password attempts'
					exit 1
				fi
			done
		fi
	fi
	exit_code=0
done
# vim: shiftwidth=2 tabstop=2 noexpandtab
