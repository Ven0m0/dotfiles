---
description: Sync dotfiles between repo and home directory using yadm-sync. Show diff before applying.
agent: build
subtask: true
---

Dotfile sync operation: $ARGUMENTS

Valid operations: `pull` (repo→home), `push` (home→repo), `status` (diff only)

```bash
# Show current state first
yadm-sync status 2>&1 | head -40
```

If operation is `pull`:
```bash
yadm-sync pull 2>&1
```

If operation is `push`:
```bash
# Preview first
yadm-sync push --dry-run 2>&1 | head -40
```
Then ask for confirmation before applying the actual push.

If operation is `status` or not specified:
Just show the diff and stop — do not apply any changes.

After pull/push, list files that changed:
```bash
git status --short 2>&1
```

Do NOT auto-commit after a sync. Stage and commit manually with `/commit`.
