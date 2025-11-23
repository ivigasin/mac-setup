#!/bin/bash

# Mac Setup Dependencies Installation Script
# Installs all required tools and dependencies
#
# Copyright © 2024 Igor Vigasin
# Created by Igor Vigasin

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Mac CLI Setup - Dependency Installation${NC}"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error: This script is designed for macOS only.${NC}"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to show what will be installed and enabled
show_installation_summary() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}What Will Be Installed & Enabled${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${YELLOW}📦 Package Manager:${NC}"
    echo -e "  ${GREEN}✓${NC} Homebrew (if not installed)"
    echo ""
    
    echo -e "${YELLOW}🎨 Shell Framework:${NC}"
    echo -e "  ${GREEN}✓${NC} Oh My Zsh"
    echo ""
    
    echo -e "${YELLOW}🔌 Zsh Plugins:${NC}"
    echo -e "  ${GREEN}✓${NC} zsh-autosuggestions (command suggestions)"
    echo -e "  ${GREEN}✓${NC} zsh-syntax-highlighting (syntax highlighting)"
    echo -e "  ${GREEN}✓${NC} zsh-history-substring-search (history search)"
    echo ""
    
    echo -e "${YELLOW}🛠️  CLI Tools (via Homebrew):${NC}"
    echo -e "  ${GREEN}✓${NC} eza (modern ls replacement)"
    echo -e "  ${GREEN}✓${NC} bat (modern cat replacement)"
    echo -e "  ${GREEN}✓${NC} ripgrep (rg - fast grep)"
    echo -e "  ${GREEN}✓${NC} fzf (fuzzy finder)"
    echo -e "  ${GREEN}✓${NC} zoxide (smart cd)"
    echo -e "  ${GREEN}✓${NC} fd (fast find)"
    echo -e "  ${GREEN}✓${NC} neovim (modern vim editor)"
    echo ""
    
    echo -e "${YELLOW}💻 Development Tools:${NC}"
    echo -e "  ${GREEN}✓${NC} NVM (Node Version Manager)"
    echo -e "  ${GREEN}✓${NC} Go (Go programming language)"
    echo -e "  ${GREEN}✓${NC} Python 3.11"
    echo -e "  ${GREEN}✓${NC} OpenJDK (Java Development Kit)"
    echo -e "  ${GREEN}✓${NC} pipx (Python application installer)"
    echo ""
    
    echo -e "${YELLOW}⚙️  Git Configuration:${NC}"
    echo -e "  ${GREEN}✓${NC} Default branch: main"
    echo -e "  ${GREEN}✓${NC} Pull strategy: rebase"
    echo -e "  ${GREEN}✓${NC} GPG signing: enabled"
    echo -e "  ${GREEN}✓${NC} Color output: configured"
    echo -e "  ${GREEN}✓${NC} Credential helper: macOS Keychain"
    echo -e "  ${GREEN}✓${NC} Git aliases: st, ci, co, br, df, dc, lg, lp, lol, lola, grog, etc."
    echo ""
    
    echo -e "${YELLOW}🔧 Tool Configurations:${NC}"
    echo -e "  ${GREEN}✓${NC} FZF setup and key bindings"
    echo -e "  ${GREEN}✓${NC} zoxide initialization"
    echo ""
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to install Homebrew if not present
install_homebrew() {
    if ! command_exists brew; then
        echo -e "${YELLOW}📦 Installing Homebrew...${NC}"
        echo -e "${BLUE}   This may take a few minutes...${NC}"
        
        # Install Homebrew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            echo -e "${RED}❌ Homebrew installation failed${NC}"
            echo -e "${YELLOW}   Please install Homebrew manually:${NC}"
            echo -e "${YELLOW}   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${NC}"
            exit 1
        }
        
        # Detect architecture and add Homebrew to PATH
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            # Apple Silicon Mac
            echo -e "${BLUE}   Adding Homebrew to PATH for Apple Silicon...${NC}"
            eval "$(/opt/homebrew/bin/brew shellenv)"
            # Add to shell profile for persistence
            if ! grep -q "/opt/homebrew/bin" "$HOME/.zprofile" 2>/dev/null; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
            fi
        elif [[ -f "/usr/local/bin/brew" ]]; then
            # Intel Mac
            echo -e "${BLUE}   Adding Homebrew to PATH for Intel Mac...${NC}"
            eval "$(/usr/local/bin/brew shellenv)"
            # Add to shell profile for persistence
            if ! grep -q "/usr/local/bin" "$HOME/.zprofile" 2>/dev/null; then
                echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
            fi
        fi
        
        # Verify installation
        if command_exists brew; then
            echo -e "${GREEN}✅ Homebrew installed successfully${NC}"
            brew --version
        else
            echo -e "${RED}❌ Homebrew installation completed but brew command not found${NC}"
            echo -e "${YELLOW}   Please restart your terminal and run this script again${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ Homebrew already installed${NC}"
        brew --version
        
        # Ensure Homebrew is in PATH (in case it wasn't sourced)
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    
    # Update Homebrew
    echo -e "${YELLOW}🔄 Updating Homebrew...${NC}"
    brew update || echo -e "${YELLOW}⚠️  Homebrew update failed (this is usually okay)${NC}"
}

