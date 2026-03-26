---
description: Diff-aware code review of staged/committed changes against dotfiles standards.
agent: reviewer
---

Review the following diff against this repository's standards.

Current diff:
!`git diff HEAD --stat && echo "---" && git diff HEAD 2>&1 | head -200`

Staged changes (if any):
!`git diff --staged 2>&1 | head -200`

Review criteria (in priority order):

1. **Shell safety** — Every `.sh` file must have `set -euo pipefail`. Variables must be quoted `"${var}"`. No `eval`, no backtick substitution, no `ls` parsing. Use `[[ ]]` not `[ ]`.

2. **Protected files** — Flag any change to: `etc/pacman.conf`, `Home/.config/zsh/.zshrc`, `Home/.gitconfig`, `etc/sysctl.d/`, `etc/paru.conf`, `etc/makepkg.conf`, `etc/sudoers`, `etc/ssh/sshd_config`. These require explicit user approval.

3. **Secrets** — Flag any hardcoded API keys, tokens, passwords, or private key material.

4. **YADM path convention** — User configs must be under `Home/` (maps to `~/`). System configs must be under `etc/` (maps to `/`). Never mix them.

5. **Commit message format** — Must follow `<type>(scope): description` with types: fix|feat|refactor|perf|docs|chore|style.

6. **Scope creep** — Flag changes that touch files unrelated to the stated task.

For each violation, output:
- File:line
- Rule violated
- Suggested fix (one-liner where possible)

If no violations: output "LGTM" and a one-sentence summary of what changed.
