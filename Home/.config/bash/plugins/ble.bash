# github.com/akinomyoga/ble.sh
[[ -r /usr/share/blesh/ble.sh ]] && . "/usr/share/blesh/ble.sh" --attach=none 2>/dev/null || {
  [[ -r "${XDG_DATA_HOME}/blesh/ble.sh" ]] && . "${XDG_DATA_HOME}/blesh/ble.sh" --noattach 2>/dev/null
}
ble-import -d integration/fzf-key-bindings
ble-import -d integration/fzf-completion
[[ -z ${BLE_VERSION-} ]] || ble-attach