# Function to install Oh My Zsh if not present
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo -e "${YELLOW}📦 Installing Oh My Zsh...${NC}"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo -e "${GREEN}✅ Oh My Zsh already installed${NC}"
    fi
}

# Function to install Oh My Zsh plugins
install_zsh_plugins() {
    echo -e "${YELLOW}🔌 Installing Oh My Zsh plugins...${NC}"
    
    local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    
    # zsh-autosuggestions
    if [ ! -d "$plugins_dir/zsh-autosuggestions" ]; then
        echo "  Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
    else
        echo -e "  ${GREEN}✅ zsh-autosuggestions already installed${NC}"
    fi
    
    # zsh-syntax-highlighting
    if [ ! -d "$plugins_dir/zsh-syntax-highlighting" ]; then
        echo "  Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting"
    else
        echo -e "  ${GREEN}✅ zsh-syntax-highlighting already installed${NC}"
    fi
    
    # history-substring-search
    if [ ! -d "$plugins_dir/zsh-history-substring-search" ]; then
        echo "  Installing history-substring-search..."
        git clone https://github.com/zsh-users/zsh-history-substring-search "$plugins_dir/zsh-history-substring-search"
    else
        echo -e "  ${GREEN}✅ history-substring-search already installed${NC}"
    fi
}

# Function to install tools via Homebrew
install_brew_packages() {
    echo -e "${YELLOW}📦 Installing Homebrew packages...${NC}"
    
    local packages=(
        "eza"           # Modern ls replacement
        "bat"           # Modern cat replacement
        "ripgrep"       # Better grep (rg)
        "fzf"           # Fuzzy finder
        "zoxide"        # Smart cd
        "fd"            # Better find (used by fzf)
        "neovim"        # Modern vim editor
        "go"            # Go programming language
        "python@3.11"   # Python
        "openjdk"       # Java
    )
    
    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            echo -e "  ${GREEN}✅ $package already installed${NC}"
        else
            echo "  Installing $package..."
            brew install "$package" || echo -e "  ${RED}⚠️  Failed to install $package${NC}"
        fi
    done
}

# Function to install NVM
install_nvm() {
    if [ ! -d "$HOME/.nvm" ]; then
        echo -e "${YELLOW}📦 Installing NVM (Node Version Manager)...${NC}"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        
        # Source NVM for current session
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        echo -e "${GREEN}✅ NVM installed${NC}"
        echo -e "${YELLOW}   Note: You may want to install Node.js with: nvm install --lts${NC}"
    else
        echo -e "${GREEN}✅ NVM already installed${NC}"
    fi
}

