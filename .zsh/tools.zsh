# Tool-specific Configurations

# FZF
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# Zoxide (smart cd)
eval "$(zoxide init zsh)"

# mise (language runtimes: node, python, go, java)
command -v mise >/dev/null && eval "$(mise activate zsh)"
