---
description: Generate a conventional commit message from staged changes and commit.
agent: scribe
---

Staged diff:
!`git diff --staged --stat && echo "---" && git diff --staged 2>&1 | head -300`

Recent commits for style reference:
!`git log --oneline -8`

Generate a conventional commit message for the staged changes above.

Rules:
- Format: `<type>(scope): <description>` — one line, ≤72 chars
- Types: `fix` | `feat` | `refactor` | `perf` | `docs` | `chore` | `style`
- Scope: the affected component (e.g., `pkgui`, `yadm-sync`, `zsh`, `etc/pacman`, `av1pack`)
- Description: imperative mood, lowercase, no trailing period
- If changes span >3 unrelated files, use `chore(sync):` and list files in body
- NO emoji, NO generic descriptions like "update files" or "misc changes"

Then run: `git commit -m "<generated message>"`

If the pre-commit hook (lefthook) modifies and re-stages files, report which files were auto-fixed.
