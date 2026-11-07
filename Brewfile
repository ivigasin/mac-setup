# Homebrew packages for Mac Setup
# Installed by `mise run brew-bundle` (part of ./setup.sh)
# Language runtimes (node, python, go, java) are managed by mise — see .config/mise/config.toml

# CLI tools
brew "eza"                # Modern ls replacement
brew "bat"                # Modern cat replacement
brew "ripgrep"            # Better grep (rg)
brew "fzf"                # Fuzzy finder
brew "zoxide"             # Smart cd
brew "fd"                 # Better find (used by fzf)
brew "neovim"             # Modern vim editor
brew "midnight-commander" # Midnight Commander (file manager)
brew "gnupg"              # GPG for commit signing
brew "pinentry-mac"       # macOS pinentry for GPG passphrase prompts
brew "gh"                 # GitHub CLI
brew "git-secrets"        # Prevent committing secrets/credentials
brew "uv"                 # Python package/venv manager (also backs mise python)
brew "pipx"               # Python application installer

# Terminal & editors (skipped when the app was installed outside Homebrew)
cask "ghostty" unless File.exist?("/Applications/Ghostty.app")
cask "visual-studio-code" unless File.exist?("/Applications/Visual Studio Code.app")
# Claude Code is handled by `mise run claude` (detects native/brew installs)

# Fonts
cask "font-meslo-lg-nerd-font" # Required for Agnoster theme
cask "font-hack-nerd-font"     # Popular programming font
