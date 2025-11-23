# Tool-specific Configurations

# FZF
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# Zoxide (smart cd)
eval "$(zoxide init zsh)"

# Pre-Oh My Zsh configuration (if exists)
if [ -f "$HOME/.zshrc.pre-oh-my-zsh" ]; then
    source "$HOME/.zshrc.pre-oh-my-zsh" 
fi
