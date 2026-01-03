# ============================================================================
# Zimfw - Minimal High-Value Plugins
# ============================================================================

# Core modules
zmodule environment
zmodule input
zmodule utility
zmodule history

# Completion
zmodule zsh-users/zsh-completions --fpath src
zmodule completion

# Prompt
zmodule romkatv/powerlevel10k --use degit

# Fish-like features
zmodule zdharma-continuum/fast-syntax-highlighting
zmodule zsh-users/zsh-autosuggestions
zmodule zsh-users/zsh-history-substring-search

# Auto-pairing
zmodule hlissner/zsh-autopair

# FZF integration
zmodule lincheney/fzf-tab-completion --source zsh/fzf-zsh-completion.zsh

# Performance
zmodule romkatv/zsh-defer

# System-specific
zmodule ohmyzsh/ohmyzsh --root plugins/git
zmodule ohmyzsh/ohmyzsh --root plugins/sudo
zmodule ohmyzsh/ohmyzsh --root plugins/archlinux
