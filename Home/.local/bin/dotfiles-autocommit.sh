#!/usr/bin/env bash
# dotfiles-autocommit.sh — sync $HOME → repo, commit, and push
# Called by systemd units for periodic, pre-shutdown, and post-boot snapshots.
# shellcheck enable=all shell=bash
set -euo pipefail
export LC_ALL=C
IFS=$'\n\t'

LABEL="${1:-auto-commit}"
SYNC_SCRIPT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/yadm-sync.sh"

log()  { logger -t dotfiles-autocommit "$*"; printf '[dotfiles-autocommit] %s\n' "$*"; }
warn() { logger -t dotfiles-autocommit "WARN: $*"; printf '[dotfiles-autocommit] WARN: %s\n' "$*" >&2; }

# ── 1. Locate repo ────────────────────────────────────────────────────────────
get_repo_dir() {
  # Try yadm first
  if command -v yadm &>/dev/null && yadm rev-parse --show-toplevel &>/dev/null 2>&1; then
    yadm rev-parse --show-toplevel
    return
  fi
  # Fall back: this script lives in <repo>/Home/.local/bin after deployment.
  # Walk up from its deploy location (e.g., ~/.local/bin) and check parent trees
  if command -v git &>/dev/null; then
    local script_dir candidate d
    script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    for candidate in "$script_dir" "$script_dir/.." "$script_dir/../.." "$script_dir/../../.."; do
      if d="$(git -C "$candidate" rev-parse --show-toplevel 2>/dev/null)"; then
        if [[ -n $d && -d $d/Home ]]; then
          printf '%s\n' "$d"
          return
        fi
      fi
    done
  fi
  printf '%s\n' ""
}

REPO_DIR="$(get_repo_dir)"
if [[ -z $REPO_DIR || ! -d $REPO_DIR/Home ]]; then
  warn "Cannot determine repo dir; aborting."
  exit 1
fi

# ── 2. Reverse-sync live $HOME → Home/ ───────────────────────────────────────
if [[ -x $SYNC_SCRIPT ]]; then
  log "Syncing \$HOME → $REPO_DIR/Home/ ..."
  "$SYNC_SCRIPT" push 2>&1 | logger -t dotfiles-autocommit || \
    warn "yadm-sync push had errors (non-fatal)"
else
  warn "yadm-sync.sh not found at $SYNC_SCRIPT; skipping rsync step."
fi

# ── 3. Stage and commit ───────────────────────────────────────────────────────
cd "$REPO_DIR" || exit 1
git add -u

if git diff --cached --quiet; then
  log "No changes to commit ($LABEL)."
  exit 0
fi

TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
HOST="$(hostname -s 2>/dev/null || printf 'unknown')"
git commit -m "[${LABEL}] ${HOST} ${TIMESTAMP}"
log "Committed: [${LABEL}] ${HOST} ${TIMESTAMP}"

# ── 4. Push (best-effort; never blocks caller) ────────────────────────────────
if git remote get-url origin &>/dev/null; then
  if timeout 30 git push --quiet 2>&1 | logger -t dotfiles-autocommit; then
    log "Pushed to remote."
  else
    warn "Push failed or timed out — will retry next run (offline?)."
  fi
else
  warn "No git remote configured; skipping push."
fi
