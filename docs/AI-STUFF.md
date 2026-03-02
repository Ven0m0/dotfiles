# LLM Prompts

> Copy-paste prompts for AI-assisted development. Each prompt is self-contained and executable.

<details><summary><b>PR Commands</b></summary>

```text
@dependabot rebase
```
```text
@gemini-code-assist review 
```
```text
@copilot 
```
```text
@codex[agent]
```
```text
@claude 
```
```text
@cursoragent
```
```text
@jules 
```
</details>

---
## Quick Tasks
<details><summary><b>🔍 Audit</b> — Quality, security, correctness sweep</summary>
  
```text
Audit codebase for quality, security, and correctness. <use_parallel_tool_calls>Use `rg` to find files.</use_parallel_tool_calls> Use ultrathink.
Scope: all source files. Exclude: .git/, node_modules/, vendor/, dist/, .venv/, generated/.
Steps:
1. Duplicate logic: rg for repeated patterns >10 lines across files, propose shared functions
2. Performance: identify O(n²)+ paths, blocking I/O in async, unnecessary allocations, missing caches
3. Bugs/edge cases: unchecked errors, race conditions, off-by-one, null/undefined access, resource leaks
4. Bad practices: hardcoded secrets, magic numbers, dead code, unreachable branches, implicit any
5. Dependencies: flag CVEs (check advisories), unmaintained (>2yr no release), duplicated, unused
6. Resolve all TODO/FIXME that are trivial (<10 min effort). List remaining with severity.
7. Format per language: biome (JS/TS) | ruff (Python) | rustfmt+clippy (Rust) | shfmt+shellcheck+shellharden (Shell)
<investigate_before_answering>
Output: summary table (file|issue|severity|fix), unified diffs, risk assessment (breaking changes, data loss potential).
</investigate_before_answering>
```
</details>
<details><summary><b>📦 Deps</b> — Dependency audit and update</summary>

```text
Audit and update all dependencies. <use_parallel_tool_calls>Use `rg` to find lockfiles, manifests, import statements.</use_parallel_tool_calls>
Steps:
1. Inventory: list all deps with current version, latest version, last publish date, weekly downloads
2. CVEs: cross-reference with known advisories, flag severity (critical/high/medium/low)
3. Unused: trace imports with rg, flag deps imported nowhere. Check for transitive-only usage.
4. Bloat: identify deps replaceable with builtins or lighter alternatives (e.g., lodash → native, moment → Temporal/dayjs)
5. Outdated: categorize as patch/minor/major. Apply patch+minor automatically. Major: note breaking changes.
6. Duplicates: find multiple versions of same package in lockfile, dedupe where possible.
7. Apply updates respecting semver. Regenerate lockfiles. Verify build passes after changes.
<investigate_before_answering>
Output: table (package|current|latest|status|action), update commands, migration notes for major bumps, before/after lockfile size.
</investigate_before_answering>
```
</details>
<details><summary><b>📋 TODOs</b> — Extract and resolve TODOs/FIXMEs</summary>

```text
<investigate_before_answering>
Extract and resolve TODOs/FIXMEs across entire codebase.
</investigate_before_answering>
<use_parallel_tool_calls>
Use `rg` to find all occurrences.
Pattern: rg -n "TODO|FIXME|HACK|XXX|WARN|DEPRECATED" --type-add 'src:*.{sh,bash,py,ts,tsx,js,jsx,rs,go,lua,yml,yaml,toml}'
</use_parallel_tool_calls>
Steps:
1. Extract all matches with file, line number, surrounding context (3 lines)
2. Categorize: trivial (type fix, rename, add guard) | moderate (refactor, new function) | complex (architecture, new feature)
3. Resolve all trivial items inline — apply the fix, remove the TODO comment
4. For moderate: create actionable description with estimated LOC change
5. For complex: note as backlog with suggested approach
Output: completion report (resolved count/total), diffs for resolved items, remaining backlog table (file|line|category|description).
```
</details>
<details><summary><b>🧹 Cleaner</b> — Aggressive dead code removal</summary>

```text
Aggressive code cleanup and deduplication. Use `rg` to find files. Use ultrathink.
Exclude: .git/, node_modules/, vendor/, dist/, .venv/, generated/, *.min.*, *.lock
Steps:
1. Dead code: remove unused functions, unreachable branches, commented-out code, unused imports/variables
2. Dead paths: find files with zero importers/references via rg, confirm unused, delete
3. Stale deps: remove packages not imported anywhere (verify transitive usage first)
4. Flatten: inline single-use abstractions, unwrap unnecessary wrapper functions, simplify nested conditionals
5. Merge: files with >80% similar content → combine into one with parameters for differences
6. Normalize: 2-space indent (except Python: 4), 120-char max line width, LF line endings
7. Strip: remove emoji from source code, delete comments that restate the code, remove empty catch blocks
8. Preserve: do NOT touch tests, docs, configs, or generated files unless explicitly broken
Output: before/after metrics (file count, total LOC, total bytes), unified diffs, list of deleted files/functions.
```
</details>
<details><summary><b>⚡ AIO</b> — All-in-one refactor + fix + update + format</summary>

