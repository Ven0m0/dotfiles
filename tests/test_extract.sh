#!/usr/bin/env bash
set -euo pipefail

# Sourcing the file under test
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$REPO_ROOT/Home/.bash_functions" ]]; then
  source "$REPO_ROOT/Home/.bash_functions"
else
  printf 'ERROR: Home/.bash_functions not found\n' >&2
  exit 1
fi

die() {
  printf '\e[31mERROR: %s\e[0m\n' "$*" >&2
  exit 1
}

# Setup
test_file="test_unsupported.xyz"
touch "$test_file"

echo "Running test: extract with unsupported format..."

# Capture output and exit code
# extract returns 1 on failure
set +e
# extract prints to stderr
stderr=$(extract "$test_file" 2>&1)
exit_code=$?
set -e

# Cleanup
rm "$test_file"

# Assertions
if [[ $exit_code -ne 1 ]]; then
  die "Expected exit code 1, but got $exit_code"
fi

if [[ "$stderr" != *"Unsupported format: $test_file"* ]]; then
  die "Expected error message to contain 'Unsupported format: $test_file', but got '$stderr'"
fi

echo "Test passed!"
