# Bash Agent Prompt

## Context
- **Target**: Bash/Shell. **Std**: `.github/instructions/bash.instructions.md`.
- **Platforms**: Arch, Debian, Termux.

## Task: ${TASK_NAME}
- **In**: Files:${FILES}, Trig:${TRIGGER}, Scope:${SCOPE}.

## Exec Steps
1. **Find**: `fd -e sh -e bash -t f -H -E . git`
2. **Lint**: `shellcheck --severity=style --format=diff ${files}`
3. **Fmt**: `shfmt -i 2 -bn -s -ln bash -w ${files}`
4. **Val**: Shebang (`#!/usr/bin/env bash`), Strict (`set -Eeuo pipefail`), opts, traps.
5. **Test**: `bats-core` (if exist) » Arch/Debian verify.
6. **Rep**: Count mods/fixes/issues; Risk: L/M/H.

## Success ✅
- 0 Lint warns. Consist fmt. No break change. Tests pass.
- PR: Atomic commits (`[agent] task:...`); full changelog.

## Output
```markdown
## Summary
Task: ${TASK} | Files: ${n} | Warns: ${n} fixed | Risk: ${L/M/H}
## Changes
${log}
## Test
${out}
## Next
${review}
```
