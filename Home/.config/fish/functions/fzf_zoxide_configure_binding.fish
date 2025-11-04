function fzf_zoxide_configure_binding --description "Sets zoxide fzf keybinding. Override default (\cz) by calling with the new binding as args"
  status is-interactive; or return

  set -f key \cz
  set -q argv[1]; and set key $argv[1]
  for mode in default insert
    bind --mode $mode $key _fzf_search_zoxide
  end
end
