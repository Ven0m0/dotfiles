#!/usr/bin/env bash
set -euo pipefail; IFS=$'\n\t'
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# Dependency check: ping and ip (iproute2) are standard on Arch/Debian base
command -v ping >/dev/null && command -v ip >/dev/null || die "Missing 'ping' or 'ip'"
select_iface() {
  local -a list; mapfile -t list < <(ip -br link | awk '$1!~/(lo|veth|docker|br-)/{print $1}')
  ((${#list[@]})) || die "No interfaces found"
  ((${#list[@]} == 1)) && { echo "${list[0]}"; return; }
  echo "Select interface:"; for i in "${!list[@]}"; do echo "$((i+1))) ${list[$i]}"; done
  read -rp "#? " n; [[ $n =~ ^[0-9]+$ && $n -le ${#list[@]} ]] || die "Invalid"
  echo "${list[$((n-1))]}"
}
persist() {
  local iface=$1 mtu=$2
  # 1. NetworkManager (Common on Arch/Debian Desktops)
  if command -v nmcli >/dev/null && nmcli -t dev | grep -q "^${iface}:"; then
    local c; c=$(nmcli -t -f NAME,DEVICE con show --active | awk -F: -v i="$iface" '$2==i{print $1}')
    [[ -n $c ]] && { sudo nmcli con mod "$c" 802-3-ethernet.mtu "$mtu"; echo "Saved via NetworkManager"; return; }
  fi
  # 2. Systemd-networkd (Arch Standard / Modern Debian)
  if [[ -d /etc/systemd/network ]]; then
    printf '[Match]\nName=%s\n[Link]\nMTUBytes=%s\n' "$iface" "$mtu" | sudo tee "/etc/systemd/network/10-${iface}-mtu.network" >/dev/null
    echo "Saved to /etc/systemd/network/ (restart systemd-networkd to apply)"; return
  fi
  # 3. /etc/network/interfaces (Debian Standard)
  if [[ -f /etc/network/interfaces ]]; then
    if grep -q "iface $iface inet" /etc/network/interfaces; then
      grep -q "mtu " /etc/network/interfaces && \
        sudo sed -i "/iface $iface/,/iface/ s/mtu [0-9]*/mtu $mtu/" /etc/network/interfaces || \
        sudo sed -i "/iface $iface/a \ \ mtu $mtu" /etc/network/interfaces
      echo "Saved to /etc/network/interfaces"; return
    fi
  fi
  echo "No supported config found (NetworkManager, systemd-networkd, or interfaces)."
}
find_mtu() {
  local srv=$1 iface=$2 min=1200 max=1500 overhead=28 opt=$min mid
  [[ $srv =~ : ]] && overhead=48
  # Temp raise interface MTU to allow large packets out
  local old_mtu; old_mtu=$(ip -o link show "$iface" | awk '{print $5}')
  sudo ip link set dev "$iface" mtu $max || die "Failed to set temp MTU"
  echo "Probing $srv on $iface..."
  while ((min <= max)); do
    mid=$(((min + max) / 2))
    if ping -M do -s $((mid - overhead)) -c1 -W1 "$srv" >/dev/null 2>&1; then
      opt=$mid; min=$((mid + 1))
    else
      max=$((mid - 1))
    fi
  done
  sudo ip link set dev "$iface" mtu "$old_mtu" # Restore original
  echo $((opt - 4)) # Safety margin
}
main() {
  local srv=${1:-8.8.8.8} iface mtu choice
  iface=$(select_iface)
  mtu=$(find_mtu "$srv" "$iface")
  echo "Optimal MTU: $mtu"
  read -rp "Apply permanent? (y/N) " -n1 choice; echo
  [[ $choice =~ ^[Yy]$ ]] || exit 0
  sudo ip link set dev "$iface" mtu "$mtu"
  persist "$iface" "$mtu"
}
main "$@"