```text
All-in-one: refactor, fix, update, and format entire codebase. Use `rg` to find files. Use ultrathink.
Exclude: .git/, node_modules/, vendor/, dist/, .venv/, generated/
Execution order (dependencies matter):
1. Deps: audit for CVEs/outdated/unused/bloat → apply safe updates (patch+minor), flag majors
2. Dedup: rg for repeated logic >10 lines → extract to shared functions/modules
3. Bugs: fix error handling, null checks, race conditions, resource leaks, off-by-one
4. Perf: eliminate O(n²)+, replace sync I/O in async paths, add missing caches, lazy-load heavy imports
5. TODOs: resolve trivial TODO/FIXME/HACK inline, list remaining
6. Format per language:
   Shell: shfmt -i 2 -bn -ci → shellcheck --severity=error → shellharden --replace
   JS/TS: biome format --write → biome check --write --unsafe
   Python: ruff format → ruff check --fix
   Rust: cargo fmt → cargo clippy -D warnings
   YAML: yamlfmt → yamllint
7. Verify: ensure build/lint passes after all changes
Output: summary table (category|files changed|issues fixed), unified diffs grouped by category, risk notes (breaking changes, behavior changes), LOC delta.
```
</details>
<details><summary><b>🗑️ Cleanup</b> — Filesystem and formatting normalization</summary>

```text
Filesystem and formatting cleanup. Use `rg`/`fd` to find files. Use ultrathink.
Phase 1 — Delete junk:
  fd -tf -e log -e bak -e tmp -e swp -e orig -e rej | xargs rm -f
  Remove: build artifacts not in .gitignore, empty directories, duplicate files (by hash), .DS_Store, Thumbs.db
  Remove: redundant/dead text files, zero-byte files (except intentional __init__.py)
Phase 2 — Normalize text:
  Strip trailing whitespace on all text files. Normalize line endings to LF. Ensure exactly 1 trailing newline.
  Collapse 3+ consecutive blank lines to max 2. Remove BOM from UTF-8 files.
Phase 3 — Format per language:
  YAML: yamlfmt → yamllint -f parsable | JSON: biome format (or jq -S .) | JS/TS: biome format --write → biome check --write
  Shell: shfmt -i 2 -bn -ci -ln bash → shellcheck → shellharden --replace | Python: ruff format → ruff check --fix
  Markdown: markdownlint --fix (or mdformat) | All text: codespell --write-changes (skip vendored/generated)
Phase 4 — Validate:
  Verify no broken imports, configs parse correctly, build still passes.
Output: deleted files list, before/after byte counts per phase, format diffs, codespell corrections table.
```
</details>

---
## Language-Specific Refactors
<details><summary><b>🐚 Bash 5.2+</b> — Maximum-density modern bash refactoring</summary>

