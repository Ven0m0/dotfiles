# Repo Manual: Arch/Debian Dotfiles

**System:** YADM (`Home/`→`~/`) + Tuckr (`etc/`,`usr/`→`/`).
**Targets:** Arch (CachyOS), Debian, Termux.
**Directives:** User>Rules. Verify. Edit>Create (min Δ). Debt-First. Auto-exec.
**Style:** Blunt, precise. `Result ∴ Cause`. Lists ≤7.

## Standards

- **Bash:** `set -euo pipefail`. `#!/usr/bin/env bash`.
  - *Idioms:* `[[ regex ]]`, `mapfile -t`, `local -n`, `printf`, `ret=$(fn)`.
  - *Ban:* `eval`, `ls` parse, backticks.
  - *Pkg:* `paru`→`yay` (Arch) | `apt` (Debian). Check `pacman -Q` first.
- **Tools:** fd→find | rg→grep | bat→cat | sd→sed | aria2→curl | jaq→jq | rust-parallel.
- **Perf:** Batch I/O. Async. Anchor regex (`grep -F`). Cache hot data.
- **Protected:** `pacman.conf`, `.zshrc`, `.gitconfig`, `sysctl.d/`.

## Workflow

- **Cycle:** TDD (Red→Green→Refactor). Edit > Create.
- **Sync:** `yadm-sync.sh` (User). `tuckr set etc usr` (Sys).
- **CI:** `lint-format` (shfmt, shellcheck, biome, ruff, actionlint).
- **QA:** Shellcheck + Syntax verify before save.

## Key Assets

- **Scripts (`~/.local/bin`):**
  - *Sys:* `pkgui` (TUI), `systool` (maint), `dosudo` (priv), `autostart`.
  - *Media:* `media-opt`, `ffwrap`, `wp`.
  - *File/Net:* `fzgrep`, `fzgit`, `netinfo`, `websearch`.
  - *Dev:* `yadm-sync`, `lint-format`.
- **Configs:** 88 total. Shells (Bash/Zsh/Fish), Terminals, Dev tools (VSCode/Git/Mise).
- **AI:** Claude (Agents/Cmds), Copilot, Gemini (`.gemini/`).

## Deployment

`yadm clone --bootstrap` → Install Pkgs → Deploy Home → Deploy Sys (Tuckr).
