# ============================================================================
# Zimfw Config - Minimal High-Value Plugins
# ============================================================================

# Core modules
zmodule environment
zmodule input
zmodule utility
zmodule history

# Completion
zmodule zsh-users/zsh-completions --fpath src
zmodule completion

# Prompt (P10k)
zmodule romkatv/powerlevel10k --use degit

# Fish-like features
zmodule zdharma-continuum/fast-syntax-highlighting
zmodule zsh-users/zsh-autosuggestions
zmodule zsh-users/zsh-history-substring-search

# Auto-pairing brackets
zmodule hlissner/zsh-autopair

# FZF tab completion
zmodule lincheney/fzf-tab-completion --source zsh/fzf-zsh-completion.zsh

# Deferred loading (performance)
zmodule romkatv/zsh-defer

# Git integration (OMZ has good git aliases)
zmodule ohmyzsh/ohmyzsh --root plugins/git
zmodule ohmyzsh/ohmyzsh --root plugins/sudo

# System-specific
zmodule ohmyzsh/ohmyzsh --root plugins/archlinux
