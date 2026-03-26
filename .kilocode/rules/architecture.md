# Architecture Rules

## Directory Ownership

| Directory | Deploys to | Tool | What goes here |
|-----------|-----------|------|----------------|
| `Home/` | `~/` | YADM | All user dotfiles and configs |
| `Home/.config/` | `~/.config/` | YADM | XDG app configs (65+ apps) |
| `Home/.local/bin/` | `~/.local/bin/` | YADM | Executable scripts (27 total) |
| `etc/` | `/etc/` | Tuckr | System-wide configs only |
| `.github/workflows/` | CI only | n/a | GitHub Actions |
| `.github/instructions/` | AI context | n/a | Copilot/Claude instructions |
| `docs/` | Documentation | n/a | Project docs |
| `pkg/` | Package lists | n/a | Arch/Debian package manifests |

## New File Placement

- New user app config → `Home/.config/<appname>/`
- New utility script → `Home/.local/bin/<name>.sh` (must be executable)
- New system config → `etc/<path-matching-/etc/>`
- New CI workflow → `.github/workflows/<name>.yml`
- New documentation → `docs/` or inline in AGENTS.md

## Cross-Platform Awareness

Scripts MUST handle three targets: Arch Linux (CachyOS), Debian, Termux. Use this pattern:

```bash
if [[ -f /etc/arch-release ]]; then
  # Arch-specific
elif [[ -f /etc/debian_version ]]; then
  # Debian-specific
elif [[ -n "${TERMUX_VERSION:-}" ]]; then
  # Termux-specific
fi
```

Package manager chain: `paru` → `yay` → `pacman` (Arch); `apt` (Debian); `pkg` (Termux).

## What NOT to Create

- Do NOT create files in `~` root without matching an existing pattern
- Do NOT create helper scripts for one-off operations — inline them or add to existing scripts
- Do NOT create new config directories under `Home/.config/` unless an actual app uses it
- Do NOT create abstract utility libraries — shell functions go in `.bash_functions`

## Import / Source Rules

- Shell scripts source from `~/.bash_functions` or `~/.bashrc` only
- Never source absolute paths — use `${XDG_CONFIG_HOME:-$HOME/.config}/` prefix
- Python scripts: stdlib only (no new pip deps without user approval)
