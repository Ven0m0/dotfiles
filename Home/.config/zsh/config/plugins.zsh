# Zim modules (order matters)
zmodule environment
zmodule git
zmodule input
zmodule termtitle
zmodule utility

# Prompt (must be before completion)
zmodule romkatv/powerlevel10k --use degit

# Completion (base + extras)
zmodule zsh-users/zsh-completions --fpath src
zmodule completion

# Syntax & suggestions (load late)
zmodule zdharma-continuum/fast-syntax-highlighting
zmodule zsh-users/zsh-autosuggestions

# History search
zmodule zsh-users/zsh-history-substring-search

# FZF integration
zmodule fzf

# Utilities
zmodule hlissner/zsh-autopair
zmodule MichaelAquilina/zsh-you-should-use
