---
description: Run all linters and formatters (shellcheck, shfmt, yamllint, taplo, jaq, biome). Show violations and auto-fix where possible.
agent: build
---

Run the full lint/format suite on the repository. Execute the following and report all violations:

```bash
# Shell scripts
shfmt -d -i 2 -bn -ci -sr Home/.local/bin/*.sh Home/.bashrc Home/.bash_functions 2>&1 | head -60
shellcheck -S style -x Home/.local/bin/*.sh 2>&1 | head -80

# YAML
yamllint -s Home/.config/**/*.{yml,yaml} .github/workflows/*.yml 2>&1 | head -40

# TOML
taplo lint **/*.toml 2>&1 | head -30

# JSON
for f in $(fd -e json -e jsonc . Home/ .github/ --exclude node_modules); do
  jaq empty "$f" 2>&1 | grep -v '^$' && echo "  → $f"
done

# JS/TS via biome
biome check Home/ 2>&1 | head -40
```

For each tool that fails:
1. Show the exact error and file:line
2. Classify as: auto-fixable vs manual
3. Apply auto-fixes (shfmt -w, yamlfmt, taplo format) and re-check

Report summary: N errors, M warnings, K auto-fixed.
