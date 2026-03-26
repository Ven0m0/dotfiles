---
description: Validate all shell scripts for syntax and lint correctness. Show failures with file and line context.
agent: build
---

Run syntax and lint validation across all shell scripts and configs in this dotfiles repo.

```bash
# 1. Bash syntax check
echo "=== Syntax Check ==="
for f in $(fd -e sh -e bash . Home/.local/bin/ Home/ --max-depth 2); do
  bash -n "$f" 2>&1 && echo "OK: $f" || echo "FAIL: $f"
done

# 2. ShellCheck with context
echo "=== ShellCheck ==="
shellcheck -x -S warning Home/.local/bin/*.sh 2>&1

# 3. Python syntax check
echo "=== Python Syntax ==="
for f in $(fd -e py . Home/.local/bin/); do
  python3 -m py_compile "$f" && echo "OK: $f" || echo "FAIL: $f"
done

# 4. YAML validation
echo "=== YAML Validation ==="
yamllint -s .github/workflows/*.yml Home/.config/lefthook.yml 2>&1

# 5. JSON validation
echo "=== JSON Validation ==="
for f in $(fd -e json . Home/ .opencode/ --exclude node_modules); do
  jaq empty "$f" 2>&1 || echo "FAIL: $f"
done
```

For each failure:
1. Show exact error output with file:line
2. Explain what rule is violated (e.g., SC2086: unquoted variable)
3. Suggest minimal fix following bash.instructions.md standards

Do NOT suggest refactors beyond the failing line. Fix the lint error only.
