# Additional Wine/NVIDIA settings (main config in bashenv.env)
if command -v wine &>/dev/null; then
  export WINEPREFIX="$XDG_DATA_HOME"/wine
fi