# Function to install pipx
install_pipx() {
    if ! command_exists pipx; then
        echo -e "${YELLOW}📦 Installing pipx...${NC}"
        python3 -m pip install --user pipx
        python3 -m pipx ensurepath
        echo -e "${GREEN}✅ pipx installed${NC}"
    else
        echo -e "${GREEN}✅ pipx already installed${NC}"
    fi
}

# Function to setup FZF
setup_fzf() {
    if command_exists fzf && [ ! -f "$HOME/.fzf.zsh" ]; then
        echo -e "${YELLOW}⚙️  Setting up FZF...${NC}"
        "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
        echo -e "${GREEN}✅ FZF configured${NC}"
    elif [ -f "$HOME/.fzf.zsh" ]; then
        echo -e "${GREEN}✅ FZF already configured${NC}"
    fi
}

# Function to configure Git
configure_git() {
    echo -e "${YELLOW}⚙️  Configuring Git...${NC}"
    
    if ! command_exists git; then
        echo -e "${RED}⚠️  Git is not installed. Skipping Git configuration.${NC}"
        return
    fi
    
    # Configure common Git settings
    echo "  Setting up Git defaults..."
    
    # Set default branch name to main
    git config --global init.defaultBranch main 2>/dev/null || true
    
    # Use rebase for pulls
    git config --global pull.rebase true 2>/dev/null || true
    
    # Configure user name and email
    # Use environment variables if provided (from wizard), otherwise prompt or use existing
    if [ -n "$GIT_USER_NAME" ]; then
        git config --global user.name "$GIT_USER_NAME"
        echo -e "  ${GREEN}✅ Git user name set to: $GIT_USER_NAME${NC}"
    elif [ -z "$(git config --global user.name)" ]; then
        echo ""
        echo -e "${BLUE}   Git user name is not configured.${NC}"
        read -p "   Enter your Git user name (or press Enter to skip): " git_name
        if [ -n "$git_name" ]; then
            git config --global user.name "$git_name"
            echo -e "${GREEN}   ✅ Git user name set to: $git_name${NC}"
        fi
    else
        echo -e "  ${GREEN}✅ Git user name already configured: $(git config --global user.name)${NC}"
    fi
    
    if [ -n "$GIT_USER_EMAIL" ]; then
        git config --global user.email "$GIT_USER_EMAIL"
        echo -e "  ${GREEN}✅ Git user email set to: $GIT_USER_EMAIL${NC}"
    elif [ -z "$(git config --global user.email)" ]; then
        echo ""
        echo -e "${BLUE}   Git user email is not configured.${NC}"
        read -p "   Enter your Git user email (or press Enter to skip): " git_email
        if [ -n "$git_email" ]; then
            git config --global user.email "$git_email"
            echo -e "${GREEN}   ✅ Git user email set to: $git_email${NC}"
        fi
    else
        echo -e "  ${GREEN}✅ Git user email already configured: $(git config --global user.email)${NC}"
    fi
    
    # Configure GPG signing
    echo "  Configuring GPG signing..."
    git config --global commit.gpgsign true 2>/dev/null || true
    
    # Use environment variable for signing key if provided, otherwise use default
    if [ -n "$GIT_SIGNING_KEY" ]; then
        git config --global user.signingkey "$GIT_SIGNING_KEY" 2>/dev/null || true
        echo -e "  ${GREEN}✅ GPG signing key set to: $GIT_SIGNING_KEY${NC}"
    else
        git config --global user.signingkey 1CF7369F7EEAAF61 2>/dev/null || true
    fi
    
    # Set up credential helper for macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        git config --global credential.helper osxkeychain 2>/dev/null || true
    fi
    
    # Configure color settings
    echo "  Configuring color settings..."
    git config --global color.ui true 2>/dev/null || true
    git config --global color.branch.current "yellow reverse" 2>/dev/null || true
    git config --global color.branch.local "yellow" 2>/dev/null || true
    git config --global color.branch.remote "green" 2>/dev/null || true
    git config --global color.diff.meta "yellow bold" 2>/dev/null || true
    git config --global color.diff.frag "magenta bold" 2>/dev/null || true
    git config --global color.diff.old "red bold" 2>/dev/null || true
    git config --global color.diff.new "green bold" 2>/dev/null || true
    git config --global color.status.added "yellow" 2>/dev/null || true
    git config --global color.status.changed "green" 2>/dev/null || true
    git config --global color.status.untracked "cyan" 2>/dev/null || true
    
    # Set up aliases
    echo "  Configuring Git aliases..."
    git config --global alias.st "status" 2>/dev/null || true
    git config --global alias.ci "commit" 2>/dev/null || true
    git config --global alias.br "branch" 2>/dev/null || true
    git config --global alias.co "checkout" 2>/dev/null || true
    git config --global alias.df "diff --color" 2>/dev/null || true
    git config --global alias.dc "diff --color --cached" 2>/dev/null || true
    git config --global alias.lg "log -p --color" 2>/dev/null || true
    git config --global alias.who "shortlog -s --" 2>/dev/null || true
    git config --global alias.lp "log --graph --pretty=format:'%Cred%h%Creset — %s %Cgreen(%cr)%Creset %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative --color" 2>/dev/null || true
    git config --global alias.undo "reset --hard" 2>/dev/null || true
    git config --global alias.lol "log --graph --decorate --pretty=oneline --abbrev-commit" 2>/dev/null || true
    git config --global alias.lola "log --graph --decorate --pretty=oneline --abbrev-commit --all" 2>/dev/null || true
    git config --global alias.ls "ls-files" 2>/dev/null || true
    git config --global alias.git "!f() { git \"\$@\"; }; f" 2>/dev/null || true
    git config --global alias.grog "log --graph --abbrev-commit --decorate --all --format=format:\"%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(dim white) - %an%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset)\"" 2>/dev/null || true
    git config --global alias.unlock "!rm -f .git/index.lock" 2>/dev/null || true
    
    echo -e "${GREEN}✅ Git configured${NC}"
}

