# ============================================================================
# Zimfw Configuration - Optimized Plugin Loading
# ============================================================================

# ---[ Core Modules ]---
zmodule environment
zmodule input
zmodule utility

# ---[ Completion System ]---
zmodule zsh-users/zsh-completions --fpath src
zmodule completion

# ---[ Command History ]---
zmodule history

# ---[ Prompt ]---
zmodule romkatv/powerlevel10k --use degit

# ---[ Syntax & Suggestions ]---
zmodule zdharma-continuum/fast-syntax-highlighting
zmodule zsh-users/zsh-autosuggestions
zmodule marlonrichert/zsh-autocomplete

# ---[ Auto-pairing ]---
zmodule hlissner/zsh-autopair

# ---[ FZF Integration ]---
zmodule lincheney/fzf-tab-completion --source zsh/fzf-zsh-completion.zsh

# ---[ Utility Plugins ]---
zmodule MichaelAquilina/zsh-you-should-use
zmodule QuarticCat/zsh-smartcache
zmodule romkatv/zsh-defer
zmodule qoomon/zsh-lazyload

# ---[ OMZ Plugins (selective) ]---
zmodule ohmyzsh/ohmyzsh --root plugins/git
zmodule ohmyzsh/ohmyzsh --root plugins/sudo
zmodule ohmyzsh/ohmyzsh --root plugins/archlinux
zmodule ohmyzsh/ohmyzsh --root plugins/debian
zmodule ohmyzsh/ohmyzsh --root plugins/docker
zmodule ohmyzsh/ohmyzsh --root plugins/docker-compose
zmodule ohmyzsh/ohmyzsh --root plugins/ssh-agent
zmodule ohmyzsh/ohmyzsh --root plugins/command-not-found

# ---[ History Navigation ]---
zmodule zsh-users/zsh-history-substring-search
