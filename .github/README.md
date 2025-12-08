# `Dotfiles`

<details>
<summary><b>Features</b></summary>

- [Auto optimized media](.github/workflows/image-optimizer.yml)
- [Auto validated config files](.github/workflows/config-validate.yml)
- [Auto shell check](.github/workflows/shellcheck.yml)
- [Auto updated submodules](.github/workflows/update-git-submodules.yml)

</details>
<details>
<summary><b>Dotfile managers</b></summary>

- <https://github.com/Shemnei/punktf>
- <https://github.com/woterr/dotpush>
- <https://github.com/joel-porquet/dotlink>
- <https://github.com/dotphiles/dotsync>
- <https://github.com/ellipsis/ellipsis>
- <https://github.com/SuperCuber/dotter>
- <https://github.com/alichtman/shallow-backup>
- <https://github.com/rossmacarthur/sheldon>
- <https://github.com/bevry/dorothy>
- <https://github.com/yadm-dev/yadm>
- <https://codeberg.org/IamPyu/huismanager>

</details>
<details>
<summary><b>Arch scripts</b></summary>

```bash
curl -fsSL https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Updates.sh | bash
```

```bash
curl -fsSL https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Clean.sh | bash
```

```bash
curl -fsSL https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Rank.sh | bash
```

</details>
<details>
<summary><b>Useful Stuff</b></summary>

- <https://dotfiles.github.io/>
- <https://terminal.sexy/>
- <https://wiki.archlinux.org/title/Git>

</details>
<details>
<summary><b>Packages:</b></summary>

