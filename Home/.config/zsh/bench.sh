#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# Zsh Startup Benchmark
# ============================================================================
readonly ITERATIONS=10
benchmark(){
  local total=0 i
  printf 'Running %d iterations...\n' "$ITERATIONS"
  for ((i = 1; i <= ITERATIONS; i++)); do
    local start end elapsed
    start=$(date +%s%N)
    zsh -i -c exit &>/dev/null
    end=$(date +%s%N)
    elapsed=$(((end - start) / 1000000))
    total=$((total + elapsed))
    printf '  Run %2d: %4dms\n' "$i" "$elapsed"
  done
  local avg=$((total / ITERATIONS))
  printf '\nAverage: %dms\n' "$avg"
  # Performance rating
  if [[ $avg -lt 300 ]]; then
    printf 'Rating: ⚡ Excellent\n'
  elif [[ $avg -lt 500 ]]; then
    printf 'Rating: ✓ Good\n'
  elif [[ $avg -lt 800 ]]; then
    printf 'Rating: ⚠ Acceptable\n'
  else
    printf 'Rating: ✗ Slow (consider more optimizations)\n'
  fi
}

main(){
  if ! command -v zsh &>/dev/null; then
    printf 'Error: zsh not found\n' >&2
    exit 1
  fi
  printf '=== Zsh Startup Benchmark ===\n\n'
  benchmark
  printf '\n=== Plugin Check ===\n'
  if command -v zsh-defer &>/dev/null; then
    printf '✓ zsh-defer available\n'
  else
    printf '✗ zsh-defer not found\n'
  fi
  if command -v lazyload &>/dev/null; then
    printf '✓ lazyload available\n'
  else
    printf '✗ lazyload not found\n'
  fi
}

main "$@"
