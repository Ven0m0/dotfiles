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

- [Libredirect](https://libredirect.github.io)
- [alternative-front-ends](https://github.com/mendel5/alternative-front-ends)
- [Privacy-tools](https://www.privacytools.io)
- [Redlib instance list](https://github.com/redlib-org/redlib-instances/blob/main/instances.md)
- [Redlib reddit](https://lr.ptr.moe)
- [Imgur](https://rimgo.lunar.icu)

## `Search engines`
- [DuckduckGo](https://duckduckgo.com)
- [Searchxng](https://searx.dresden.network/) &nbsp;[Instances](https://searx.space)
- [Brave search](https://search.brave.com)

## **Quick prompts**
<details>
<summary><b>Lint/Format</b></summary>
  
```markdown
Objective: Exhaustive lint+format per .editorconfig. Enforce 2-space indent. Zero remaining errors. Fail CI on non-zero.
Discovery: fd --type f --hidden --no-ignore --exclude .git --exclude node_modules --extension <exts>
Fallbacks: fd→find; rg→grep; sd→sed; zstd→gzip→xz.
Policy:
  - Run formatters before linters.
  - Apply only when tool supports safe write flag (--write/--apply/--fix).
  - Show diff summary + list of CLI commands to reproduce.
  - Exit non-zero if any unresolved errors.
Filegroups & pipeline (format → lint/fix → report):
  - yaml: yamlfmt --apply; yamllint -f parsable.
  - json/css/js/html: biome format --apply || prettier --write; eslint --fix; minify for final output.
  - xml: minify (format-only).
  - sh/zsh: shfmt -w -i 2; shellcheck --format=gcc || :; shellharden (audit).
  - fish: fish_indent (write).
  - toml: taplo format; tombi lint.
  - markdown: mdformat; markdownlint --fix.
  - actions: yamlfmt --apply; yamllint; actionlint.
  - python: ruff --fix; black --fast.
  - lua: stylua; selene lint.
  - global: ast-grep run rules; rg to enumerate; run batched in parallel (xargs -P).
Output (structured):
  - table: {file, group, modified, errors}
  - commands: exact CLI to reproduce fixes
  - summary: totals + exit code
Constraints:
  - Prefer tools in PATH; detect & report missing tools.
  - Minimize forks; batch file lists; safe parallelism.
  - Respect project config files (.editorconfig, .prettierrc, pyproject.toml).
```
</details>
<details>
<summary><b>TODO</b></summary>
  
```markdown
Objective: locate + fix a small TODO (code comment or TODO-file), remove obvious duplicated code, and suggest/implement targeted improvements for hotspots. Minimal, behavior-preserving edits. Produce reproducible patch + tests or an issue when fix is non-trivial.
Scope:
  - Small TODOs only (one-liner / single-responsibility). If TODO affects multiple modules or requires design changes, file an issue and link.
  - Languages: detect per-file; prefer AST-aware tools when available.
  - Do not change public behavior/ABI without explicit note and tests.
Discovery (fast, precise):
  - TODOs: `rg --hidden --no-ignore -nS '\bTODO\b'` (or `fd -0 . -e <ext> | xargs -0 rg ...`).
  - Duplicate code: `jscpd --min-tokens 50` + `ast-grep` rules.
  - Slow/inefficient patterns: language heuristics + `rg` for known anti-patterns (e.g. nested loops, O(n²) regex/concat, sync I/O in hot paths).
Pipeline (detect → classify → fix → verify):
  1. Find TODOs; classify: trivial (implementable), risky (needs design), external (deps/docs).
  2. For trivial: implement inline, prefer small helper extraction, use existing utils.
  3. For duplicates: extract common function/module; replace occurrences with call; keep diff minimal.
  4. For perf: micro-benchmark candidate area (hyperfine or builtin profiler). If measurable (>5% improvement), apply targeted optimization (algorithmic change, batching, caching). Avoid micro-optimizations unless measurable.
  5. Add/extend unit test(s) covering the change; run test suite.
  6. Run linter/format pipeline; `git add -p` commit on a short branch `todo/<short>`
Constraints / Safety:
  - Preserve API/behavior; add tests for any behavior change.
  - Prefer single-file small patches; refuse large refactors — create issue instead.
  - Fail-fast on missing tests; if test coverage absent, add regression test demonstrating original bug then fix.
Tools (prefer → fallback): `rg` → `grep`; `fd` → `find`; `jscpd`; `ast-grep`; `semgrep`; `hyperfine`/`time`/`perf`; `python -m cProfile` / `node --prof` / `go test -bench`; `git`.
Output (structured):
  - Patch (git diff/PR) with branch.
  - One-line changelog entry.
  - Tests added/modified.
  - Benchmark before/after (numbers).
  - Short rationale (2–4 lines) and risk level.
  - If not fixed: created issue with reproduction + suggested plan.
Repro commands (example):
  - `rg --hidden --no-ignore -nS '\bTODO\b'`
  - `jscpd --reporters console --min-tokens 50`
  - `hyperfine 'cargo run --release --example foo'`
  - `git checkout -b todo/short && git add -A && git commit -m 'fix: TODO — short' && git push`
Exit criteria:
  - Trivial TODO implemented + tests pass + CI local lint clean → return patch.
  - Non-trivial → open issue with code pointers, suggested patch sketch, & benchmarks.
```
</details>
<details>
<summary><b>LLM files</b></summary>
  
```markdown
Goal
- Create or update CLAUDE.MD, GEMINI.MD, copilot-instructions.md — clear, minimal, machine- and human-readable; keep content consistent across files; fail CI on missing or invalid file.
Discovery
- locate: fd --hidden --no-ignore -E .git -e md || find . -type f -name '*.md' -print
- search: rg --no-ignore -nS 'CLAUDE|GEMINI|copilot' || :
Strategy
1. read existing files; if missing -> create from template.
2. merge: prefer explicit sections, preserve user custom lines, prune duplicates.
3. normalize: 2-space indent; remove invisible/unicode; line-length 80.
4. validate: markdownlint, rg for banned patterns.
5. commit: branch claude|gemini|copilot/{short} -> git commit -m "chore(docs): update <file>"
Tools (prefer → fallback)
- fd → find ; rg → grep ; sd → sed ; shfmt for code blocks; markdownlint
Templates (minimal; fill placeholders)
CLAUDE.MD
---
# Claude — Usage & Instructions
Purpose: concise prompt patterns & safety constraints for Claude-style assistants.
Format:
- Model: claude-*(version)
- Tone: blunt, factual, precise.
- Max tokens / context: <n>
- Safety: do not produce hallucinated facts; cite sources when claimed.
Prompts:
- System: "You are a concise Claude-style assistant. Follow user's tone preferences (blunt, factual)."
- Examples: | 
  - "Task: <one-line objective>"
  - "Constraints: <list>"
  - "Output: <format>"
Rules:
- prefer short answers; if ambiguous, implement best-effort and note uncertainty.
- when code: provide runnable snippets, shell-first, quote vars.
---
GEMINI.MD
---
# Gemini — Usage & Instructions
Purpose: prompt patterns & capabilities for Gemini-style assistants.
Format:
- Model: gemini-*(version)
- Tone & style: same as CLAUDE.MD (explicit).
- Images/vision: allowed? yes/no (specify).
Prompts:
- System: "You are a Gemini-style assistant. Concise, precise, forward-looking."
- Example tasks & expected response format (json + human summary).
Rules:
- Use web.run only when freshness needed (document when used).
- For persona/model differences: note special tokens or behavior.
---
copilot-instructions.md
---
# Copilot — Dev Instructions
Purpose: configure Copilot suggestions & guardrails for code completion.
Defaults:
- Shell: bash-native; prefer arrays for flags; shfmt & shellcheck clean.
- Style: 2-space indent; short args; avoid eval/backticks; quote vars.
- Tools ordering: fd → rg → sd → sed → awk → xargs.
- Perf: minimize forks; batch IO; early returns.
Prompts:
- System: "Provide compact, optimal, secure code. Prefer POSIX-bash. Minimize external forks; prefer builtin ops."
- Examples: one-liners, small refactors, tests, benchmark hints.
CI checks:
- markdownlint, shellcheck, shfmt -w, golangci-lint (if relevant).
- Validate presence of CLAUDE.MD & GEMINI.MD.
Commit/branch
- branch: docs/{claude|gemini|copilot}/<short>
- commit: chore(docs): update <file> —short
- push & open PR.
Validation commands
- find . -type f -name 'CLAUDE.MD' -o -name 'GEMINI.MD' -o -name 'copilot-instructions.md'
- markdownlint **/*.md || :
- rg --hidden --no-ignore -nS '\p{Cf}' && sd $'\u200B' '' -r . || :
Merge policy
- small changes: direct PR -> squash.
- conflicting or large edits: open issue + propose delta patch.
- always include TL;DR one-line summary at top of file for quick scan.
Output (on run)
- patched file(s), git diff, short changelog (1 line per file), validation report.
- if unable to auto-fix: create ISSUE.md with diagnostics + suggested patch.
Example run (repro)
- fd -e md . || find . -name '*.md'
- for f in CLAUDE.MD GEMINI.MD copilot-instructions.md; do [[ -f $f ]] || printf '%s\n' "creating $f"; done
- markdownlint **/*.md || :
- git checkout -b docs/update-guides && git add -A && git commit -m "chore(docs): sync assistant guides" && git push --set-upstream origin HEAD
Exit criteria
- All three files present + lint pass → success (print diff & changelog).
- Partial → create ISSUE.md and exit non-zero.
Risk notes
- Do not change behavioral/operational prompts without explicit user signoff.
- Keep templates minimal; prefer examples over long prose.
```
</details>
