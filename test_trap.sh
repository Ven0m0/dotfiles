#!/bin/bash
set -u
f() {
  local t="foo"
  trap 'echo "Trap: $t"' EXIT
}
f
echo "Done"
