# Copilot — Instructions (condensed, actionable)

## Summary
Act autonomously, prefer edits over new files, verify automatically, remove debt, and optimize for long-term throughput. Be blunt, concise, and token-efficient.

## Core rules
- **Execute:** act immediately; confirm only for destructive/large changes.  
- **Verify:** run formatters/linters/tests automatically.  
- **Prefer edit > create:** modify existing files when possible.  
- **Debt first:** remove unused code/deps; minimize surface area.  
- **Compound context:** build on prior work (Snowball).  
- **Subtract:** remove complexity for clarity.  
- **Transparency:** surface plan, decisions, alternatives; use full paths.

## Communication
- Technical English; concise; minimize tokens; prefer short syntax.

## Workflow & commits
- **TDD:** Red → Green → Refactor.  
- **Separate concerns:** format vs logic in separate commits.  
- **Atomic commits:** small, self-contained; tests pass; no lint warnings.  
- **Fail fast:** guard clauses; early returns.

## Code quality
- Single responsibility; loose coupling; DRY.  
- Composable abstractions; write tests for behavior; refactor after green.

## Language/tooling

### Bash
- `set -euo pipefail`; `shopt -s nullglob globstar`; `IFS=$'\n\t'`.  
- Prefer `[[ ]]`, arrays, `mapfile -t`; avoid `eval` and `ls` parsing.  
- Lint: `shfmt`, `shellcheck -a -x`.  
- Prefer: `fd`, `rg`, `sd`, `bat`, `fzf` (fallback: find/grep/sed/cut).

### JavaScript
- Use **ESM** (`type: module`) unless project dictates otherwise.  
- Format: `prettier`; Lint: `eslint --max-warnings=0`.  
- Prefer pure functions, immutability, small modules.  
- Avoid implicit `any`; use JSDoc types or TS when available.  
- Use async/await; avoid callback pyramids; handle errors explicitly.  
- Keep dependencies minimal; remove unused deps; prefer stdlib.

### Python
- Format: `black`; lint: `ruff`; type hints encouraged.  
- Prefer small functions/modules; explicit error handling; no unused imports.

### Markdown
- Use `##`/`###`; fenced code blocks; soft wrap ~80–100 columns.

## Performance & ops
- Measure first; optimize hot paths only.  
- Batch I/O; cache appropriately; leverage async/worker pools.  
- DB: proper indexing; verify via `EXPLAIN`.  
- CI: cache deps/build artifacts; parallelize via matrices.

## GitHub Actions
- Use OIDC; minimal `permissions`.  
- Cache deps; use reusable workflows/composites.  
- Run unit/integration/E2E tests; surface results clearly.

---
Keep outputs compact, actionable, and change-focused.
