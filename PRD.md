# PRD: Setup Script & Package List Sync

## Context

Merge improvements from `Ven0m0/Linux-OS/Cachyos/` into the local dotfiles repo. Local repo is source of truth (more secure, more packages). Remote provides new features and expanded AI tooling.

**Targets:** Arch Linux (CachyOS), Debian, Termux
**Tools:** paru, mise, bun, uv, yadm, tuckr/stow

---

## Decisions

- **other.txt**: NOT created. Redundant — droid installed via `mise` (`npm:droid`), zerobrew installed directly.
- **AUR merge**: Use remote's curated list + keep `opencode-desktop-bin` (direct binary only, plugins handled elsewhere). Remove `aionui-bin`, `beads-bin`, `openclaw-git` entirely.
- **oxfmt/oxlint**: Install via `mise` (not AUR, not bun). Remove from `pkg/aur.txt` and `pkg/bun.txt`.
- **tuckr vs stow**: Flip to tuckr > stow (matches CLAUDE.md).

---

## Files Created (2)

### `PRD.md` (this file)
Implementation plan committed to repo root.

### `pkg/am.txt` (NEW)
Appman packages from remote:
```
am
am-gui
bauh
cursor-cli
github-store
```

---

## Files Modified (4)

### 1. `setup.sh` — 7 changes

| # | Change | Location | Description |
|---|--------|----------|-------------|
| 1 | Add `run_url()` helper | After `die()` (~line 22) | Downloads + executes scripts with HTTPS validation. Used by zerobrew. |
| 2 | Fix `fetch_pkgfile()` | Line 46 | Replace `cat "$SCRIPT_DIR/$path"` with `printf '%s' "$(<"$SCRIPT_DIR/$path")"` per bash idiom. |
| 3 | Add `install_zerobrew()` | After `setup_am()` | Checks `has zb`, installs via `run_url "https://zerobrew.rs/install"` with `--no-modify-path`. Non-fatal. |
| 4 | Flip `link_system_configs()` | Lines 186-207 | Reorder: tuckr first, stow fallback. Currently reversed. |
| 5 | Update `setup_am()` | Lines 236-238 | Replace commented-out AM apps with actual `load_pkgs am` + `am -i` call. |
| 6 | Add `install_zerobrew` to `main()` | After `install_uv_pkgs` | Single line function call. |
| 7 | Update comment in `main()` | Line 308 | "includes yadm, tuckr, stow, konsave" |

**Delta:** +40 lines (328 → 368)

#### Change 1: `run_url()` helper
```bash
run_url() {
  local url="$1"
  shift
  [[ $url =~ ^https:// ]] || die "Security: URL must be HTTPS: $url"
  local name="${url##*/}"
  [[ $name =~ ^[[:alnum:]._-]+$ ]] || die "Invalid installer filename from URL: $url"
  local tmp="$WORKDIR/$name"
  curl --proto '=https' --tlsv1.3 -fsSL --retry 3 --retry-delay 2 "$url" -o "$tmp" \
    || die "Failed to download $url"
  [[ -s $tmp ]] || die "Downloaded installer is empty: $url"
  bash "$tmp" "$@"
}
```

#### Change 3: `install_zerobrew()`
```bash
install_zerobrew() {
  if has zb; then
    log "zerobrew already installed, skipping"
    return 0
  fi
  log "Installing zerobrew..."
  has curl || sudo pacman -S --needed --noconfirm curl
  run_url "https://zerobrew.rs/install" --no-modify-path
}
```

#### Change 4: `link_system_configs()` reorder
```bash
# BEFORE (current):
if has stow; then ... elif has tuckr; then ...
# AFTER:
if has tuckr; then ... elif has stow; then ...
```

#### Change 5: `setup_am()` update
```bash
# Replace the commented placeholder:
log "Installing AM apps..."
local -a am_apps
mapfile -t am_apps < <(load_pkgs am)
if (( ${#am_apps[@]} > 0 )); then
  am -i "${am_apps[@]}" || warn "Some AM apps failed"
fi
```

#### Change 6: `main()` addition
```bash
install_uv_pkgs
install_zerobrew       # NEW — after uv, before rust
setup_rust
```

---

### 2. `pkg/aur.txt` — merge to ~25 packages

**Remove entirely:** aionui-bin, beads-bin, openclaw-git
**Remove (moved to mise):** oxfmt-bin, oxlint-bin
**Remove (plugins handled elsewhere):** opencode-antigravity-auth, opencode-cursor-auth, opencode-gemini-auth, opencode-optimal-model-temps, opencode-pty
**Remove (replaced/obsolete):** claude-code-acp (moved to bun), cursor-appimage (replaced by cursor-bin), factory-cli-bin (redundant), github-copilot-cli, happy-cli, repomix, smithery-cli, vscodium-marketplace (replaced by vscodium-all-marketplace)
**Keep (direct binary):** opencode-desktop-bin
**Add from remote:** basedpyright, cursor-bin, docker-language-server, github-actions-bin, mdformat-gfm-git, vtsls

---

### 3. `pkg/bun.txt` — expand from 12 to ~24 packages

Replace with remote's list minus oxfmt/oxlint (those go to mise). Adds AI/MCP SDKs, Claude Code integrations, modern tooling:
- @anthropic-ai/sdk, @modelcontextprotocol/sdk, @ai-sdk/openai-compatible
- @zed-industries/claude-code-acp, @github/copilot, @google/jules
- firecrawl-cli, fish-lsp, node-lief, agnix, happy-coder

---

### 4. `pkg/uv.txt` — update from 4 to 5 packages

Remove `zon-format` (JS tool). Add `json-repair`, `mdformat-shfmt`.

---

## Files Unchanged

- `pkg/pacman.txt` — local is more comprehensive (499 packages). Already includes tuckr, stow, yadm, mise.

---

## Verification

```bash
# Syntax & lint
bash -n setup.sh
shellcheck -x setup.sh

# Structure checks
grep -n "has tuckr" setup.sh   # Should appear before "has stow"
grep -n "load_pkgs am" setup.sh  # AM apps loaded from file

# Package counts
wc -l pkg/*.txt
# Expected: am.txt=5, aur.txt=25, bun.txt=24, pacman.txt=499, uv.txt=5

# Duplicate check
for f in pkg/*.txt; do sort "$f" | uniq -d; done  # Should be empty
```

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| AUR packages removed that are still needed | Git history preserves old list; `paru -Q` shows installed |
| tuckr/stow flip breaks existing deploy | Idempotent functions; stow fallback still present |
| Zerobrew install fails | Non-fatal (`warn` not `die`); skipped if already installed |
| AM not installed when am.txt read | `setup_am()` runs first; `has am` guard |
| mise not available for oxfmt/oxlint | mise is in pacman.txt; user installs tools via `mise use` |