```text
<instructions>Refactor shell scripts to latest bash (5.2+), maximizing bashisms and density</instructions>. <use_parallel_tool_calls>Use `rg` to find files. Use ultrathink.</use_parallel_tool_calls>
Target: *.sh, *.bash, rc/profile files. Convert POSIX sh → bash where beneficial.
Exclude: .git/, node_modules/, vendor/, generated/, third-party scripts.
<formatting>2 space indentation, max 1 nempty newline, 120 line lengt, follow editorconfig</formatting>
── Prologue (required for all scripts) ──
<examples>

#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar; IFS=$'\n\t' LC_ALL=C
cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null
has(){ command -v -- "$1" &>/dev/null; }
</examples>
<rules>

── Whitespace: absolute minimum ──
Zero blank lines between functions unless readability demands exactly one.
fn(){ body; } — no space before brace, no space after {, compact single-line where ≤100 chars.
No trailing whitespace anywhere. No space in redirects: >&2, &>/dev/null, <file.
No space around = in assignments: x=1 not x = 1. No space inside [[ ]]: [[ -f $x ]] not [[  -f  $x  ]].
Inline case arms: pat) cmd1; cmd2 ;; — one-line unless >100 chars.
Semicolons to chain: mkdir -p "$d"; cd "$d" instead of separate lines for trivial sequences.
shfmt -i 2 -bn -ci -ln bash -mn (minify where safe).
── Bash 5.2+ features (prefer over older patterns) ──
${var@Q} for quoting, ${var@U}/${var@L} for case conversion (not tr/awk).
${var@a} for attribute inspection. ${!prefix@} for indirect expansion.
wait -p REPLY for async job harvesting. shopt -s patsub_replacement for regex-like substitution.
readarray/mapfile -t -d '' for null-delimited. printf -v for variable capture (no subshell).
Associative arrays (declare -A) over awk/sed key-value parsing. local -n namerefs over eval.
${EPOCHSECONDS} and ${EPOCHREALTIME} over $(date +%s). $SRANDOM over $RANDOM for better entropy.
Brace expansion {1..100} and sequence expressions over seq. (( )) for all arithmetic, never expr.
── Forbidden (never emit, always replace) ──
eval | parsing ls | unquoted expansions | unnecessary subshells ($() where ${} works)
curl|bash | echo -e/-n (use printf) | test/[ (use [[ ]]) | seq (use {n..m})
cat file|cmd (use cmd <file or $(<file)) | basename/dirname on vars (use ${var##*/}/${var%/*})
External tools when builtins suffice: grep→[[ =~ ]], cut→${var:o:l}, wc -l→${#arr[@]}, tr→${var@U}
Unnecessary quoting of literal strings in non-expansion context. Useless semicolons before done/fi/esac.
── Safety: DO NOT modify ──
Heredocs (<<EOF blocks) | single-quoted blocks with special chars
Regex-heavy =~ lines | intentional [ ] for POSIX compat (if documented)
── Inline/Extract rules ──
Inline: ≤6 lines + ≤2 calls + no complex flow → inline at call site.
Extract: >50 tokens + ≥3 occurrences → function with local vars. No sourcing; standalone only.
── Idioms (replace old patterns) ──
Builtins first: ${#var}, ${var//old/new}, ${var:offset:length}, ${var^^}/${var,,}
mapfile -t arr < <(cmd) over arr=($(cmd)). read -ra over manual IFS splitting.
while IFS= read -r line; do ...; done <file over for line in $(cat file).
printf '%s\n' over echo. local -r for constants. declare -g for global-from-function.
Parallel I/O: limited &+wait -n. Process substitution <() over temp files.
</rules>
<examples>

── Helpers (include only if used) ──
die(){ printf '%s\n' "$*" >&2; exit 1; }
fcat(){ printf '%s\n' "$(<"$1")"; }
sleepy(){ read -rt "${1:-1}" -- <> <(:) &>/dev/null||:; }
</examples>
<action>

── Pipeline ──
1. Parse and transform → 2. shfmt -i 2 -bn -ci -ln bash -w → 3. shellcheck -S error -f diff
4. shellharden --replace → 5. shellcheck (final, must pass clean)
</action>

── Output ──
Plan (3-6 lines), unified diff, standalone script(s), risk notes, LOC before/after with % reduction.
```
</details>
<details><summary><b>🐍 Python 3.13+</b> — Strict typed performant refactoring with uv</summary>

```text
Refactor Python to latest (3.13+), strictly typed, performant code. Use `rg` to find files. Use ultrathink.
Exclude: .git/, __pycache__/, .venv/, dist/, generated/, *_pb2.py
Package management: uv only (never pip/pipx/poetry/pipenv). uv run, uv add, uv sync, uv lock.
── Pipeline ──
uv run ruff format → uv run ruff check --fix --unsafe-fixes → uv run mypy --strict → uv run pytest --durations=0
All tools invoked via uv run (no global installs). pyproject.toml as single config source.
── Python 3.13+ features (prefer over older patterns) ──
type X = ... aliases (PEP 695) over TypeAlias. Generic classes/functions with [T] syntax (PEP 695).
match/case for complex conditionals (structural pattern matching).
list[str], dict[str, int], str | None — never Optional, Union, List, Dict from typing.
Self type for fluent returns. TypeGuard/TypeIs for narrowing. @override decorator.
ExceptionGroup + except* for concurrent error handling. TaskGroup over gather.
tomllib (stdlib) for TOML. pathlib everywhere (never os.path).
dataclasses with slots=True, frozen=True defaults. NamedTuple for immutable records.
f-string = debugging: f"{var=}". Walrus operator := where it reduces lines.
── Types ──
Full hints on all functions including return. No Any without documented justification.
Protocol over ABC for structural typing. TypedDict for dict-shaped data at boundaries.
@dataclass(slots=True) on all data classes. Literal types for string enums.
── Performance ──
orjson > json (3-10x faster) | httpx > requests (async native) | uvloop > asyncio default
csv.DictReader > pandas for ETL | Generators/itertools for large data (never materialize needlessly)
Target O(n)+. dict/set lookups over list scans. __slots__ on hot-path classes.
functools.cache/lru_cache for expensive pure functions. sys.intern for repeated string comparison.
── Async ──
asyncio.TaskGroup (not gather). asyncio.to_thread for sync→async. Never mix sync+async I/O.
async generators for streaming. anyio for framework-agnostic async when needed.
── Style ──
Atomic functions: single responsibility, max 50 lines, max 5 params. snake_case/PascalCase/UPPER_SNAKE.
Specific exceptions: raise ValueError("msg") from e — never bare except. No module-level mutable globals.
Import order: stdlib → third-party → local (ruff isort). One class per file for large classes.
── Tests ──
uv run pytest + fixtures + parametrize. hypothesis for property-based testing.
Minimum 80% line coverage. Edge cases: empty, None, boundary, error paths.
── Output ──
Plan (5-10 lines), type-checked code (ruff+mypy clean), coverage summary, perf notes, migration guide.
```
</details>
<details><summary><b>📘 JS/TS</b> — Modern strict TypeScript refactoring with bun</summary>

