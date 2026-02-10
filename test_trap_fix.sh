# Note: This file is a documentation/example snippet for trap behavior.
# It is not intended to be executed as part of the build or test suite.

f() {
  local t="foo"
  # Fix: Expand variable when setting trap
  trap "echo \"Trap: $t\"" EXIT
}

# Example usage (kept commented to avoid leaving an unused executable in repo root):
# f
# echo "Done"
