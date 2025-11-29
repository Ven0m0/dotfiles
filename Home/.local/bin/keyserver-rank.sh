#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
export LC_ALL=C LANG=C

# Keyserver ranking tool - tests and ranks GPG keyservers by response time

has() { command -v -- "$1" &>/dev/null; }
die() {
	printf 'Error: %s\n' "$*" >&2
	exit 1
}

has gpg || die "gpg not found"

rank_server() {
	local srv=$1 keyid=003DB8B0CB23504F time code
	time=$(
		TIMEFORMAT='%3R'
		{ time gpg --batch --keyserver "$srv" --search-keys info@endeavouros.com &>/dev/null; } 2>&1
	)
	code=$?
	if [[ $code -eq 0 ]]; then
		gpg --batch --keyserver "$srv" --search-keys info@endeavouros.com 2>/dev/null | grep -qw "$keyid" && echo "$srv OK $time" || echo "$srv FAIL 99.999"
	else
		echo "$srv FAIL 99.999"
	fi
}

main() {
	local -a servers=(
		hkps://keys.openpgp.org
		hkps://keyserver.ubuntu.com
		hkps://zimmermann.mayfirst.org
		https://keyserver.ubuntu.com
	)
	local mode=ask show_fastest=no

	while (($#)); do
		case $1 in
		--yes | -y) mode=yes ;;
		--no | -n) mode=no ;;
		--show-fastest)
			mode=no
			show_fastest=yes
			;;
		--list-servers)
			printf '%s\n' "${servers[@]}"
			exit 0
			;;
		--servers=*) mapfile -t -O ${#servers[@]} servers <"${1#*=}" ;;
		--servers-replace=*) mapfile -t servers <"${1#*=}" ;;
		-h | --help)
			cat <<'EOF'
keyserver-rank - Test and rank GPG keyservers by response time

USAGE:
  keyserver-rank [OPTIONS]

OPTIONS:
  -y, --yes                    Auto-refresh keys with fastest server
  -n, --no                     Rank only, no refresh
  --show-fastest               Output fastest server to stdout
  --list-servers               List servers and exit
  --servers=FILE               Add servers from FILE
  --servers-replace=FILE       Replace servers with FILE contents
  -h, --help                   Show this help

EXAMPLES:
  keyserver-rank               # Rank servers and prompt for refresh
  keyserver-rank -y            # Auto-refresh with fastest
  keyserver-rank --show-fastest  # Print fastest server only

FEATURES:
  - Tests keyservers in parallel for speed
  - Validates keyserver by searching for known key
  - Ranks by response time (lower is better)
  - Can auto-refresh pacman keys with fastest server
EOF
			exit 0
			;;
		*) die "Unknown option: $1" ;;
		esac
		shift
	done

	local tmp
	tmp=$(mktemp)
	trap 'rm -f "$tmp"' EXIT

	[[ $show_fastest == no ]] && echo "Ranking ${#servers[@]} keyservers..." >&2

	export -f rank_server
	printf '%s\n' "${servers[@]}" | xargs -P"$(nproc)" -I{} bash -c 'rank_server "$@"' _ {} >"$tmp"

	local fastest
	fastest=$(grep -v FAIL "$tmp" | sort -k3,3n | head -n1 | awk '{print $1}')

	if [[ $show_fastest == yes ]]; then
		echo "$fastest"
		return 0
	fi

	printf '\nResults:\n\n' >&2
	sort -k3,3n "$tmp" | column -t >&2
	printf '\nFastest: %s\n\n' "$fastest" >&2

	case $mode in
	yes) ;;
	no) return 0 ;;
	ask)
		read -rp "Refresh pacman keys using $fastest? (y/N) " -n1 >&2
		echo >&2
		[[ $REPLY =~ ^[Yy]$ ]] || return 0
		;;
	esac

	has pacman-key || die "pacman-key not found"
	sudo pacman-key --refresh-keys --keyserver "$fastest"
}

main "$@"