```text
Refactor JS/TS to modern, strict, performant code. Use `rg` to find files. Use ultrathink.
Discovery: fd -tf -e js -e jsx -e ts -e tsx -e mjs -e cjs -E node_modules -E .git -E dist -E .next
Runtime and package management: bun only (never npm/pnpm/yarn/node for execution).
bun add, bun remove, bun install, bun run, bun test, bunx for one-off tools.
── Pipeline ──
biome format --write . → biome check --write --unsafe . → oxlint -D all --deny-warnings
For TS: tsc --noEmit (type check without build). Prefer bunx biome / bunx oxlint.
── Bun-specific patterns (prefer over Node equivalents) ──
Bun.file() / Bun.write() over fs.readFile/writeFile. Bun.serve() over express/fastify for HTTP.
Bun.spawn/Bun.spawnSync over child_process. Bun.env over process.env (typed).
bun:test over jest/vitest: import { test, expect, describe } from "bun:test".
bun:sqlite for embedded DB. Bun.Glob for file matching. Bun.password for hashing.
Bun.peek() for promise inspection. Bun.sleep() over setTimeout promisified.
Import from "bun" for types: import type { Server, Subprocess } from "bun".
Use bunfig.toml for bun configuration. workspace support via package.json workspaces.
── Style ──
2-space indent, double quotes, trailing commas, semicolons.
const over let (never var). Arrow functions for callbacks. Template literals over concat.
Destructuring for object/array access. ?. and ?? over manual null checks.
satisfies over as. unknown over any. readonly where immutable. using keyword for disposables.
── TypeScript strict mode ──
Enable: strict, noUncheckedIndexedAccess, exactOptionalPropertyTypes, verbatimModuleSyntax.
No any without documented justification. Interfaces for object shapes. Discriminated unions for state.
Generics with constraints: <T extends Base>. Zod/valibot at boundaries (API inputs, env, config).
import type for type-only imports (enforced by verbatimModuleSyntax).
── Performance ──
No O(n²): Map/Set for lookups, avoid nested .find()/.filter(). for...of over .forEach() in hot paths.
Dynamic import() for heavy modules. structuredClone over JSON roundtrip. Avoid spread in loops.
Bun's FFI (bun:ffi) for native performance-critical code. Worker threads via new Worker().
Use Response/Request web standard APIs — bun implements WinterCG.
── Error handling ──
Custom error classes extending Error. Never throw strings. catch (error: unknown).
Result pattern for expected failures. try/catch only at boundaries.
── Output ──
Summary table (File|Status|Biome|Oxlint|Type Errors|Notes), unified diffs, migration notes.
```
</details>
<details><summary><b>🦀 Rust</b> — Idiomatic safe performant refactoring</summary>

```text
Refactor Rust to idiomatic, safe, performant code. Use `rg` to find files. Use ultrathink.
Exclude: .git/, target/, generated/, *_pb.rs, build.rs (unless buggy)
── Pipeline (execute in order) ──
cargo fmt → cargo clippy -- -D warnings -W clippy::pedantic → cargo test → cargo build --release
── Idioms ──
Result/Option chains over match nesting: .map(), .and_then(), .unwrap_or_else(), ? operator.
Prefer iterators over index loops. Use .collect() with turbofish for type inference.
Cow<str> for functions accepting both owned and borrowed. impl Into<String> for flexible APIs.
Use #[must_use] on pure functions returning values. derive(Debug, Clone, PartialEq) on all public types.
thiserror for library errors, anyhow for application errors. Never .unwrap() in library code.
── Performance ──
Avoid unnecessary allocations: &str over String, &[T] over Vec<T> in function params.
Use SmallVec for small collections. Prefer stack allocation where size is known at compile time.
rayon for CPU-bound parallelism. tokio for async I/O. Never block async runtime with sync I/O.
Use #[inline] sparingly — only on small hot-path functions. Profile before optimizing.
── Safety ──
Zero unsafe blocks without documented safety invariants and // SAFETY: comment.
Prefer Arc<Mutex<T>> over raw pointers. Use Pin only when implementing Future/Stream.
No mem::transmute without exhaustive justification. Prefer TryFrom over as casts.
── Style ──
Max 50 lines per function. Modules over large files. pub(crate) as default visibility.
Doc comments (///) on all public items with examples. #[cfg(test)] mod tests in same file.
── Output ──
Plan (5-10 lines), clippy-clean code, test results, benchmark comparisons if perf-critical, MSRV impact notes.
```
</details>
<details><summary><b>🐳 Docker</b> — Dockerfile and compose optimization</summary>

