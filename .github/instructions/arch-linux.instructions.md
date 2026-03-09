---
description: 'Arch Linux administration, pacman workflows, and rolling-release best practices'
applyTo: "**"
excludeAgent: "code-review"
---

# Arch Linux Administration

<Standards>

**Platform**: Rolling-release model. Full upgrades only (`pacman -Syu`), no partial upgrades. Prefer official repos and Arch Wiki.

**Package Management**: `pacman -Syu` upgrade | `pacman -Qi` info | `pacman -Ql` list | `pacman -Ss` search. AUR helpers with caution (always review PKGBUILDs).

**Configuration**: Keep config under `/etc/`, never edit `/usr/`. Use systemd drop-ins in `/etc/systemd/system/<unit>.d/`. Manage services with `systemctl`, logs with `journalctl`.

**Security**: Reboot after kernel/core library upgrades. Least-privilege `sudo`. Minimal packages. Explicit firewall tooling (nftables/ufw).

</Standards>

<WhatToAdd>

- Copy-paste-ready command blocks
- Validation steps after changes
- Rollback/cleanup steps for risky operations

</WhatToAdd>
