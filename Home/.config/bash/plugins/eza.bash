#!/usr/bin/env bash
has eza || return
# Eza aliases for modern ls replacement
alias ls='eza -F --color=auto --group-directories-first --icons=auto'
alias la='eza -aF --color=auto --group-directories-first --icons=auto'
alias ll='eza -alF --color=auto --git --header --group-directories-first --icons=auto'
alias lt='eza -aT -L 2 --color=auto --group-directories-first --icons=auto'
alias tree='eza -T --color=always --icons=auto'