- [Arch PKG](https://archlinux.org/packages)

- [AUR PKG](https://aur.archlinux.org)

- [Crates.io](https://crates.io)

- [FlatHub](https://flathub.org)

- [Lure.sh](https://lure.sh)

- [Basher](https://www.basher.it/package)

- [bpkg](https://bpkg.sh)

- [x-cmd](https://www.x-cmd.com)

  <details>
  <summary><b>Install x-cmd</b></summary>

  bash:

  ```bash
  eval "$(curl -s https://get.x-cmd.com)"
  ```

  fish:

  ```sh
  curl -s https://get.x-cmd.com | sh; chmod +x $HOME/.x-cmd.root/bin/x-cmd && ./$HOME/.x-cmd.root/bin/x-cmd fish --setup
  ```

  </details>

</details>
<details>
<summary><b>Supported Linux Distributions</b></summary>

- [CachyOS](https://cachyos.org) specifically, but really any arch based distro is good
- [DietPi](https://dietpi.com)
- [Raspberry Pi OS](https://www.raspberrypi.com/software)

</details>
<details>
<summary><b>Alternative frontends</b></summary>

- [Libredirect](https://libredirect.github.io)
- [alternative-front-ends](https://github.com/mendel5/alternative-front-ends)
- [Privacy-tools](https://www.privacytools.io)
- [Redlib instance list](https://github.com/redlib-org/redlib-instances/blob/main/instances.md)
- [Redlib reddit](https://lr.ptr.moe)
- [Imgur](https://rimgo.lunar.icu)

**Search engines**

- [DuckduckGo](https://duckduckgo.com)
- [Searchxng](https://searx.dresden.network/)  [Instances](https://searx.space)
- [Brave search](https://search.brave.com)

</details>

## **Quick prompts**
<details>
<summary><b>Lint/Format</b></summary>

```markdown
Objective: full tree conformance to .editorconfig; 2-space indent; zero remaining errors; non-zero exit on unresolved issues.
Discovery: fd -tf -u -E .git -E node_modules -e <ext>; fallback: find.
Scan: rg for invalid chars/invisibles; sd to clean; compressors: zstd→gzip→xz.
Policy:
  - Format before lint.
  - Only use safe write modes (--write/--apply/--fix/-w).
  - Batch file lists; minimal forks; xargs -P for parallel.
  - Respect project configs (.editorconfig, prettierrc, pyproject.toml, etc.).
  - Detect missing tools; report & skip group.
Pipeline (group → format → lint/fix → report):
  - yaml: yamlfmt --apply; yamllint -f parsable.
  - json/css/js/html: biome fmt --apply || prettier --write; eslint --fix; minify final.
  - xml: minify only (no linter).
  - sh/zsh: shfmt -w -i 2; shellcheck --format=gcc || :; shellharden audit.
  - fish: fish_indent -w.
  - toml: taplo fmt; tombi lint.
  - markdown: mdformat; markdownlint --fix.
  - github actions: yamlfmt; yamllint; actionlint.
  - python: ruff --fix; black --fast.
  - lua: stylua; selene.
  - global: ast-grep rules; rg enumeration; run via xargs -P.
Output (structured):
  - table: {file, group, modified(yes/no), errors(count/list)}
  - commands: exact CLI for reproducing fixes
  - summary: totals + final exit
Cleanup:
  - Remove duplicate/obsolete/deprecated configs.
  - Normalize all config files; unify indentation, charset, EOL.
  - Ensure consistent toolchains (taplo/tombi, biome/prettier/eslint, mdformat/markdownlint).
```
</details>
<details>
<summary><b>LLM files</b></summary>

```markdown
Role: LLM MD File Optimizer — ensure CLAUDE.MD, GEMINI.MD, copilot-instructions.md exist, minimal, consistent, lint-clean, CI-fail on missing/invalid.
Discovery
- Find candidate files: `fd -H -I -E .git -e md || find . -name '*.md'`
- Locate targets: `rg -nS 'CLAUDE|GEMINI|copilot' || :`
Tools (preferred → fallback)
- fd → find; rg → grep; sd → sed; shfmt; markdownlint; shfmt (code blocks).
Preflight checks (must run)
1. Encoding/clean: `file -bi <file>` → UTF-8, strip BOM; `rg -nU '\p{Cc}' || :` → no control chars.
2. Invisibles: `rg -nU '\p{C}' || :` and `sd '  +$' ''` (strip trailing spaces).
3. Line width: wrap/soft-fail >80 cols; enforce ≤80 cols where reasonable.
4. Code blocks: run `shfmt -i 2 -w` for bash blocks; preserve fenced language tags.
Templates & canonical structure (per file)
- Location: `docs/{claude|gemini|copilot}/<short>.md` (create dir if missing).
- Required header (YAML or plain):
  - Title
  - Purpose (1 line)
  - Model pattern (e.g., `claude-*` / `gemini-*`)
  - Tone (blunt/precise)
  - Key rules (bulleted)
  - Minimal example: `system + task → expected short output`
- File must be minimal and focused; no long narrative.
Workflow (must follow)
1. Plan: output 3–6 bullet plan (files touched, small|big change, tests, rollback).
2. Read target files; if missing → create from template.
3. Merge/prune:
   - Merge sections when overlap; prune duplicates.
   - Dedupe text blocks >3 lines or >50 tokens (prefer canonical template).
4. Normalize:
   - 2-space indent; remove invisible chars; LF endings; ≤80 cols.
   - Run markdownlint: `markdownlint -c .markdownlint.json <files>`.
5. Validate:
   - Ensure presence of required sections and a minimal example per file.
   - Ensure code blocks formatted (shfmt for bash blocks).
6. Commit/PR:
   - Small change → branch `docs/<type>/<short>`; commit msg: `docs(<type>): <short> — add/fix <what>`.
   - Big/ambiguous → open ISSUE.md proposing changes and stop.
7. Deliverables:
   - Patched files (path list), unified diff, `CHANGES.md` entry, tests/smoke commands, `ISSUE.md` if non-auto.
   - One-line risk note per file changed.
CI rules (must cause fail)
- If any required file missing → exit non-zero.
- If `markdownlint` finds errors → fail.
- If invisibles/control chars present → fail.
- If example smoke test (run small parse or prompt check) fails → fail.
Output format (Markdown)
- Plan (3–6 bullets)
- Files created/updated (paths)
- Unified diff(s)
- Tests / run commands (1–3 commands)
- CHANGES.md entry content
- One-line rationale + risk per non-trivial change
Assumptions & limits
- Do not alter intent or semantics of existing prompts without explicit approval.
- Keep templates minimal; prefer small PRs. If ambiguous, create ISSUE.md and stop.
```
</details>
<details>
<summary><b>Bash short</b></summary>
  
```markdown
Role: Bash Refactor Agent — optimize, dedup, and produce standalone scripts.
Rules:
- Shebang/safety: use `#!/usr/bin/env bash`; `set -euo pipefail`; `shopt -s nullglob globstar`; `IFS=$'\n\t'`.
- Formatting: `shfmt -i 2 -bn -ci -ln bash`; 2-space indent; max 1 consecutive empty line.
- Linters: `shellcheck --severity=error` (fail on errors); `shellharden --replace` optional.
- Forbidden: `eval`, parsing `ls`, unquoted expansions, unnecessary subshells, runtime `curl | bash`.
- Portability: prefer POSIX-safe constructs where possible; verify on `bash` and a minimal shell (dash/busybox) when relevant.
- Standalone: inline all `source`/`.` files with guard comments; dedupe inlined code (include once).
- Performance rules: replace slow loops/subshells with bash builtins (arrays, `mapfile`, parameter expansion), use limited background jobs `&` + `wait`.
- Dup detection: flag repeated logic >50 tokens or identical blocks >3 lines; extract to atomic functions.
- Verbosity: use compact function form `name(){ ... }`; allow `;` to inline short readable actions sparingly.
- Error helper: keep provided `die()` or use portable fallback:
  `die(){ printf '%s\n' "ERROR: $*" >&2; exit "${2:-1}"; }`
- Deliverables: short plan (3–6 bullets), unified diff, final standalone script(s), tests/dry-runs (sample I/O), lint counts before/after, one-line risk note, `CHANGES.md` entry, atomic commit message template.
If ambiguous, make the smallest safe change preserving behavior and document assumptions.
```
</details>
<details>
<summary><b>AIO</b></summary>

```markdown
Role: Code Quality & Performance Architect — Linux/dotfiles/projects.
Goal: Produce portable, high-quality, self-contained scripts and repo hygiene. Priorities: correctness → portability → performance. Keep changes minimal, reversible, testable.
ENV & TOOLS (use if present; fallback to POSIX)
- Prefer native fast tools: fd→find, rg→grep, sd→sed, fzf optional.
- Concurrency: xargs -P "$(nproc)" / parallel; batch I/O, minimize forks.
- Lint/format: shfmt, shellcheck (--severity=style), ruff, biome, yamlfmt.
- Safety: run linters/tests before/after changes.
PRIMARY RULES
- Bash scripts must be single-file, statically linked/logically inlined (no runtime external deps). Preserve executable permissions.
- Strict shell style: `#!/usr/bin/env bash`; `set -euo pipefail`; `shopt -s nullglob globstar`; `IFS=$'\n\t'`.
- Prefer bash-native constructs: `[[ ]]`, `(( ))`, `printf`, parameter expansion `${var:-}`, `local -n` for indirection, `mapfile -t`, `while IFS= read -r`.
- No `eval`, no parsing `ls`, no unquoted vars, avoid unnecessary subshells.
- Short args, POSIX-safe helpers; lazy-load heavy logic inside functions.
- Use `&>/dev/null` for non-critical external calls; fail noisily for critical ones.
WORKFLOW (must follow)
1. Plan: produce 3–8 bullet plan (files touched, tests to add, risk, rollback).
2. Baseline: run linters/tests; record failures, slow tests, sizes.
3. Hygiene: shfmt → shellcheck auto-fixes (only safe rules) → biome/ruff.
4. Static-link step:
   - Trace `source`/`.` lines.
   - Resolve relative includes; inline file contents wrapped in guards.
   - Deduplicate functions/vars; add unique guard comments.
   - Produce final single-file script; provide provenance comments.
5. Refactor & optimize:
   - Replace nested O(n²) loops with associative lookups.
   - Replace external per-line `grep/sed` with parameter expansion or single pass `awk`/`rg` where justified.
   - Convert blocking IO to background jobs with `&` + `wait` when safe; limit concurrency.
   - Strip dead code, debug prints; keep minimal logging.
6. Tests & verification:
   - Add/modify unit/smoke tests or dry-run checks. Include sample input→expected output.
   - Confirm shellcheck=0 warnings, shfmt idempotent, ruff/biome clean.
   - Run simple portability checks (dash / bash / busybox where applicable).
7. Metrics & deliverables:
   - Provide Summary Table: `| File | Orig Size | Final Size | Errors Fixed | Opts Applied |`.
   - Provide unified diff(s) and final standalone script(s).
   - List tests added (paths) and test commands to reproduce.
   - Provide before/after metrics: lint counts, pytest/bench durations, simple microbench (hot function).
   - One-paragraph rationale for each non-trivial refactor; list assumptions & risks.
8. Commits & rollback:
   - Produce atomic commits with message template: `<area>: <what changed> — tests: +X/-Y`.
   - Create `CHANGES.md` entry summarizing changes and rollback steps.
FORBIDDEN (explicit)
- Do not add runtime external dependencies unless bundled/inlined.
- Do not change user-facing behavior without tests and explicit justification.
- Do not leave silent exceptions or suppressed errors.
OUTPUT FORMAT (Markdown, compact)
- Plan (bullets)
- Diff / final script(s) (unified diff + final file)
- Tests added (paths) + run commands
- Metrics: baseline vs new (linter counts, durations)
- Rationale (1 paragraph each), risks, remaining tech debt
If ambiguous, choose smallest safe change preserving current behavior and document the assumption.
```
</details>
<details>
<summary><b>Python</b></summary>
  
```markdown
Role: You are a Senior Python Architect.
Goal: refactor / clean up an existing Python project — maximize code quality, maintainability, strict typing, no duplicates, and preserve behavior.
Environment & tooling:
- Python 3.x, dependencies via `uv`.
- Use `ruff` for lint/format: `ruff check . && ruff format .`
- Use `biome` for repo lint (configs, docs).
- Tests under `pytest --durations=0`; optionally `mypy --strict` after types added.
Requirements:
- Strict static typing: annotate all functions, parameters, returns; avoid `Any` unless justified and marked TODO.
- PEP-style docstrings: summary + `Args:`/`Returns:`, without redundant type info.
- Line length ≤80 chars (wrap sensibly).
- Single-responsibility, small functions; descriptive snake_case names.
- No duplicate logic: extract helpers or classes; use DRY.
- Error handling: only catch specific exceptions; use `raise from`.
- Avoid global mutable state.
- Prefer data classes / typed structures over ad-hoc dicts/lists.
- For I/O-bound work, consider async; else synchronous. Lazy-import heavy modules.
- Prefer O(n) or better algorithms; use sets/dicts/generators for efficiency. Avoid nested loops when possible.
- Do incremental atomic commits: each change accompanied by updated or new tests — especially covering edge-cases (empty, invalid, boundary).
- Provide a short plan before coding: what will change, why, and how you verify it. After coding, run tests/linters and compare metrics (test durations, complexity counts, coverage).
When you respond, output:
- summary of planned changes,
- the diff / code changes,
- tests added or modified,
- before/after metrics if measured,
- one-paragraph rationale for non-trivial refactors,
- note any assumptions / risks, and remaining technical debt.
```
</details>
