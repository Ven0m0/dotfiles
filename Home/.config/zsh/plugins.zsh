# plugin list
plugins=(
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-syntax-highlighting
)

# plugin function
function plugin-load {
  local repo plugdir initfile initfiles=()
  : "${ZPLUGINDIR:=${XDG_DATA_HOME:-${HOME}/.local/share}/zsh/plugins}"
  for repo in "$@"; do
    plugdir=$ZPLUGINDIR/${repo:t}
    initfile=$plugdir/${repo:t}.plugin.zsh
    if [[ ! -d $plugdir ]]; then
      echo "Cloning $repo..."
      git clone -q --depth 1 --filter=blob:none --single-branch --also-filter-submodules --no-tags --shallow-submodules \
        https://github.com/"$repo" "$plugdir"
    fi
    if [[ ! -e $initfile ]]; then
      initfiles=("$plugdir"/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
      (( $#initfiles )) || { echo >&2 "No init file found '$repo'." && continue }
      ln -sf "$initfiles"[1] "$initfile"
    fi
    fpath+=$plugdir
    (( $+functions[zsh-defer] )) && zsh-defer . "$initfile" || . "$initfile"
  done
}

# automatically run
plugin-load "$plugins"