```text
Optimize Dockerfiles and compose configs. Use `rg` to find Dockerfile*, compose*.yml. Use ultrathink.
── Dockerfile ──
Multi-stage builds: separate build and runtime stages. Final stage from distroless/alpine/scratch.
Pin base images to specific digest or version tag (never :latest).
Order layers by change frequency: deps install → copy source → build (maximize cache hits).
Combine RUN commands with && to reduce layers. Use --no-install-recommends (apt) or --no-cache (apk).
COPY specific files over COPY . — avoid invalidating cache with unrelated changes.
Non-root USER in final stage. HEALTHCHECK on long-running services.
Use .dockerignore: .git, node_modules, dist, .venv, __pycache__, *.md, .env
── Compose ──
Use profiles for optional services. Named volumes over bind mounts for persistence.
Resource limits: deploy.resources.limits on memory and CPU. depends_on with condition: service_healthy.
Environment variables via env_file, never hardcoded. Use secrets for sensitive values.
── Security ──
No secrets in build args or ENV. Use --mount=type=secret for build-time secrets.
Scan with trivy/grype. Pin package versions in RUN install commands.
Read-only root filesystem where possible: read_only: true + tmpfs for writable paths.
── Output ──
Optimized Dockerfile(s), compose.yml, .dockerignore, image size before/after, layer analysis, security scan results.
```
</details>

---
## CI/CD & Tooling
<details><summary><b>⚙️ GitHub Actions</b> — Fix, harden, optimize workflows</summary>

```text
Fix, harden, and optimize CI/CD workflows. Use `rg` to find .github/workflows/*.yml. Use ultrathink.
── Security ──
Explicit permissions block on every workflow AND job (least privilege: contents: read default).
Never echo secrets or use secrets in run step interpolation (${{ secrets.* }} in env: only).
Pin third-party actions to latest stable version tag (e.g., actions/checkout@v4, NOT @main, NOT SHA pins).
Use environment protection rules for deployment jobs. No pull_request_target with checkout of PR head.
── Fixes ──
Replace deprecated: set-output → $GITHUB_OUTPUT, save-state → $GITHUB_STATE, ::set-env → $GITHUB_ENV.
Add timeout-minutes to every job (default: 30, max: 60). Add continue-on-error only where explicitly needed.
Fix YAML syntax errors. Ensure all `uses:` reference existing action versions.
Add `if: success()` / `if: always()` explicitly where failure handling matters.
── Performance ──
Concurrency groups: cancel in-progress on PR push: concurrency: { group: ${{ github.workflow }}-${{ github.ref }}, cancel-in-progress: true }
Cache dependencies: actions/cache or built-in cache (setup-node, setup-python, etc.).
fetch-depth: 1 for checkouts (unless history needed). Shallow submodules if used.
Matrix parallelism where applicable, max 7 combinations. Split slow tests into shards.
Use `paths:` and `paths-ignore:` filters to skip irrelevant workflows.
── Validation pipeline ──
yamlfmt → yamllint → actionlint → verify all referenced secrets exist in repo settings.
── Constraints ──
Max 20 workflow files. Max 20 min expected runtime per job. Max 7 matrix combinations.
No workflow_dispatch without input validation. No self-hosted runners without security review.
── Output ──
Analysis table (workflow|issue|severity|fix), unified diffs, new/modified workflow files, validation results (actionlint output), rollback plan (previous working versions).
```
</details>
<details><summary><b>🔧 Lint/Format Orchestrator</b> — Multi-language quality pipeline</summary>

```text
Orchestrate multi-language linting and formatting across entire codebase.
Use `rg`/`fd` to discover files by language. Use ultrathink.
Exclude: .git, node_modules, vendor, dist, .venv, __pycache__, *.min.*, generated/
── Rules ──
Always format BEFORE lint (formatters may fix lint issues). Batch with xargs -P$(nproc) where safe.
Exit non-zero on any lint failure in CI. In interactive mode, fix what's auto-fixable, report rest.
── Language pipelines (format → lint) ──
YAML:      yamlfmt -w        → yamllint -f parsable -d '{extends: default, rules: {line-length: {max: 140}}}'
JSON:      biome format      → biome check (or jq -S . for standalone files)
JS/TS:     biome format --write → biome check --write --unsafe → oxlint -D all
Shell:     shfmt -w -i 2 -bn -ci -ln bash → shellcheck --severity=error -f gcc → shellharden --replace
Fish:      fish_indent -w
TOML:      taplo fmt         → taplo lint (or tombi lint)
Markdown:  mdformat          → markdownlint --fix
Actions:   yamlfmt           → yamllint → actionlint
Python:    ruff format       → ruff check --fix --unsafe-fixes
Rust:      cargo fmt         → cargo clippy -- -D warnings
Lua:       stylua            → selene
Go:        gofmt -w -s       → golangci-lint run
CSS:       biome format      → biome check (or stylelint --fix)
── Execution strategy ──
Detect languages present via fd/rg. Only run pipelines for detected languages.
Run independent language pipelines in parallel. Collect all results before reporting.
If a formatter modifies a file, re-run its linter to verify fix didn't introduce new issues.
── Output ──
Orchestration script (executable, standalone), per-language error reports, summary table (language|files|formatted|lint errors|fixed|remaining), CI-compatible exit code (0 = clean, 1 = unfixed issues).
```
</details>
<details><summary><b>🔒 Security Scan</b> — Vulnerability and secret detection</summary>

