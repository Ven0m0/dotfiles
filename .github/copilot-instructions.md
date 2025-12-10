# GitHub Copilot Dev Guardrails

**Purpose:** Code generation guardrails for GitHub Copilot **Model:** copilot (GPT-4 based) **Tone:** Blunt, precise.
Result-first. Lists ≤7

## Core Principles

1. User cmds > Rules
2. Edit > Create (min diff)
3. Subtraction > Addition
4. Align w/ existing patterns

## Bash Standards

- **Native:** Arrays over string splits. `set -euo pipefail`.
- **Idioms:** `[[ regex ]]`, `mapfile -t`, `local -n`, `printf`, `ret=$(fn)`.
- **Ban:** `eval`, parsing `ls`, backticks, unneeded subshells.
- **Safe:** Quote all vars. `"${var}"` not `$var`.
- **Format:** 2-space indent. Short args (`-a` not `--all`).
- **CI:** shfmt + shellcheck clean required.

## Toolchain Preference

fd → find | rg → grep | bat → cat | sd → sed | aria2 → curl | jaq → jq | rust-parallel → xargs

## Performance

- **Min forks:** Prefer builtins. Batch I/O. Avoid pipes where possible.
- **Regex:** Anchor patterns. Use `grep -F` for literals.
- **Async:** Background tasks for I/O. Wait at sync points.

## Code Style

- **Fmt:** 2-space indent. Strip invisibles (U+202F/200B/00AD).
- **Output:** Result-first. Lists ≤7 items.
- **Abbr:** cfg, impl, deps, val, opt, Δ.

## Quality Gates

- **Prompts:** Compact, optimal, secure code. Prefer builtins.
- **CI:** markdownlint. shellcheck. shfmt. Ensure CLAUDE.md exists.
- **Validation:** No syntax errors. All scripts executable.

## Example

**Task:** Generate file search function **Input:** "Find all .sh files modified in last 7 days" **Output:**

```bash
fd -e sh -t f --changed-within 7d
```

**Result:** Prefers `fd` over `find` per toolchain standards.
