---
name: dotfile-sync
description: Expert knowledge of YADM + Tuckr deployment model for this repo. Covers Home/ vs etc/ path conventions, yadm-sync workflow, and system config deployment. Use when working with dotfile deployment, sync operations, or adding new config files.
---

# Dotfile Sync & Deployment

## Path Model

| Repo Path | Deploys To | Tool |
|-----------|-----------|------|
| `Home/.config/app/` | `~/.config/app/` | YADM |
| `Home/.bashrc` | `~/.bashrc` | YADM |
| `Home/.local/bin/*.sh` | `~/.local/bin/*.sh` | YADM |
| `etc/pacman.conf` | `/etc/pacman.conf` | Tuckr |
| `etc/systemd/` | `/etc/systemd/` | Tuckr |
| `etc/udev/rules.d/` | `/etc/udev/rules.d/` | Tuckr |

NEVER put user configs under `etc/` or system configs under `Home/`.

## Sync Commands

```bash
yadm-sync pull   # Repo Home/ → ~/  (deploy to live system)
yadm-sync push   # ~/         → Repo Home/ (capture live changes)
yadm-sync status # Show differences without applying
```

Always run `yadm-sync status` before a push to review what changed.

## System Config Deployment

```bash
# Primary (preferred)
sudo tuckr link -d ~/dotfiles -t / etc

# Fallback if tuckr unavailable
sudo stow -t / -d ~/dotfiles etc
```

## Adding a New Config File

1. Create it under the correct prefix: `Home/.config/app/` or `etc/app.conf`
2. For user config: run `yadm-sync pull` to deploy
3. For system config: run `sudo deploy-system-configs.sh`
4. Stage specifically: `git add Home/.config/app/config.toml`
5. Never `git add -A` — it may sweep in secrets or yadm state files

## Protected Configs (Require Explicit Approval)

- `etc/pacman.conf` — package manager
- `etc/paru.conf`, `etc/makepkg.conf` — build settings
- `etc/sysctl.d/` — kernel parameters
- `etc/sudoers` — privilege escalation
- `etc/ssh/sshd_config` — SSH server
- `Home/.config/zsh/.zshrc` — interactive shell
- `Home/.gitconfig` — git identity
