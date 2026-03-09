# YADM Dotfiles Management Guide

This repository is fully configured for [yadm](https://yadm.io) (Yet Another Dotfiles Manager) while maintaining a
clean, hierarchical folder structure.

## 📁 Repository Structure

```
dotfiles/
├── Home/           # User-level dotfiles (~/.*)  [Managed by yadm]
├── etc/            # System configs (/etc/*)     [Managed by stow]
├── usr/            # System configs (/usr/*)     [Managed by stow]
├── Home/.config/yadm/
│   ├── bootstrap   # Managed bootstrap source copied into ~/.config/yadm/bootstrap
│   ├── config      # Repository-wide yadm config
│   └── encrypt     # Encryption patterns used by `yadm encrypt`
└── setup.sh        # One-command full system setup
```

After checkout into `$HOME`, yadm executes `~/.config/yadm/bootstrap` as the bootstrap entrypoint. This repository keeps
`Home/.config/yadm/bootstrap` as the managed source copy and mirrors it into place during deployment.

### Why This Structure?

- **Separation of concerns**: User configs vs. system configs
- **Easy to understand**: Mirrors Linux filesystem structure
- **Flexible deployment**: yadm for user files, stow for system files
- **Git-friendly**: Clean repository with minimal clutter
- **Portable**: Works across different systems
- **Fallback support**: Can still fall back to tuckr if stow is unavailable

---

## 🚀 Quick Start

### First-Time Setup

```bash
# Clone the repository with yadm and run bootstrap immediately
yadm clone https://github.com/Ven0m0/dotfiles.git --bootstrap

# Or use the all-in-one setup script
curl -fsSL https://raw.githubusercontent.com/Ven0m0/dotfiles/main/setup.sh | bash
```

The bootstrap process will:

1. ✅ Deploy dotfiles from `Home/` to `~/`
1. ✅ Install base dependencies (git, zsh, starship, etc.)
1. ✅ Configure shell environment
1. ✅ Set up system configs (requires sudo for etc/, usr/)
1. ✅ Process yadm alternate files

Upstream yadm expects the bootstrap program at `~/.config/yadm/bootstrap`, it must be executable, and it should be
idempotent so it can be safely re-run after future pulls or merges. This repository follows that model.

### Existing Installation

```bash
# Pull latest changes and re-bootstrap
yadm pull && yadm bootstrap

# Or use the sync helper
yadm-sync.sh pull
```

---

## 🔄 Daily Workflow

### Making Changes to Dotfiles

There are two workflows depending on your preference:

#### **Option A: Edit in Repository, Deploy to Home**

```bash
# 1. Navigate to repository
cd $(yadm rev-parse --show-toplevel)

# 2. Make changes in Home/ directory
${EDITOR-nano} Home/.config/zsh/.zshrc

# 3. Deploy changes to your home directory
yadm-sync.sh pull

# 4. Commit changes
git add Home/.config/zsh/.zshrc
git commit -m "Update zsh configuration"
yadm push
```

#### **Option B: Edit in Home, Sync Back to Repository**

```bash
# 1. Edit files in your home directory normally
${EDITOR-nano} ~/.config/zsh/.zshrc

# 2. Sync changes back to repository
yadm-sync.sh push

# 3. Navigate to repo and commit
cd $(yadm rev-parse --show-toplevel)
git add -A
git commit -m "Update zsh configuration"
yadm push
```

---

## 🛠️ yadm-sync Command

A helper script for bidirectional syncing between `~/` and `${REPO}/Home/`.

### Commands

```bash
# Deploy dotfiles from repository to home
yadm-sync.sh pull

# Update repository with changes from home
yadm-sync.sh push

# Preview changes before syncing (dry-run)
yadm-sync.sh push --dry-run
yadm-sync.sh pull --dry-run

# Check what files differ
yadm-sync.sh status

# View detailed differences
yadm-sync.sh diff
```

### Full Workflow Example

```bash
# Make changes to your dotfiles
${EDITOR-nano} ~/.bashrc
${EDITOR-nano} ~/.config/starship.toml

# Check what changed
yadm-sync.sh status

# Preview the sync (optional)
yadm-sync.sh push --dry-run

# Sync changes to repository
yadm-sync.sh push

# Commit and push
cd $(yadm rev-parse --show-toplevel)
git status
git add -A
git commit -m "Update bashrc and starship config"
git push
```

---

## 📋 Common Tasks

### Add New Dotfile to Repository

```bash
# 1. Copy file to repository structure
cd $(yadm rev-parse --show-toplevel)
cp ~/.my-new-config Home/.my-new-config

# 2. Add and commit
git add Home/.my-new-config
git commit -m "Add my-new-config"
yadm push

# 3. The file is now tracked and will be deployed on bootstrap
```

### Update System Configs (etc/, usr/)

System configs are managed separately with **stow**:

```bash
# Navigate to repository
cd $(yadm rev-parse --show-toplevel)

# Edit system config
sudo ${EDITOR-nano} etc/pacman.conf

# Commit changes
git add etc/pacman.conf
git commit -m "Update pacman configuration"
git push

# Re-link system configs (creates symlinks)
# Option 1: Using stow (preferred)
cd $(yadm rev-parse --show-toplevel) && sudo stow -t / etc usr

# Option 2: Using helper script
sudo deploy-system-configs.sh
```

### Check Repository Status

```bash
# Check yadm repository status
yadm status

# Check sync status between ~/ and repo
yadm-sync.sh status

# View repository location
yadm rev-parse --show-toplevel

# View git log
yadm log --oneline -10
```

### Bootstrap After Fresh Install

```bash
# Re-run bootstrap to redeploy everything
yadm bootstrap

# Or manually
~/.config/yadm/bootstrap
```

---

## 🎯 How It Works

### yadm Bootstrap Process

When you run `yadm bootstrap`, yadm executes `~/.config/yadm/bootstrap`. In this repository, that script then:

```
1. Deploys user dotfiles
   └─> rsync Home/ → ~/

2. Installs base dependencies
   └─> git, zsh, starship, fzf, konsave, etc.

3. Configures the shell environment
   ├─> Set Zsh as default shell
   ├─> Install Starship preset
   └─> Add zoxide integration

4. Deploys system configs (with sudo)
   └─> stow link etc/ usr/ → /

5. Applies optional KDE settings
   └─> konsave import/apply main.knsv

6. Processes alternate files
   └─> yadm alt (OS/host-specific configs)
```

If `konsave` is available, the bootstrap imports and applies the `main` profile from `main.knsv` so Plasma/KDE settings are restored automatically.

### Subdirectory Deployment

Unlike traditional yadm setups where dotfiles are at the repository root, this repo uses:

- **Repository**: `Home/.config/zsh/.zshrc`
- **Deployed to**: `~/.config/zsh/.zshrc`

The `~/.config/yadm/bootstrap` script handles this deployment automatically using rsync.

### System Configs with Stow

System-level configs (`/etc`, `/usr`) require root permissions and are managed with **stow**:

```bash
# Using stow (preferred)
cd /path/to/repo && sudo stow -t / etc
# Creates: /etc/pacman.conf → /path/to/repo/etc/pacman.conf

# Using helper script
sudo deploy-system-configs.sh etc usr
```

The bootstrap script automatically detects which tool is available and uses it accordingly.

---

## 🔧 Advanced Usage

### OS-Specific Configurations (Alternates)

yadm supports [alternate files](https://yadm.io/docs/alternates) for different operating systems or hosts:

```bash
# Create OS-specific version
cp Home/.bashrc Home/.bashrc##os.Linux
cp Home/.bashrc Home/.bashrc##os.Darwin  # macOS

# Create host-specific version
cp Home/.zshrc Home/.zshrc##hostname.myserver

# Process alternates
yadm alt
```

### Encrypting Sensitive Files

```bash
# Create encryption config
echo '.ssh/id_rsa' >> ~/.config/yadm/encrypt

# Encrypt files
yadm encrypt

# Track the encryption config and encrypted archive, not the plaintext secrets
yadm add ~/.config/yadm/encrypt ~/.local/share/yadm/archive

# Decrypt on new system
yadm decrypt
```

### Custom Bootstrap Scripts

Add additional bootstrapping for specific applications:

```bash
# This repository keeps Home/.config/yadm/bootstrap as the managed source copy
# and mirrors it to ~/.config/yadm/bootstrap during deployment.
# Keep both files identical if you edit the bootstrap logic.
${EDITOR-nano} Home/.config/yadm/bootstrap
```

### Useful Aliases

The `Home/.config/yadm/config` file provides helpful aliases:

```bash
yadm sync-pull      # Alias for: yadm-sync.sh pull
yadm sync-push      # Alias for: yadm-sync.sh push
yadm sync-status    # Alias for: yadm-sync.sh status
yadm deploy         # Alias for: yadm bootstrap
```

---

## 🐛 Troubleshooting

### yadm repository not found

```bash
# Check if repository is cloned
yadm status

# If not, clone it
yadm clone https://github.com/Ven0m0/dotfiles.git --bootstrap
```

### Files not syncing properly

```bash
# Check rsync is installed
command -v rsync

# Install rsync
sudo pacman -S rsync  # Arch
sudo apt install rsync  # Debian/Ubuntu

# Re-run bootstrap
yadm bootstrap
```

### yadm-sync.sh command not found

```bash
# Deploy user scripts
yadm-sync.sh pull

# Or manually copy
cp "$(yadm rev-parse --show-toplevel)/Home/.local/bin/yadm-sync.sh" ~/.local/bin/
chmod +x ~/.local/bin/yadm-sync.sh

# Ensure ~/.local/bin is in PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

### System configs not applying

```bash
# Install stow
paru -S stow       # Arch
sudo apt install stow  # Debian/Ubuntu

# Re-link system configs
cd $(yadm rev-parse --show-toplevel)

# Using stow:
sudo stow -t / etc usr

# OR using helper script:
sudo deploy-system-configs.sh
```

---

## 📚 Further Reading

- **yadm Documentation**: [https://yadm.io/docs](https://yadm.io/docs)
- **yadm Alternate Files**: [https://yadm.io/docs/alternates](https://yadm.io/docs/alternates)
- **yadm Encryption**: [https://yadm.io/docs/encryption](https://yadm.io/docs/encryption)
- **GNU Stow Manual**: [https://www.gnu.org/software/stow/manual/](https://www.gnu.org/software/stow/manual/)

---

## 🤝 Contributing

When adding new dotfiles:

1. Add them to the appropriate directory (`Home/`, `etc/`, `usr/`)
1. Test deployment: `yadm-sync.sh pull` or `yadm bootstrap`
1. Commit with clear message
1. Push to remote

---

## 📄 License

See main [README.md](./README.md) for license information.