```text
Comprehensive security audit of codebase. Use `rg` to find files. Use ultrathink.
Exclude: .git/, node_modules/, vendor/, dist/, test fixtures, *.min.*
── Secrets detection ──
rg for patterns: API keys, tokens, passwords, private keys, AWS credentials, connection strings.
Patterns: rg -i '(api[_-]?key|secret|password|token|bearer|auth)["\s]*[:=]\s*["\047][^"\047]{8,}' --type-not binary
Check: .env files committed to git, hardcoded credentials in configs, base64-encoded secrets.
Verify .gitignore covers: .env*, *.pem, *.key, id_rsa*, credentials.json
── Dependency vulnerabilities ──
npm audit / pnpm audit | pip-audit | cargo audit | govulncheck ./...
Flag: critical/high CVEs, outdated deps with known exploits, typosquatting risk.
── Code patterns ──
SQL injection: string concatenation in queries (use parameterized). XSS: unescaped user input in HTML/templates.
Path traversal: unsanitized file paths from user input. SSRF: user-controlled URLs in fetch/request.
Insecure deserialization: pickle.loads, eval, Function(), yaml.load (use safe_load).
Weak crypto: MD5/SHA1 for security purposes, ECB mode, hardcoded IVs.
── Config ──
CORS: overly permissive origins. CSP headers: missing or too broad. HTTPS: mixed content, missing redirects.
Permissions: overly broad file permissions (777/666), unnecessary root/admin access.
── Output ──
Findings table (file|line|severity|category|description|fix), remediation diffs, secrets to rotate list, dependency update commands.
```
</details>
<details><summary><b>📦 Dependency Optimizer</b> — Modernize, slim, and secure all deps</summary>

```text
Deep dependency optimization across all ecosystems. Use `rg` to find manifests and lockfiles. Use ultrathink.
Scope: package.json, pyproject.toml, Cargo.toml, go.mod, and their lockfiles.
Exclude: .git/, node_modules/, vendor/, .venv/
── Phase 1: Inventory ──
Map every dep: name, current version, latest version, last publish date, install size, weekly downloads.
Detect ecosystem: bun (JS/TS) | uv (Python) | cargo (Rust). Never use npm/pip/yarn.
rg import/require/use statements → cross-reference with declared deps → flag unused.
Check for multiple versions of same package in lockfile (duplicates).
── Phase 2: Eliminate ──
Remove unused deps (not imported anywhere, not in build config, not a peer dep requirement).
Replace heavy deps with builtins or lighter alternatives:
  JS/TS: lodash → native, moment/dayjs → Temporal API, axios → fetch, uuid → crypto.randomUUID()
  Python: requests → httpx, json → orjson, os.path → pathlib, pyyaml → tomllib (for TOML)
  Shell: jq for JSON, no python/node for simple text processing
Deduplicate: resolve multiple versions to single compatible version where possible.
Flag transitive bloat: deps that pull >50 transitive deps, suggest alternatives.
── Phase 3: Update ──
Apply all patch+minor updates automatically. For major updates:
  List breaking changes from changelog/release notes. Provide migration code for each.
  Test build+lint after each major bump individually. Roll back if broken.
Pin versions in lockfile but use semver ranges in manifests (^/~).
Regenerate lockfiles: bun install, uv lock, cargo update.
── Phase 4: Harden ──
Run vulnerability scan: bun audit / uv pip audit / cargo audit.
Flag CVEs with severity. Auto-fix where patch version resolves it.
Check license compatibility (flag GPL in MIT projects, AGPL in proprietary).
Verify no deprecated packages (check npm deprecation notices, PyPI classifiers).
── Phase 5: Optimize size ──
Measure: node_modules size, .venv size, target/ size before and after.
For JS/TS: check bundle impact with bundlephobia data. Flag deps >100KB gzipped.
For Python: prefer pure-python over C-extension deps when perf difference is negligible.
Suggest devDependencies promotion for build-only tools (linters, formatters, test frameworks).
── Output ──
Report table (dep|current|latest|size|status|action), removal diffs, migration code for breaking changes,
before/after metrics (dep count, lockfile size, install size), vulnerability summary, license report.
```
</details>
<details><summary><b>🧹 Maintenance</b> — Repo-wide janitorial cleanup and hygiene</summary>

