# Environment Variables and PATH Exports

# Language settings
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Preferred editor
export EDITOR='nvim'
export VISUAL="$EDITOR"

# NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Go PATH
export PATH=$PATH:$(go env GOPATH)/bin

# Python/pipx PATH
export PATH="$PATH:/Users/igorvigasin/Library/Python/3.9/bin"
export PATH="$PATH:/Users/igorvigasin/.local/bin"

# Java PATH
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# Rancher Desktop PATH
### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/igorvigasin/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# Local bin PATH
export PATH="$HOME/.local/bin:$PATH"

# Bat theme
export BAT_THEME="Dracula"

# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info --preview 'bat --style=numbers --color=always --line-range :500 {}'"
