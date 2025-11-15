# Quick git add, commit, and push
gpush() {
  LC_ALL=C git add -A && \
  LC_ALL=C git commit -m "${1:-Update}" && \
  LC_ALL=C git push -q --recurse-submodules=on-demand
}
