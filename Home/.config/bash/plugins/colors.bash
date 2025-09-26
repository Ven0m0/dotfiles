# Vivid (https://github.com/sharkdp/vivid)
if command -v vivid &> /dev/null; then
    export VIVID_THEME="molokai"
    export LS_COLORS="$(vivid generate)"
fi
