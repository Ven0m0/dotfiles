# Unified Instructions for Copilot & Claude (Optimized)

## Core Principles
- **Autonomous execution:** Act immediately, minimal confirmations.  
- **Edit > create:** Modify existing files first.  
- **Debt-first:** Remove unused code, deps, complexity.  
- **Snowball:** Accumulate/compound context; each change improves future changes.  
- **Subtraction:** Remove clutter → clarity, speed, lower cognitive load.  
- **Transparency:** Show plans, reasoning, alternatives, full paths.  
- **Selective optimization:** Improve only what raises long-term throughput.  
- **Invent & simplify:** Find core insight; simplify aggressively; keep solutions malleable and low-token.

## Communication
- Technical English; blunt, concise, precise.  
- Minimize tokens; compact reasoning; avoid fluff.  
- Surface decisions, tradeoffs, and alternatives directly.

## Workflow
- **TDD:** Red → Green → Refactor.  
- **Atomic commits:** One logical change; tests pass; no lint errors.  
- **Separate concerns:** Format vs logic.  
- **Fail fast:** Early returns, guard clauses.

## Code Quality
- Single responsibility; DRY; composable.  
- Explicit error handling; explicit deps; small focused functions.  
- Remove duplication instantly.  
- Write behavior tests first; refactor after green.

## Language/Tool Rules

### Bash
- `set -euo pipefail`; `shopt -s nullglob globstar`; `IFS=$'\n\t'`.  
- Prefer `[[ ]]`, arrays, `mapfile -t`; avoid `eval` and `ls` parsing.  
- Prefer: `fd`, `rg`, `sd`, `bat`, `fzf` (fallback: find/grep/sed/cut).  
- Lint/format: `shfmt`, `shellcheck`.

### JavaScript
- Prefer **ESM**; minimal deps.  
- Format: `prettier`; Lint: `eslint --max-warnings=0`.  
- Prefer pure functions; immutability; small modules.  
- Async/await; explicit error handling.  
- Avoid implicit `any`; use JSDoc or TS where applicable.

### Python
- Format: `black`; Lint: `ruff`; use type hints.  
- Keep modules/functions small; explicit exceptions; zero unused imports.

### Markdown
- Use `##`/`###`; fenced blocks; soft-wrap ~80–100 columns.

## Performance / Ops
- Measure before optimizing; profile hot paths only.  
- Batch I/O; minimize subprocess spawning.  
- Use caching; async/worker pools.  
- DB: index + verify via `EXPLAIN`.  
- CI: cache deps; parallelize jobs.

## GitHub Actions
- Use OIDC; minimal `permissions`.  
- Cache everything possible; prefer reusable workflows.  
- Run unit/integration/E2E tests; surface results cleanly.

## Claude-Specific
- Works autonomously: edits files directly when safe.  
- Multi-approach reasoning: compare solutions when ambiguity exists.  
- Quality-driven: validate facts; lint/format/apply tests automatically.  
- Use repo structure knowledge: follow conventions; avoid modifying protected files unless explicitly asked.

## Copilot-Specific
- Keep suggestions small, clean, and production-ready.  
- Always align with repo conventions, shell standards, and performance guidelines.  
- Avoid speculative code; prefer verified, minimal diffs.

## Repository Safety Rules
- **Protected files:** Only modify if requested (e.g., pacman.conf, makepkg.conf, sysctl.d/, zshrc, gitconfig).  
- **Safe zones:** Shell scripts, `.config/`, docs, workflows.  
- Follow naming conventions, security rules, and fallback chains.

## Tool Preferences (Global)
- Modern tools first: `fd → find`, `rg → grep`, `sd → sed`, `bat → cat`, `aria2 → curl → wget`.  
- Parallel: `rust-parallel → parallel → xargs`.  
- JSON: `jaq → jq`.  
- Avoid unnecessary forks; batch operations.

## Summary
Operate autonomously, minimally, transparently.  
Remove complexity, compound context, finish high-leverage work, and keep outputs crisp, correct, and production-grade.