```text
Full repo maintenance pass: clean, normalize, verify, fix rot. Use `rg`/`fd`. Use ultrathink.
Run periodically. Safe and non-breaking — no logic changes, no API changes.
Exclude: .git/, node_modules/, vendor/, dist/, .venv/, generated/, *.min.*
── Phase 1: Dead file removal ──
fd -tf -e log -e bak -e tmp -e swp -e orig -e rej -e pyc -x rm -f
Remove: .DS_Store, Thumbs.db, desktop.ini, __MACOSX/, *.retry, *~, \#*\#
Remove: zero-byte files (except __init__.py, .gitkeep, .keep). Empty directories.
Remove: orphaned source files (zero importers/references confirmed by rg). Build artifacts not in .gitignore.
Remove: dead configs (eslintrc if using biome, prettier if using biome, setup.cfg if pyproject.toml exists).
── Phase 2: Text normalization ──
LF line endings everywhere (no CRLF). Exactly 1 trailing newline per file.
Strip all trailing whitespace. Collapse 3+ consecutive blank lines to max 2.
Remove BOM from UTF-8 files. Fix file permissions: 644 for files, 755 for scripts, no 777.
Ensure shebang on all executable scripts. Ensure .gitattributes handles line endings.
── Phase 3: Config hygiene ──
Sync .gitignore with actual artifacts (add missing, remove stale entries).
Validate all JSON (jq -e .), YAML (yamllint), TOML (taplo lint) configs parse cleanly.
Remove duplicate/conflicting config files (e.g., both .eslintrc and biome.json for same rules).
Ensure .editorconfig exists and matches project conventions.
Update license year if stale. Verify README badges/links aren't broken (check URLs).
── Phase 4: Spelling and comments ──
codespell --write-changes (skip vendored/generated/lockfiles).
Remove comments that restate the code ("increment i by 1"). Remove TODO/FIXME with no context.
Remove commented-out code blocks (>3 lines of commented code = dead code, delete it).
Fix obvious typos in user-facing strings, variable names, and doc comments.
── Phase 5: Format everything ──
YAML: yamlfmt → yamllint | JSON: jq -S or biome format | JS/TS: biome format → biome check
Shell: shfmt -i 2 -bn -ci -ln bash → shellcheck → shellharden | Python: ruff format → ruff check --fix
Markdown: markdownlint --fix or mdformat | TOML: taplo fmt
Run formatters for detected languages only. Re-lint after format to verify.
── Phase 6: Verify nothing broke ──
git diff --stat for summary. Ensure build passes. Ensure tests pass. Ensure lint is clean.
No behavior changes — if any diff touches logic, revert that hunk and flag for manual review.
── Output ──
Deleted files list, normalization diffs, codespell corrections, format diffs, before/after metrics
(file count, total bytes, line count), verification results (build/test/lint status).
```
</details>

---
<details><summary><b>📐 Flow-Style Compaction</b> — Compact structured data files</summary>
  
```text
Compact structured data files for density without losing readability.
Use `rg`/`fd` to find JSON/YAML/TOML files. Use ultrathink.
Exclude: lockfiles (package-lock.json, yarn.lock, bun.lockb), node_modules/, .git/
Rules:
- Arrays/objects with total serialized length ≤140 chars → inline/flow-style on one line
- Arrays/objects >140 chars → block/expanded style with proper indentation
- Collapse 3+ consecutive blank lines to max 1
- Delete HTML/XML comments in non-HTML files. Preserve YAML comments.
- Sort object/mapping keys alphabetically (unless order is semantically meaningful, e.g., "name" before "version" in package.json)
- JSON: normalize with jq -S or biome format. Remove trailing commas (invalid JSON).
- YAML: prefer flow for short sequences: tags: [ci, build, test] not multi-line
- TOML: inline tables for ≤3 key-value pairs
Validation: parse output to verify no data loss (diff key counts, value equality check).
Output: unified diffs, space savings (bytes before/after, line count before/after), validation confirmation.
```
</details>
<details><summary><b>📖 AGENTS.md Generator</b> — AI-assisted development docs</summary>

```text
Generate AGENTS.md via deep repo analysis (use `rg` + `fd`). Infer only from evidence. Use ultrathink.
ANALYZE:
1. Languages → rank file extensions.
2. Frameworks → search imports/requires.
3. Build system → detect package/lock/build files.
4. CI/CD → inspect .github/workflows or equivalents.
5. Conventions → infer naming, structure, errors, tests.
6. Tooling → detect formatter, linter, type system, test runner.
7. Entry points → main app, CLI, routes, exports.
OUTPUT:
1) AGENTS.md with sections:
- Project (desc, languages, frameworks, architecture)
- Structure (@annotated key dirs)
- Dev workflow (exact discovered commands)
- Conventions
- Key dependencies (purpose only)
- Common tasks (feature, bug, test, deps)
- CI/CD (PR, merge, deploy flow)
- Tool preferences
2) Symlinks:
   ln -sf AGENTS.md CLAUDE.md
   ln -sf AGENTS.md GEMINI.md
3) .github/copilot-instructions.md
   (dev commands + conventions subset, similar to AGENTS.md)
4) Summary of detected patterns.
No guesses. No analysis logs. Output final artifacts only.
```
</details>
<details><summary><b>📊 Benchmark</b> — Performance profiling and comparison</summary>

