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
- [Searchxng](https://searx.dresden.network/) &nbsp;[Instances](https://searx.space)
- [Brave search](https://search.brave.com)
</details>

## **Quick prompts**
<details>
<summary><b>Lint/Format</b></summary>

```markdown
Objective: Exhaustive lint+format per .editorconfig. Enforce 2-space indent. Zero remaining errors. Fail CI on non-zero.
Discovery: fd -tf -u -E .git -E node_modules -e <exts>
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
Objective: fix one small TODO, remove obvious dupes, and apply targeted perf improvements. Minimal, behavior-preserving edits. Output: patch + tests, or issue if non-trivial.
Scope: trivial TODOs only; multi-module/design → issue. Detect langs per file; prefer AST tools. No public API changes without tests.
Discovery:
- TODOs: rg -H -I -nS '\bTODO\b'
- Dupes: jscpd --min-tokens 50 + ast-grep
- Perf smells: heuristics + rg (nested loops, O(n²) regex/concat, sync I/O)
Pipeline:
1. classify TODO: trivial / risky / external
2. trivial → implement inline; extract helper if needed
3. dupes → extract common fn/module; minimal diff
4. perf → microbench; if >5% win, apply (algo/batching/caching)
5. add/extend tests; run suite
6. lint/format; commit on branch todo/<short>
Safety:
- preserve API/behavior; add tests for changes
- small single-file patches only; big → issue
- no tests → add regression test then fix
Tools: rg→grep; fd→find; jscpd; ast-grep; semgrep; hyperfine/time/perf; cProfile/node --prof/go bench; git.
Output:
- git diff patch; 1-line changelog
- tests added/updated, benchmarks before/after
- short rationale + risk
- non-trivial → issue w/ reproduction + plan
Repro:
- rg -H -I -nS '\bTODO\b'
- jscpd --min-tokens 50
- hyperfine 'cargo run --release --example foo'
- git checkout -b todo/short && git add -A && git commit -m 'fix: TODO' && git push
Exit:
- trivial fixed + tests + lint clean → patch
- else → issue w/ pointers + benchmark notes

```
</details>
<details>
<summary><b>LLM files</b></summary>
  
```markdown
Goal: ensure CLAUDE.MD, GEMINI.MD, copilot-instructions.md exist, stay minimal/consistent, pass lint; fail CI on missing/invalid.
Discovery: fd -H -I -E .git -e md || find . -name '*.md'; rg -nS 'CLAUDE|GEMINI|copilot' || :
Strategy: read→create-if-missing→merge sections→prune dupes→normalize (2-space, no invisibles, <=80 cols)→markdownlint→commit docs/{claude|gemini|copilot}/<short>.
Tools: fd→find; rg→grep; sd→sed; shfmt (code blocks); markdownlint.
Templates:
---
# CLAUDE.MD
Purpose: concise patterns & constraints.
- model: claude-*
- tone: blunt/precise
- safety: no hallucinations; cite claims
Prompts: system+task/constraints/output
Rules: short answers; best-effort on ambiguity; runnable code w/ quoted vars
---
# GEMINI.MD
Purpose: patterns for Gemini.
- model: gemini-*
- tone: same as Claude
- vision: yes/no
Prompts: system+json/human examples
Rules: web.run only for freshness; note model quirks
---
# copilot-instructions.md
Purpose: dev guardrails.
- bash-native; arrays; shfmt/shellcheck clean
- 2-space; short args; no eval/backticks
- tools: fd→rg→sd→sed→awk→xargs
- perf: low forks; batch IO
Prompts: compact/optimal/secure code; prefer builtins
CI: markdownlint; shellcheck; shfmt; ensure CLAUDE.MD+GEMINI.MD exist
---
Validation: find required files; markdownlint; rg for invisibles; sd to strip.  
Merge: small→direct PR; big→issue.  
Output: patched files + diff + changelog; else ISSUE.md.  
Exit: all files + lint pass → ok; else fail.  
Risk: no behavioral prompt changes without approval; templates stay minimal.
```
</details>
