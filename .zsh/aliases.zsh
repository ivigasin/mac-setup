# Aliases

# Modern ls/cat replacements
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --git --no-user --no-permissions'
alias la='eza -la --icons --git'
alias cat='bat --paging=never'
alias less='bat'

# Editor aliases
alias vi='nvim'
alias vim='nvim'
alias v='nvim'
alias hosts='sudo vi /etc/hosts'

# Python aliases
alias python=python3
alias pip=pip3

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'

# Safe file operations
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'

# Utilities
alias grep='rg'
alias ca='cursor-agent'
alias claude="/Users/igorvigasin/.claude/local/claude"
