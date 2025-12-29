# YADM Dotfiles Management Guide

This repository is fully configured for [yadm](https://yadm.io) (Yet Another Dotfiles Manager) while maintaining a
clean, hierarchical folder structure.

## 📁 Repository Structure

```
dotfiles/
├── Home/           # User-level dotfiles (~/.*)  [Managed by yadm]
├── etc/            # System configs (/etc/*)     [Managed by tuckr/stow]
├── usr/            # System configs (/usr/*)     [Managed by tuckr/stow]
├── .yadm/          # YADM configuration
│   ├── bootstrap   # Main bootstrap script
│   └── config      # Repository-wide yadm config
└── setup.sh        # One-command full system setup
```

### Why This Structure?

- **Separation of concerns**: User configs vs. system configs
- **Easy to understand**: Mirrors Linux filesystem structure
- **Flexible deployment**: yadm for user files, tuckr/stow for system files
- **Git-friendly**: Clean repository with minimal clutter
- **Portable**: Works across different systems
- **Fallback support**: Automatically uses stow if tuckr is unavailable

---

## 🚀 Quick Start

### First-Time Setup

```bash
# Clone the repository with yadm
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

### Existing Installation

```bash
# Pull latest changes and re-bootstrap
yadm pull && yadm bootstrap

# Or use the sync helper
yadm-sync pull
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
yadm-sync pull

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
yadm-sync push

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
yadm-sync pull

# Update repository with changes from home
yadm-sync push

# Preview changes before syncing (dry-run)
yadm-sync push --dry-run
yadm-sync pull --dry-run

# Check what files differ
yadm-sync status

# View detailed differences
yadm-sync diff
```

### Full Workflow Example

```bash
# Make changes to your dotfiles
${EDITOR-nano} ~/.bashrc
${EDITOR-nano} ~/.config/starship.toml

# Check what changed
yadm-sync status

# Preview the sync (optional)
yadm-sync push --dry-run

# Sync changes to repository
yadm-sync push

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

System configs are managed separately with **tuckr** (or **stow** as fallback):

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
# Option 1: Using tuckr (preferred)
sudo tuckr link -d $(yadm rev-parse --show-toplevel) -t / etc usr

# Option 2: Using stow (fallback)
cd $(yadm rev-parse --show-toplevel) && sudo stow -t / etc usr

# Option 3: Using helper script (auto-detects tuckr/stow)
sudo deploy-system-configs
```

### Check Repository Status

```bash
# Check yadm repository status
yadm status

# Check sync status between ~/ and repo
yadm-sync status

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
cd $(yadm rev-parse --show-toplevel)
./.yadm/bootstrap
```

---

## 🎯 How It Works

### yadm Bootstrap Process

When you run `yadm bootstrap`, the following happens:

```
1. Deploy User Dotfiles
   └─> rsync Home/ → ~/

2. Install Base Dependencies
   └─> git, zsh, starship, fzf, konsave, etc.

3. Configure Shell Environment
   ├─> Set Zsh as default shell
   ├─> Install Starship preset
   └─> Add zoxide integration

4. Deploy System Configs (with sudo)
   └─> tuckr link etc/ usr/ → /

5. Process Alternate Files
   └─> yadm alt (OS/host-specific configs)

6. Run Application Bootstraps
   └─> ~/.config/yadm/bootstrap
```

If `konsave` is available, the bootstrap imports and applies the `main` profile from `main.knsv` so Plasma/KDE settings are restored automatically.

### Subdirectory Deployment

Unlike traditional yadm setups where dotfiles are at the repository root, this repo uses:

- **Repository**: `Home/.config/zsh/.zshrc`
- **Deployed to**: `~/.config/zsh/.zshrc`

The `.yadm/bootstrap` script handles this deployment automatically using rsync.

### System Configs with Tuckr or Stow

System-level configs (`/etc`, `/usr`) require root permissions and are managed with **tuckr** or **stow**:

```bash
# Using tuckr (preferred - supports hooks)
sudo tuckr link -d /path/to/repo -t / etc
# Creates: /etc/pacman.conf → /path/to/repo/etc/pacman.conf

# Using stow (fallback - widely available)
cd /path/to/repo && sudo stow -t / etc
# Creates: /etc/pacman.conf → /path/to/repo/etc/pacman.conf

# Using helper script (auto-detects best tool)
sudo deploy-system-configs etc usr
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

# Decrypt on new system
yadm decrypt
```

### Custom Bootstrap Scripts

Add additional bootstrapping for specific applications:

```bash
# Create app-specific bootstrap
mkdir -p Home/.config/yadm/
${EDITOR-nano} Home/.config/yadm/bootstrap

# This runs automatically after main bootstrap
```

### Useful Aliases

The `.yadm/config` provides helpful aliases:

```bash
yadm sync-pull      # Alias for: yadm-sync pull
yadm sync-push      # Alias for: yadm-sync push
yadm sync-status    # Alias for: yadm-sync status
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

### yadm-sync command not found

```bash
# Deploy user scripts
yadm-sync pull

# Or manually copy
cp $(yadm rev-parse --show-toplevel)/Home/.local/bin/yadm-sync ~/.local/bin/
chmod +x ~/.local/bin/yadm-sync

# Ensure ~/.local/bin is in PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

### System configs not applying

```bash
# Option 1: Install tuckr (preferred)
paru -S tuckr  # Arch/AUR

# Option 2: Install stow (fallback, widely available)
paru -S stow       # Arch
sudo apt install stow  # Debian/Ubuntu

# Re-link system configs with sudo
cd $(yadm rev-parse --show-toplevel)

# Using tuckr:
sudo tuckr link -d "$PWD" -t / etc usr

# OR using stow:
sudo stow -t / etc usr

# OR using helper script (auto-detects):
sudo deploy-system-configs
```

---

## 📚 Further Reading

- **yadm Documentation**: [https://yadm.io/docs](https://yadm.io/docs)
- **yadm Alternate Files**: [https://yadm.io/docs/alternates](https://yadm.io/docs/alternates)
- **yadm Encryption**: [https://yadm.io/docs/encryption](https://yadm.io/docs/encryption)
- **tuckr Documentation**: [https://github.com/RaphGL/tuckr](https://github.com/RaphGL/tuckr)

---

## 🤝 Contributing

When adding new dotfiles:

1. Add them to the appropriate directory (`Home/`, `etc/`, `usr/`)
1. Test deployment: `yadm-sync pull` or `yadm bootstrap`
1. Commit with clear message
1. Push to remote

---

## 📄 License

See main [README.md](./README.md) for license information.
