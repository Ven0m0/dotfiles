#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob; IFS=$'\n\t' LC_ALL=C
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

check_deps() {
  local reqs=(ping ip awk grep sed)
  for r in "${reqs[@]}"; do command -v "$r" >/dev/null || die "Missing: $r"; done
}
select_iface() {
  local -a ifaces; mapfile -t ifaces < <(ip -br link | awk '$1!~/(lo|veth|docker|br-)/{print $1}')
  ((${#ifaces[@]})) || die "No interfaces found"
  ((${#ifaces[@]} == 1)) && { echo "${ifaces[0]}"; return; }
  echo "Interfaces: "; for i in "${!ifaces[@]}"; do echo "$((i+1))) ${ifaces[$i]}"; done
  read -rp "Select [1-${#ifaces[@]}]: " n
  [[ $n =~ ^[0-9]+$ && $n -ge 1 && $n -le ${#ifaces[@]} ]] || die "Invalid"
  echo "${ifaces[$((n-1))]}"
}
persist() {
  local iface=$1 mtu=$2
  if command -v nmcli >/dev/null && nmcli -t dev | grep -q "^${iface}:"; then
    local c; c=$(nmcli -t -f NAME,DEVICE con show --active | awk -F: -v i="$iface" '$2==i{print $1}')
    [[ -n $c ]] && { sudo nmcli con mod "$c" 802-3-ethernet.mtu "$mtu"; echo "Saved via NetworkManager"; return; }
  fi
  local np_file; np_file=$(compgen -G "/etc/netplan/*.yaml" | head -1)
  if [[ -n $np_file ]] && grep -q "^ *$iface:" "$np_file"; then
    grep -q "mtu:" "$np_file" && sudo sed -i "s/mtu: [0-9]*/mtu: $mtu/" "$np_file" || \
      sudo sed -i "/^ *$iface:/a\      mtu: $mtu" "$np_file"
    echo "Saved via Netplan ($np_file). Run 'sudo netplan apply'."; return
  fi
  if [[ -d /etc/systemd/network ]]; then
    echo -e "[Match]\nName=$iface\n[Link]\nMTUBytes=$mtu" | sudo tee "/etc/systemd/network/99-$iface-mtu.network" >/dev/null
    echo "Saved via systemd-networkd"; return
  fi
  if [[ -f /etc/network/interfaces ]] && grep -q "iface $iface inet" /etc/network/interfaces; then
    grep -q "^ *mtu $iface" /etc/network/interfaces && \
      sudo sed -i "/iface $iface inet/,/^iface/ s/^ *mtu . */    mtu $mtu/" /etc/network/interfaces || \
      sudo sed -i "/iface $iface inet/ a\    mtu $mtu" /etc/network/interfaces
    echo "Saved via /etc/network/interfaces"; return
  fi
  echo "No supported network manager found for persistence."
}
find_mtu() {
  local srv=$1 iface=$2 min=1200 max=1500 overhead=28 cmd="ping"
  [[ $srv =~ : ]] && { overhead=48; cmd="ping6"; }
  command -v "$cmd" >/dev/null || die "$cmd missing"
  "$cmd" -c1 -W1 "$srv" >/dev/null || die "Server $srv unreachable"
  # Temporarily raise IFACE MTU to allow testing large packets
  local orig_mtu; orig_mtu=$(ip -o link show "$iface" | awk '{print $5}')
  sudo ip link set dev "$iface" mtu $max || die "Cannot set temp MTU on $iface"
  local lo=$min hi=$max opt=$min mid
  echo "Probing MTU to $srv ($cmd)..."
  while ((lo <= hi)); do
    mid=$(((lo + hi) / 2))
    if "$cmd" -M do -s $((mid - overhead)) -c1 -W1 "$srv" >/dev/null 2>&1; then
      opt=$mid; lo=$((mid + 1))
    else
      hi=$((mid - 1))
    fi
  done
  # Revert MTU if not applying immediately (safety)
  sudo ip link set dev "$iface" mtu "$orig_mtu"
  echo $((opt - 4)) # Safety margin
}
main() {
  check_deps
  local srv=${1:-8.8.8.8} iface mtu choice
  echo "Target: $srv"
  iface=$(select_iface)
  mtu=$(find_mtu "$srv" "$iface")
  echo "Optimal MTU: $mtu"
  read -rp "Apply and persist? (y/N) " -n1 choice; echo
  [[ $choice =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
  sudo ip link set dev "$iface" mtu "$mtu" && echo "Applied to interface."
  persist "$iface" "$mtu"
}
main "$@"