```text
Profile and benchmark code for performance regressions and optimization opportunities. Use ultrathink.
── Discovery ──
Identify hot paths: entry points, request handlers, data processing pipelines, loops with I/O.
Use `rg` to find: sleep, setTimeout, fetch, query, loop, for, while, map, filter, reduce in critical paths.
── Profiling ──
Shell: time, strace -c, perf stat (if available). Measure: wall time, syscalls, memory.
Python: cProfile + snakeviz, memory_profiler, py-spy for production. timeit for micro-benchmarks.
JS/TS: console.time/timeEnd, Clinic.js, 0x for flame graphs. Benchmark.js for micro-benchmarks.
Rust: criterion for micro, flamegraph for profiling. #[bench] in nightly.
Go: go test -bench -benchmem, pprof for CPU/memory profiles.
── Methodology ──
Warm-up runs (discard first 3). Minimum 10 iterations. Report: mean, median, p99, stddev.
Compare before/after with statistical significance. Control for: CPU throttling, GC pauses, background load.
── Output ──
Benchmark script (executable), results table (function|before|after|delta%), flame graph commands, optimization recommendations with expected impact.
```
</details>
<details><summary><b>📝 Changelog Generator</b> — Generate release notes from git history</summary>

```text
Generate structured changelog from git history. Use ultrathink.
── Discovery ──
Parse commits since last tag: git log $(git describe --tags --abbrev=0 HEAD~1 2>/dev/null || echo "")..HEAD --oneline
Detect conventional commits: feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert
── Categorization ──
🚀 Features: feat commits → user-facing description (strip technical jargon)
🐛 Bug Fixes: fix commits → describe what was broken and what's fixed
⚡ Performance: perf commits → include before/after metrics if available
🔒 Security: security-related fixes → CVE references if applicable
💥 Breaking Changes: commits with BREAKING CHANGE footer or ! after type
📦 Dependencies: dependency updates grouped by ecosystem
🔧 Internal: refactor/chore/ci/build → summarize, don't enumerate
── Output ──
Markdown changelog following Keep a Changelog format. Group by category. Include: PR/commit links, contributor attribution, migration notes for breaking changes. Both verbose (for CHANGELOG.md) and concise (for GitHub release) versions.
```
</details>

---
## Copilot / Jules Tasks
<details><summary><b>Expand task list</b></summary>

```text
Find duplicate logic across files — rg for repeated patterns >10 lines, propose shared abstractions
```
```text
Analyze repo structure, test coverage gaps, and dependency health. Generate 3 high-impact feature/improvement ideas with: problem statement, proposed solution, affected files, estimated LOC, risk level.
```
```text
Cluster related functions by responsibility using import/call graph analysis. Suggest module refactoring with: current→proposed file mapping, migration steps, import update commands.
```
```text
Identify CPU-bound sequential code. Refactor for parallel processing using language-native concurrency (asyncio/TaskGroup, Promise.all, rayon, goroutines). Benchmark before/after.
```
```text
Audit all linter/formatter configs. Upgrade to latest versions. Auto-fix breaking config schema changes. Verify lint passes after upgrade.
```
```text
Set up Renovate with: automerge for patch/minor, grouped updates by ecosystem, schedule (weekdays only), PR limits, custom rules for known-breaking packages. Include renovate.json and workflow.
```
```text
Convert CLI tool into GitHub App: webhook receiver, event handlers for PR/push/issue events, installation auth flow, Dockerfile, deploy workflow.
```
```text
Build web scraper with: rate limiting (token bucket), exponential backoff retries (max 3), structured error handling, proxy rotation support, robots.txt compliance, output as JSON/CSV.
```
```text
Find untested public functions/methods via coverage report. Generate pytest/vitest test files with: happy path, edge cases (empty/null/boundary), error paths. Target 80%+ coverage.
```
```text
Set up pre-commit hooks: format (biome/ruff/shfmt) → lint (oxlint/ruff/shellcheck) → type-check (tsc --noEmit/mypy) → codespell. Include .pre-commit-config.yaml and setup instructions.
```
```text
Create CI/CD workflows: lint+format check, test matrix (OS × runtime version), build, deploy preview on PR, deploy prod on merge. Include: caching, concurrency groups, path filters, artifact upload.
```
```text
Identify functions >50 lines or >5 parameters. Decompose into focused <30-line functions using: extract method, introduce parameter object, replace conditional with polymorphism. Preserve public API.
```
```text
Generate comprehensive test suite for existing codebase. Analyze code paths with rg, identify untested branches. Create: unit tests (isolated, mocked deps), integration tests (real deps, DB), edge cases (empty, null, overflow, unicode). Target 90%+ branch coverage.
```
```text
Analyze and optimize bundle size. Identify: large imports (lodash, moment), unused exports, duplicate polyfills, unminified assets. Apply: tree-shaking, dynamic imports, compression analysis. Report: before/after sizes per chunk.
```
```text
Migrate codebase between frameworks/runtimes. Map: API equivalents, config changes, dependency replacements, breaking patterns. Generate: migration script, compatibility shims, rollback plan. Verify: tests pass after migration.
```
</details>
