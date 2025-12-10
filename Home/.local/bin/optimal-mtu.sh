#!/usr/bin/env bash
set -euo pipefail;shopt -s nullglob globstar;IFS=$'\n\t'
export LC_ALL=C LANG=C HOME="/home/${SUDO_USER:-$USER}"
has(){ command -v -- "$1" &>/dev/null; }
die(){ printf 'ERROR: %s\n' "$*" >&2; exit 1; }

check_requirements(){
  local -a missing=() reqs=(ping ip)
  for req in "${reqs[@]}"; do
    has "$req" || missing+=("$req")
  done
  ((${#missing[@]})) && die "Missing tools: ${missing[*]}"
}

detect_ip_version(){ local addr="$1"; [[ $addr =~ : ]] && printf '6' || printf '4'; }

select_interface(){
  local -a ifaces
  mapfile -t ifaces < <(ip -br link | awk '$1!~/(lo|veth|docker|br-)/{print $1}')
  ((${#ifaces[@]})) || die "No valid interfaces found"
  if ((${#ifaces[@]} == 1)); then
    printf '%s' "${ifaces[0]}"; return
  fi
  printf "Available interfaces:\n"
  for i in "${!ifaces[@]}"; do
    printf "%d) %s\n" $((i + 1)) "${ifaces[$i]}"
  done
  local n
  read -rp "Select [1-${#ifaces[@]}]: " n
  [[ $n =~ ^[0-9]+$ && $n -ge 1 && $n -le ${#ifaces[@]} ]] || die "Invalid selection"
  printf '%s' "${ifaces[$((n - 1))]}"
}

persist_mtu(){
  local iface=$1 mtu=$2
  if has nmcli && [[ -n $(nmcli -t dev | grep "^$iface:") ]]; then
    local conn
    conn=$(nmcli -t -f NAME,DEVICE con show --active | awk -F: -v i="$iface" '$2==i{print $1}')
    if [[ $conn ]]; then
      sudo nmcli con mod "$conn" 802-3-ethernet.mtu "$mtu"
      printf 'Persistent via NetworkManager: %s\n' "$conn"; return 0
    fi
  fi
  if [[ -d /etc/netplan ]] && compgen -G "/etc/netplan/*.yaml" >/dev/null; then
    local netplan_file
    netplan_file=$(compgen -G "/etc/netplan/*.yaml" | head -1)
    printf 'Updating Netplan config: %s\n' "$netplan_file"
    if grep -q "^ *$iface:" "$netplan_file" 2>/dev/null; then
      if grep -q "mtu:" "$netplan_file" 2>/dev/null; then
        sudo sed -i "s/mtu: [0-9]*/mtu: $mtu/" "$netplan_file"
      else
        sudo sed -i "/^ *$iface:/a\      mtu: $mtu" "$netplan_file"
      fi
      sudo netplan apply &>/dev/null || printf "Run 'sudo netplan apply' to activate\n"
      printf 'Persistent via Netplan: %s\n' "$netplan_file"; return 0
    fi
  fi
  if [[ -d /etc/systemd/network ]]; then
    local nwfile="/etc/systemd/network/99-$iface-mtu.network"
    sudo tee "$nwfile" &>/dev/null <<EOF
[Match]
Name=$iface

[Link]
MTUBytes=$mtu
EOF
    sudo systemctl restart systemd-networkd &>/dev/null || :
    printf 'Persistent via systemd-networkd: %s\n' "$nwfile"; return 0
  fi
  if [[ -f /etc/network/interfaces ]]; then
    if grep -q "iface $iface inet" /etc/network/interfaces 2>/dev/null; then
      if grep -q "^ *mtu $iface" /etc/network/interfaces 2>/dev/null; then
        sudo sed -i "/iface $iface inet/,/^iface/ s/^ *mtu . */    mtu $mtu/" /etc/network/interfaces
      else
        sudo sed -i "/iface $iface inet/ a\    mtu $mtu" /etc/network/interfaces
      fi
      printf 'Persistent via /etc/network/interfaces\n'
      sudo systemctl restart networking &>/dev/null || sudo ifdown "$iface" && sudo ifup "$iface" || :; return 0
    fi
  fi
  printf 'Manual persistence needed - no supported network manager found\n'
}

find_mtu_binary(){
  local srv="$1" iface="$2" lo=1200 hi=1500 mid opt ipver overhead ping_cmd
  ipver=$(detect_ip_version "$srv")
  if [[ $ipver == "6" ]]; then
    overhead=48; ping_cmd="ping6"
    has ping6 || die "ping6 not available for IPv6"
  else
    overhead=28; ping_cmd="ping"
  fi
  printf 'Testing MTU to %s (IPv%s) via binary search...\n' "$srv" "$ipver"
  "$ping_cmd" -c1 -W1 "$srv" &>/dev/null || die "Server $srv unreachable"
  "$ping_cmd" -M 'do' -s$((lo - overhead)) -c1 "$srv" &>/dev/null || die "Min MTU $lo not viable"
  opt=$lo
  while ((lo <= hi)); do
    mid=$(((lo + hi) / 2))
    if "$ping_cmd" -M 'do' -s$((mid - overhead)) -c1 "$srv" &>/dev/null; then
      opt="$mid"; lo=$((mid + 1))
    else
      hi=$((mid - 1))
    fi
  done
  opt=$((opt - 4))
  printf 'Optimal MTU: %d bytes (4-byte safety margin)\n' "$opt"; printf '%d' "$opt"
}

find_mtu_incremental(){
  local srv="$1" iface="$2" step="$3" current last_ok min_mtu=1000 max_mtu=1500 ipver overhead ping_cmd
  ipver=$(detect_ip_version "$srv")
  if [[ $ipver == "6" ]]; then
    overhead=48; ping_cmd="ping6"
    has ping6 || die "ping6 not available for IPv6"
  else
    overhead=28; ping_cmd="ping"
  fi
  printf 'Testing MTU to %s (IPv%s) via incremental (step=%s)...\n' "$srv" "$ipver" "$step"
  "$ping_cmd" -c1 -W1 "$srv" &>/dev/null || die "Server $srv unreachable"
  sudo ip link set dev "$iface" mtu "$max_mtu" &>/dev/null || die "Cannot set initial MTU"
  current="$min_mtu"; last_ok="$min_mtu"
  while ((current <= max_mtu)); do
    printf "Testing MTU: %d...  " "$current"
    if "$ping_cmd" -M 'do' -s$((current - overhead)) -c1 -W1 "$srv" &>/dev/null; then
      printf 'OK\n'; last_ok="$current"
    else
      printf 'FAIL - retrying...\n'
      read -rt 0.5 -- <> <(:) &>/dev/null || :
      if "$ping_cmd" -M 'do' -s$((current - overhead)) -c1 -W1 "$srv" &>/dev/null; then
        printf '  Retry OK\n'; last_ok="$current"
      else
        printf '  Retry FAIL - stopping\n'; break
      fi
    fi
    ((current += step))
  done
  last_ok=$((last_ok - 2))
  printf 'Optimal MTU: %d bytes (2-byte safety margin)\n' "$last_ok"; printf '%d' "$last_ok"
}

main(){
  local srv step_mode=0 step_size=5 iface opt choice persist_choice
  check_requirements
  while getopts "s:h" opt; do
    case $opt in
      s)
        step_mode=1 step_size="$OPTARG"
        [[ $step_size =~ ^[0-9]+$ && $step_size -ge 1 && $step_size -le 10 ]] || die "Step size must be 1-10" ;;
      h)
        cat <<EOF
Usage: ${0##*/} [-s STEP] [SERVER]
Find optimal MTU to SERVER (default: 8.8.8.8)
Supports IPv4 and IPv6.

Options:
  -s STEP   Use incremental mode with step size 1-10 (default: binary search)
  -h        Show this help

Examples:
  ${0##*/}                       # Binary search to 8.8.8.8
  ${0##*/} 1.1.1.1               # Binary search to Cloudflare
  ${0##*/} -s 5 1.1.1.1          # Incremental (step=5)
  ${0##*/} 2606:4700:4700::1111  # IPv6 binary search
EOF
        exit 0 ;;
      *) die "Invalid option. Use -h for help" ;;
    esac
  done
  shift $((OPTIND - 1)); srv=${1:-8.8.8.8}
  read -rp "Set MTU on interface? (Y/n) " -n1 choice
  [[ $choice =~ ^[Nn]$ ]] && {
    printf 'Dry run only - no changes applied\n'
    iface="(not selected)"
    if ((step_mode)); then
      find_mtu_incremental "$srv" "$iface" "$step_size" >/dev/null
    else
      find_mtu_binary "$srv" "$iface" >/dev/null
    fi; return 0
  }
  iface=$(select_interface)
  printf 'Selected interface: %s\n' "$iface"
  local mtu
  if ((step_mode)); then
    mtu=$(find_mtu_incremental "$srv" "$iface" "$step_size")
  else
    mtu=$(find_mtu_binary "$srv" "$iface")
  fi
  sudo ip link set dev "$iface" mtu "$mtu" || die "Failed to set MTU on $iface"
  printf 'MTU set to %s on %s\n' "$mtu" "$iface"
  read -rp "Make persistent? (y/N) " -n1 persist_choice
  [[ $persist_choice =~ ^[Yy]$ ]] && persist_mtu "$iface" "$mtu"
}

main "$@"