# Main installation flow
main() {
    # Show what will be installed
    show_installation_summary
    
    # Ask for confirmation
    read -p "$(echo -e "${YELLOW}Do you want to proceed with the installation? [Y/n]:${NC} ")" -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
        echo -e "${YELLOW}Installation cancelled.${NC}"
        exit 0
    fi
    echo ""
    
    echo -e "${BLUE}Step 1: Installing Homebrew${NC}"
    install_homebrew
    echo ""
    
    echo -e "${BLUE}Step 2: Installing Oh My Zsh${NC}"
    install_oh_my_zsh
    echo ""
    
    echo -e "${BLUE}Step 3: Installing Oh My Zsh plugins${NC}"
    install_zsh_plugins
    echo ""
    
    echo -e "${BLUE}Step 4: Installing Homebrew packages${NC}"
    install_brew_packages
    echo ""
    
    echo -e "${BLUE}Step 5: Installing NVM${NC}"
    install_nvm
    echo ""
    
    echo -e "${BLUE}Step 6: Installing pipx${NC}"
    install_pipx
    echo ""
    
    echo -e "${BLUE}Step 7: Setting up FZF${NC}"
    setup_fzf
    echo ""
    
    echo -e "${BLUE}Step 8: Configuring Git${NC}"
    configure_git
    echo ""
    
    echo -e "${GREEN}🎉 Setup complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Test the installation by running: ./test.sh"
    echo "  2. Restart your terminal or run: source ~/.zshrc"
    echo "  3. Install Node.js LTS: nvm install --lts"
    echo "  4. Install any additional tools you need"
    echo ""
}

# Run main function
main
