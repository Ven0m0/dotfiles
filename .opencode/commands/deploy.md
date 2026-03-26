---
description: Deploy system configs from etc/ to /etc using tuckr (or stow fallback). Requires sudo.
agent: build
---

Deploy system configuration files from `etc/` to `/etc` using the appropriate tool.

```bash
# Detect available deployment tool
if command -v tuckr &>/dev/null; then
  echo "Using tuckr"
  sudo tuckr link -d ~/dotfiles -t / etc --verbose 2>&1
elif command -v stow &>/dev/null; then
  echo "Falling back to stow"
  sudo stow -t / -d ~/dotfiles etc --verbose 2>&1
else
  echo "ERROR: Neither tuckr nor stow found. Install with: paru -S tuckr"
  exit 1
fi
```

After deployment, verify key config files are linked:
```bash
ls -la /etc/pacman.conf /etc/ssh/sshd_config /etc/systemd/system/ 2>&1 | head -20
```

If deploying after adding a new udev rule, also run:
```bash
sudo udevadm control --reload-rules && sudo udevadm trigger
```

Report: which files were linked, which were skipped (conflicts), and any errors.

IMPORTANT: Do NOT deploy `etc/sudoers` or `etc/ssh/sshd_config` without explicit user confirmation — these affect system security.
