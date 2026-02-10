#!/bin/bash
set -u
f() {
  local t="foo"
  # Fix: Expand variable when setting trap
  trap "echo \"Trap: $t\"" EXIT
}
f
echo "Done"
