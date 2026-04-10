# Chezmoi Dotfiles Management Guide

This repository is fully configured for [chezmoi](https://chezmoi.io) (Yet Another Dotfiles Manager) while maintaining a
clean, hierarchical folder structure.

## 📁 Repository Structure

```
dotfiles/
├── Home/           # User-level dotfiles (~/.*)  [Managed by chezmoi]
├── etc/            # System configs (/etc/*)     [Managed by stow]
├── usr/            # System configs (/usr/*)     [Managed by stow]
├── Home/.config/chezmoi/
│   ├── bootstrap   # Managed bootstrap source copied into ~/.config/chezmoi/bootstrap
│   ├── config      # Repository-wide chezmoi config
│   └── encrypt     # Encryption patterns used by `chezmoi encrypt`
└── setup.sh        # One-command full system setup
```

After checkout into `$HOME`, chezmoi executes `~/.config/chezmoi/bootstrap` as the bootstrap entrypoint. This repository keeps
`Home/.config/chezmoi/bootstrap` as the managed source copy and mirrors it into place during deployment.

### Why This Structure?

- **Separation of concerns**: User configs vs. system configs
- **Easy to understand**: Mirrors Linux filesystem structure
- **Flexible deployment**: chezmoi for user files, stow for system files
- **Git-friendly**: Clean repository with minimal clutter
- **Portable**: Works across different systems
- **Fallback support**: Can still fall back to tuckr if stow is unavailable

---

## 🚀 Quick Start

### First-Time Setup

```bash
# Clone the repository with chezmoi and run bootstrap immediately
chezmoi clone https://github.com/Ven0m0/dotfiles.git --bootstrap

# Or use the all-in-one setup script
curl -fsSL https://raw.githubusercontent.com/Ven0m0/dotfiles/main/setup.sh | bash
```

The bootstrap process will:

1. ✅ Deploy dotfiles from `Home/` to `~/`
1. ✅ Install base dependencies (git, zsh, starship, etc.)
1. ✅ Configure shell environment
1. ✅ Set up system configs (requires sudo for etc/, usr/)
1. ✅ Process chezmoi alternate files

Upstream chezmoi expects the bootstrap program at `~/.config/chezmoi/bootstrap`, it must be executable, and it should be
idempotent so it can be safely re-run after future pulls or merges. This repository follows that model.

### Existing Installation

```bash
# Pull latest changes and re-bootstrap
chezmoi pull && chezmoi bootstrap

# Or use the sync helper
chezmoi-sync.sh pull
```

---

## 🔄 Daily Workflow

### Making Changes to Dotfiles

There are two workflows depending on your preference:

#### **Option A: Edit in Repository, Deploy to Home**

```bash
# 1. Navigate to repository
cd $(chezmoi rev-parse --show-toplevel)

# 2. Make changes in Home/ directory
${EDITOR-nano} Home/.config/zsh/.zshrc

# 3. Deploy changes to your home directory
chezmoi-sync.sh pull

# 4. Commit changes
git add Home/.config/zsh/.zshrc
git commit -m "Update zsh configuration"
chezmoi push
```

#### **Option B: Edit in Home, Sync Back to Repository**

```bash
# 1. Edit files in your home directory normally
${EDITOR-nano} ~/.config/zsh/.zshrc

# 2. Sync changes back to repository
chezmoi-sync.sh push

# 3. Navigate to repo and commit
cd $(chezmoi rev-parse --show-toplevel)
git add -A
git commit -m "Update zsh configuration"
chezmoi push
```

---

## 🛠️ chezmoi-sync Command

A helper script for bidirectional syncing between `~/` and `${REPO}/Home/`.

### Commands

```bash
# Deploy dotfiles from repository to home
chezmoi-sync.sh pull

# Update repository with changes from home
chezmoi-sync.sh push

# Preview changes before syncing (dry-run)
chezmoi-sync.sh push --dry-run
chezmoi-sync.sh pull --dry-run

# Check what files differ
chezmoi-sync.sh status

# View detailed differences
chezmoi-sync.sh diff
```

### Full Workflow Example

```bash
# Make changes to your dotfiles
${EDITOR-nano} ~/.bashrc
${EDITOR-nano} ~/.config/starship.toml

# Check what changed
chezmoi-sync.sh status

# Preview the sync (optional)
chezmoi-sync.sh push --dry-run

# Sync changes to repository
chezmoi-sync.sh push

# Commit and push
cd $(chezmoi rev-parse --show-toplevel)
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
cd $(chezmoi rev-parse --show-toplevel)
cp ~/.my-new-config Home/.my-new-config

# 2. Add and commit
git add Home/.my-new-config
git commit -m "Add my-new-config"
chezmoi push

# 3. The file is now tracked and will be deployed on bootstrap
```

### Update System Configs (etc/, usr/)

System configs are managed separately with **stow**:

```bash
# Navigate to repository
cd $(chezmoi rev-parse --show-toplevel)

# Edit system config
sudo ${EDITOR-nano} etc/pacman.conf

# Commit changes
git add etc/pacman.conf
git commit -m "Update pacman configuration"
git push

# Re-link system configs (creates symlinks)
# Option 1: Using stow (preferred)
cd $(chezmoi rev-parse --show-toplevel) && sudo stow -t / etc usr

# Option 2: Using helper script
sudo deploy-system-configs.sh
```

### Check Repository Status

```bash
# Check chezmoi repository status
chezmoi status

# Check sync status between ~/ and repo
chezmoi-sync.sh status

# View repository location
chezmoi rev-parse --show-toplevel

# View git log
chezmoi log --oneline -10
```

### Bootstrap After Fresh Install

```bash
# Re-run bootstrap to redeploy everything
chezmoi bootstrap

# Or manually
~/.config/chezmoi/bootstrap
```

---

## 🎯 How It Works

### chezmoi Bootstrap Process

When you run `chezmoi bootstrap`, chezmoi executes `~/.config/chezmoi/bootstrap`. In this repository, that script then:

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
   └─> chezmoi alt (OS/host-specific configs)
```

If `konsave` is available, the bootstrap imports and applies the `main` profile from `main.knsv` so Plasma/KDE settings are restored automatically.

### Subdirectory Deployment

Unlike traditional chezmoi setups where dotfiles are at the repository root, this repo uses:

- **Repository**: `Home/.config/zsh/.zshrc`
- **Deployed to**: `~/.config/zsh/.zshrc`

The `~/.config/chezmoi/bootstrap` script handles this deployment automatically using rsync.

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

chezmoi supports [alternate files](https://chezmoi.io/docs/alternates) for different operating systems or hosts:

```bash
# Create OS-specific version
cp Home/.bashrc Home/.bashrc##os.Linux
cp Home/.bashrc Home/.bashrc##os.Darwin  # macOS

# Create host-specific version
cp Home/.zshrc Home/.zshrc##hostname.myserver

# Process alternates
chezmoi alt
```

### Encrypting Sensitive Files

```bash
# Create encryption config
echo '.ssh/id_rsa' >> ~/.config/chezmoi/encrypt

# Encrypt files
chezmoi encrypt

# Track the encryption config and encrypted archive, not the plaintext secrets
chezmoi add ~/.config/chezmoi/encrypt ~/.local/share/chezmoi/archive

# Decrypt on new system
chezmoi decrypt
```

### Custom Bootstrap Scripts

Add additional bootstrapping for specific applications:

```bash
# This repository keeps Home/.config/chezmoi/bootstrap as the managed source copy
# and mirrors it to ~/.config/chezmoi/bootstrap during deployment.
# Keep both files identical if you edit the bootstrap logic.
${EDITOR-nano} Home/.config/chezmoi/bootstrap
```

### Useful Aliases

The `Home/.config/chezmoi/config` file provides helpful aliases:

```bash
chezmoi sync-pull      # Alias for: chezmoi-sync.sh pull
chezmoi sync-push      # Alias for: chezmoi-sync.sh push
chezmoi sync-status    # Alias for: chezmoi-sync.sh status
chezmoi deploy         # Alias for: chezmoi bootstrap
```

---

## 🐛 Troubleshooting

### chezmoi repository not found

```bash
# Check if repository is cloned
chezmoi status

# If not, clone it
chezmoi clone https://github.com/Ven0m0/dotfiles.git --bootstrap
```

### Files not syncing properly

```bash
# Check rsync is installed
command -v rsync

# Install rsync
sudo pacman -S rsync  # Arch
sudo apt install rsync  # Debian/Ubuntu

# Re-run bootstrap
chezmoi bootstrap
```

### chezmoi-sync.sh command not found

```bash
# Deploy user scripts
chezmoi-sync.sh pull

# Or manually copy
cp "$(chezmoi rev-parse --show-toplevel)/Home/.local/bin/chezmoi-sync.sh" ~/.local/bin/
chmod +x ~/.local/bin/chezmoi-sync.sh

# Ensure ~/.local/bin is in PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

### System configs not applying

```bash
# Install stow
paru -S stow       # Arch
sudo apt install stow  # Debian/Ubuntu

# Re-link system configs
cd $(chezmoi rev-parse --show-toplevel)

# Using stow:
sudo stow -t / etc usr

# OR using helper script:
sudo deploy-system-configs.sh
```

---

## 📚 Further Reading

- **chezmoi Documentation**: [https://chezmoi.io/docs](https://chezmoi.io/docs)
- **chezmoi Alternate Files**: [https://chezmoi.io/docs/alternates](https://chezmoi.io/docs/alternates)
- **chezmoi Encryption**: [https://chezmoi.io/docs/encryption](https://chezmoi.io/docs/encryption)
- **GNU Stow Manual**: [https://www.gnu.org/software/stow/manual/](https://www.gnu.org/software/stow/manual/)

---

## 🤝 Contributing

When adding new dotfiles:

1. Add them to the appropriate directory (`Home/`, `etc/`, `usr/`)
1. Test deployment: `chezmoi-sync.sh pull` or `chezmoi bootstrap`
1. Commit with clear message
1. Push to remote

---

## 📄 License

See main [README.md](./README.md) for license information.
