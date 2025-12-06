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
Also clean them up and enhance/improve the configs and delete duplicate, redundant or deprecated files. 
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
<details>
<summary><b>Format and refactor</b></summary>

```markdown
# Codebase Optimization & Hygiene Architect
**Role:** Execute a strict code quality pipeline: Format » Lint » Inline » Refactor.
**Targets:** Bash (Priority), Python, Web/Config.
**Constraint:** All Bash scripts must be standalone (statically linked/no external sourcing).
## 1. Standards & Tooling
**Policy:** Use native/fastest tools. Fallback: `fd`→`find`; `rg`→`grep`.
- **Bash**: `shfmt -i 2 -bn -ci -s`, `shellcheck` (0 errors), `shellharden --replace`.
- **Python**: `ruff --fix`, `black`.
- **Config**: `biome`, `yamlfmt`, `taplo`.
## 2. Style & Formatting
- **Structure**: Enforce 2-space indent. Max 1 consecutive empty newline.
- **Bash Style**:
  - Use `(){` for function declarations.
  - Inline short actions using `;` where readable.
  - Minimize vertical whitespace.
- **Idioms**: Use compact wrapper functions to reduce verbosity.
  - *Example*: `die(){ printf '%b[ERROR]%b %s\n' '\e[1;31m' '\e[0m' "$*" >&2; exit "${2:-1}"; }`
## 3. Execution Pipeline
### Phase A: Static Compliance
1. **Format**: Run formatters. Apply safe fixes (`--write/--fix`) blindly.
2. **Lint**: Enforce zero errors. Apply `set -euo pipefail`.
3. **Inline**: Recursively read `source` files and inject content into the parent script to ensure valid standalone execution.
### Phase B: Refactor & Optimize
1. **Deduplicate**: Identify logic repeated >50 tokens; extract to atomic functions.
2. **Performance**:
   - Replace slow loops/subshells with Bash built-ins (arrays, mapfile, parameter expansion).
   - Detect and fix O(n²) operations or synchronous I/O blocks.
3. **Cleanup**: Remove unused variables and dead code.
## 4. Deliverables
- **Code**: Refactored, standalone, single-file scripts.
- **Report**: Diff summary + Performance metrics (e.g., "Loop opt: -200ms").
```
</details>
<details>
<summary><b>Bash short</b></summary>
  
```markdown
Identify and suggest improvements to slow or inefficient code and find and refactor duplicated code. Ensure that they are linted and formatted with shellcheck and shellharden. Avoid libraries and reimplement any libraries back into the scripts that source them. Each script needs to work on its own statically. Make use of small wrapper functions like this for example: `die(){ printf '%b[ERROR]%b %s\n' '\e[1;31m' '\e[0m' "$*" >&2; exit "${2:-1}"; }` to save space for repetetive code. Enforce 2-space indent and use `;` to inline some short actions if it is reasonable and readable. Always use `(){` for functions  and ensure that there are no consecutive empty newlines, the max is 1. Keep whitespace and newlines reasonably minimal.
```
</details>
