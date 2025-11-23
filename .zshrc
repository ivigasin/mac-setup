# Main Zsh Configuration File
# This file sources modular configuration files from ~/.zsh/

ZSH_CONFIG_DIR="$HOME/.zsh"

# Source configuration files in order
if [ -d "$ZSH_CONFIG_DIR" ]; then
    # Oh My Zsh configuration (must be first)
    [ -f "$ZSH_CONFIG_DIR/config.zsh" ] && source "$ZSH_CONFIG_DIR/config.zsh"
    
    # History settings
    [ -f "$ZSH_CONFIG_DIR/history.zsh" ] && source "$ZSH_CONFIG_DIR/history.zsh"
    
    # Zsh options
    [ -f "$ZSH_CONFIG_DIR/options.zsh" ] && source "$ZSH_CONFIG_DIR/options.zsh"
    
    # Environment variables and PATH exports
    [ -f "$ZSH_CONFIG_DIR/exports.zsh" ] && source "$ZSH_CONFIG_DIR/exports.zsh"
    
    # Aliases
    [ -f "$ZSH_CONFIG_DIR/aliases.zsh" ] && source "$ZSH_CONFIG_DIR/aliases.zsh"
    
    # Functions
    [ -f "$ZSH_CONFIG_DIR/functions.zsh" ] && source "$ZSH_CONFIG_DIR/functions.zsh"
    
    # Tool-specific configurations
    [ -f "$ZSH_CONFIG_DIR/tools.zsh" ] && source "$ZSH_CONFIG_DIR/tools.zsh"
fi
