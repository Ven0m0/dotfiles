---
applyTo: "**/*.{sh,bash,zsh},PKGBUILD"
description: "Compressed standards for Bash scripts."
---

# Bash Standards

Role: Bash Refactor Agent — full-repo shell codemod, fixer, and optimizer. Goal:

- Scan all bash/sh files using rg/ripgrep and apply a compact, safe codemod: normalize syntax, fix redirects, inline
  trivial code, run linters/formatters, and emit standalone, deduped, fully optimized scripts. Scope (targets):
- All `*.sh`,`*.bash`,`*.zsh`, and rc-like shell files, including PKGBUILDS, makepkg.conf, excluding `.git`,
  `node_modules`, vendored/generated assets.
- Prefer bash; user wants bashisms.

Core rules:

- Formatting: `shfmt -i 2 -bn -ci -ln bash`; max 1 empty line, keep whitespace reasonably minimal
- Linters: `shellcheck --severity=error`; `shellharden --replace` when safe.
- Forbidden: `eval`, parsing `ls`, unquoted expansions, unnecessary subshells, runtime piping into shell.
- Standalone: Avoid sourcing files; dedupe repeated logic; keep guard comments.
- Inline case (`example) action1; action2 ;;`)
- Performance: Prefer bashism's and shell native methods, replace slow loops/subshells with bash builtins (arrays,
  mapfile, parameter expansion); limited `&` + `wait`.
- Use printf's date instead of date (`date(){ local x="${1:-%d/%m/%y-%R}"; printf "%($x)T\n" '-1'; }`).
- Use bash native methods instead of a useless cat (`fcat(){ printf '%s\n' "$(<${1})"; }`).
- Use read instead of sleep when safe (`sleepy(){ read -rt "${1:-1}" -- <> <(:) &>/dev/null || :; }`).
- Start every script like this:

```bash
#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
set -euo pipefail; shopt -s nullglob globstar
export LC_ALL=C; IFS=$'\n\t'
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
has(){ command -v -- "$1" &>/dev/null; }
```

Codemod transformations:

1. Header/style normalization
   - Convert `() {` → `(){` and enforce compact function form.
   - Remove space in redirects: `> /dev/null` → `>/dev/null`.
   - Collapse combined redirects: `>/dev/null 2>&1` and malformed `2&>1` → `&>/dev/null`.
   - Always prefer `[[ ... ]]` over `[ ... ]`.
   - Ensure explicit bash shebang on scripts containing bashisms.
2. Inlining
   - Inline small functions (≤6 non-empty lines, ≤2 call sites, no complex control flow).
   - Inline short adjacent commands using `;` if clarity preserved.
3. Safety guards
   - Skip heredocs and single-quoted blocks.
   - Skip ambiguous bracket conversions (arrays, arithmetic, regex-heavy lines).
   - Flag blocks >50 tokens or repeated >3 lines; extract into atomic functions.
   - Preserve behavior; smallest safe change wins.
4. Deduplication
   - On inlining or inlining sourced code, dedupe repeated blocks and emit a single canonical version.
5. Linters/fixes
   - Run `shellcheck`; auto-apply trivial fixes (quoting, redirs) when safe.
   - Run `shellharden`; accept safe output or revert unsafe changes.
   - Re-run linters; fail if remaining errors.
6. Deliverables from Claude Code
   - Short plan (3–6 bullets).
   - Unified diff.
   - Final standalone script(s).
   - One-line risk note.

Pipeline (per file):

- Token-aware read; apply ordered transforms → shfmt → shellcheck → shellharden → re-check.
- PR: Clean lint, atomic commits (fmt != logic), tests pass.
- Create branch `codemod/bash/<timestamp>`; atomic commits per file.
