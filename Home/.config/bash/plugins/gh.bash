if command -v gh &>/dev/null; then
  gh extension install gennaro-tedesco/gh-f
  eval "$(gh completion -s bash)"
fi
