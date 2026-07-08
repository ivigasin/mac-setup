#!/bin/bash

# Mac Setup - All-in-One Installation Script
# Automated setup for configuring a new Mac with CLI tools and zsh configuration
#
# Copyright © 2025 Igor Vigasin
# Created by Igor Vigasin

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

# Installation flags
INTERACTIVE_MODE=true
INSTALL_ZSH_CONFIG=true
INSTALL_DEPENDENCIES=true
INSTALL_NODE_LTS=false
RUN_TESTS=true

# Git configuration variables
GIT_NAME=""
GIT_EMAIL=""
GIT_SIGNING_KEY=""

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if file exists
file_exists() {
    [ -f "$1" ]
}

# Function to check if directory exists
dir_exists() {
    [ -d "$1" ]
}

# Function to prompt for input with default value
prompt_with_default() {
    local prompt_text="$1"
    local default_value="$2"
    local var_name="$3"

    if [ -n "$default_value" ]; then
        read -p "$(echo -e "${CYAN}$prompt_text${NC} ${YELLOW}[$default_value]:${NC} ")" input
        eval "$var_name=\"\${input:-$default_value}\""
    else
        read -p "$(echo -e "${CYAN}$prompt_text:${NC} ")" input
        eval "$var_name=\"$input\""
    fi
}

# Function to prompt for yes/no
prompt_yes_no() {
    local prompt_text="$1"
    local default_value="${2:-y}"
    local var_name="$3"

    local default_display="Y/n"
    if [[ "$default_value" == "n" ]]; then
        default_display="y/N"
    fi

    while true; do
        read -p "$(echo -e "${CYAN}$prompt_text${NC} ${YELLOW}[$default_display]:${NC} ")" yn
        yn=${yn:-$default_value}
        case $yn in
            [Yy]* ) eval "$var_name=\"y\""; break;;
            [Nn]* ) eval "$var_name=\"n\""; break;;
            * ) echo -e "${YELLOW}Please answer yes or no.${NC}";;
        esac
    done
}

# =============================================================================
# DISPLAY FUNCTIONS
# =============================================================================

show_banner() {
    clear
    echo -e "${BLUE}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║           🚀 Mac Setup - All-in-One                       ║"
    echo "║                                                           ║"
    echo "║     Automated Mac CLI Setup & Configuration               ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

show_installation_summary() {
    local install_zsh="$1"
    local install_deps="$2"

    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}What Will Be Installed & Enabled${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    if [[ "$install_zsh" == "true" ]] || [[ "$install_zsh" == "y" ]]; then
        echo -e "${CYAN}📁 Zsh Configuration Files:${NC}"
        echo -e "  ${GREEN}✓${NC} ~/.zshrc (main configuration file)"
        echo -e "  ${GREEN}✓${NC} ~/.zsh/config.zsh (Oh My Zsh config)"
        echo -e "  ${GREEN}✓${NC} ~/.zsh/exports.zsh (environment variables)"
        echo -e "  ${GREEN}✓${NC} ~/.zsh/aliases.zsh (command aliases)"
        echo -e "  ${GREEN}✓${NC} ~/.zsh/functions.zsh (custom functions)"
        echo -e "  ${GREEN}✓${NC} ~/.zsh/history.zsh (history settings)"
        echo -e "  ${GREEN}✓${NC} ~/.zsh/options.zsh (zsh options)"
        echo -e "  ${GREEN}✓${NC} ~/.zsh/tools.zsh (tool configurations)"
        echo ""
    fi

    if [[ "$install_deps" == "true" ]] || [[ "$install_deps" == "y" ]]; then
        echo -e "${CYAN}📦 Package Manager:${NC}"
        echo -e "  ${GREEN}✓${NC} Homebrew (if not installed)"
        echo ""

        echo -e "${CYAN}🎨 Shell Framework:${NC}"
        echo -e "  ${GREEN}✓${NC} Oh My Zsh"
        echo ""

        echo -e "${CYAN}🔌 Zsh Plugins:${NC}"
        echo -e "  ${GREEN}✓${NC} zsh-autosuggestions (command suggestions)"
        echo -e "  ${GREEN}✓${NC} zsh-syntax-highlighting (syntax highlighting)"
        echo -e "  ${GREEN}✓${NC} zsh-history-substring-search (history search)"
        echo -e "  ${GREEN}✓${NC} git (Git aliases and functions)"
        echo -e "  ${GREEN}✓${NC} fzf (fuzzy finder integration)"
        echo ""

        echo -e "${CYAN}🔤 Fonts:${NC}"
        echo -e "  ${GREEN}✓${NC} MesloLGS NF (required for Agnoster theme)"
        echo -e "  ${GREEN}✓${NC} Hack Nerd Font"
        echo ""

        echo -e "${CYAN}🖥️  Terminal Emulators:${NC}"
        echo -e "  ${GREEN}✓${NC} Ghostty (installed + Nerd Font + iTerm2-style keybindings)"
        echo ""

        echo -e "${CYAN}🛠️  CLI Tools (via Homebrew):${NC}"
        echo -e "  ${GREEN}✓${NC} eza (modern ls replacement)"
        echo -e "  ${GREEN}✓${NC} bat (modern cat replacement)"
        echo -e "  ${GREEN}✓${NC} ripgrep (rg - fast grep)"
        echo -e "  ${GREEN}✓${NC} fzf (fuzzy finder)"
        echo -e "  ${GREEN}✓${NC} zoxide (smart cd)"
        echo -e "  ${GREEN}✓${NC} fd (fast find)"
        echo -e "  ${GREEN}✓${NC} neovim (modern vim editor)"
        echo -e "  ${GREEN}✓${NC} mc (Midnight Commander file manager)"
        echo -e "  ${GREEN}✓${NC} gnupg (GPG for commit signing)"
        echo -e "  ${GREEN}✓${NC} pinentry-mac (GPG passphrase prompts)"
        echo -e "  ${GREEN}✓${NC} gh (GitHub CLI)"
        echo -e "  ${GREEN}✓${NC} git-secrets (prevent committing secrets)"
        echo ""

        echo -e "${CYAN}💻 Development Tools:${NC}"
        echo -e "  ${GREEN}✓${NC} NVM (Node Version Manager)"
        echo -e "  ${GREEN}✓${NC} Go (Go programming language)"
        echo -e "  ${GREEN}✓${NC} Python 3.11"
        echo -e "  ${GREEN}✓${NC} OpenJDK (Java Development Kit)"
        echo -e "  ${GREEN}✓${NC} pipx (Python application installer)"
        echo -e "  ${GREEN}✓${NC} Claude Code CLI (install + browser auth)"
        echo ""

        echo -e "${CYAN}⚙️  Git Configuration:${NC}"
        echo -e "  ${GREEN}✓${NC} Default branch: main"
        echo -e "  ${GREEN}✓${NC} Pull strategy: rebase"
        echo -e "  ${GREEN}✓${NC} GPG signing: enabled"
        echo -e "  ${GREEN}✓${NC} Color output: configured"
        echo -e "  ${GREEN}✓${NC} Credential helper: macOS Keychain"
        echo -e "  ${GREEN}✓${NC} Git aliases: st, ci, co, br, df, dc, lg, lp, lol, lola, grog, etc."
        echo ""

        echo -e "${CYAN}🔧 Tool Configurations:${NC}"
        echo -e "  ${GREEN}✓${NC} FZF setup and key bindings"
        echo -e "  ${GREEN}✓${NC} zoxide initialization"
        echo ""
    fi

    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# =============================================================================
# ZSH CONFIGURATION INSTALLATION (from install.sh)
# =============================================================================

install_zsh_configuration() {
    echo -e "${BOLD}${BLUE}📁 Installing Zsh Configuration Files...${NC}"
    echo ""

    # Create .zsh directory if it doesn't exist
    echo -e "${YELLOW}📁 Creating ~/.zsh directory...${NC}"
    mkdir -p "$HOME_DIR/.zsh"

    # Copy zsh configuration files
    if [ -d "$SCRIPT_DIR/.zsh" ] && [ "$(ls -A "$SCRIPT_DIR/.zsh" 2>/dev/null)" ]; then
        echo -e "${YELLOW}📋 Copying zsh configuration files...${NC}"
        cp -r "$SCRIPT_DIR/.zsh/"* "$HOME_DIR/.zsh/"
        echo -e "${GREEN}✅ Zsh configuration files copied${NC}"
    else
        echo -e "${RED}⚠️  Warning: .zsh directory not found or empty in $SCRIPT_DIR${NC}"
        echo -e "${YELLOW}   Skipping zsh configuration file copy${NC}"
    fi

    # Backup existing .zshrc if it exists
    if [ -f "$HOME_DIR/.zshrc" ]; then
        echo -e "${YELLOW}💾 Backing up existing .zshrc to .zshrc.backup...${NC}"
        cp "$HOME_DIR/.zshrc" "$HOME_DIR/.zshrc.backup"
    fi

    # Copy .zshrc
    echo -e "${YELLOW}📝 Installing .zshrc...${NC}"
    cp "$SCRIPT_DIR/.zshrc" "$HOME_DIR/.zshrc"
    echo -e "${GREEN}✅ .zshrc installed${NC}"

    # Copy neovim configuration
    if [ -d "$SCRIPT_DIR/.config/nvim" ]; then
        echo -e "${YELLOW}📝 Installing Neovim configuration...${NC}"
        mkdir -p "$HOME_DIR/.config/nvim"
        cp -r "$SCRIPT_DIR/.config/nvim/"* "$HOME_DIR/.config/nvim/"
        echo -e "${GREEN}✅ Neovim configuration installed${NC}"
    fi

    echo ""
    echo -e "${GREEN}✅ Zsh configuration installed successfully!${NC}"
    echo ""
}

# =============================================================================
# DEPENDENCY INSTALLATION FUNCTIONS (from setup.sh)
# =============================================================================

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

install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo -e "${YELLOW}📦 Installing Oh My Zsh...${NC}"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo -e "${GREEN}✅ Oh My Zsh installed${NC}"
    else
        echo -e "${GREEN}✅ Oh My Zsh already installed${NC}"
    fi
}

install_zsh_plugins() {
    echo -e "${YELLOW}🔌 Installing Oh My Zsh plugins...${NC}"

    local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"

    # zsh-autosuggestions
    if [ ! -d "$plugins_dir/zsh-autosuggestions" ]; then
        echo "  Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
    else
        echo -e "  ${GREEN}✅ zsh-autosuggestions already installed, updating...${NC}"
        git -C "$plugins_dir/zsh-autosuggestions" pull --quiet || true
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$plugins_dir/zsh-syntax-highlighting" ]; then
        echo "  Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting"
    else
        echo -e "  ${GREEN}✅ zsh-syntax-highlighting already installed, updating...${NC}"
        git -C "$plugins_dir/zsh-syntax-highlighting" pull --quiet || true
    fi

    # history-substring-search
    if [ ! -d "$plugins_dir/zsh-history-substring-search" ]; then
        echo "  Installing history-substring-search..."
        git clone https://github.com/zsh-users/zsh-history-substring-search "$plugins_dir/zsh-history-substring-search"
    else
        echo -e "  ${GREEN}✅ history-substring-search already installed, updating...${NC}"
        git -C "$plugins_dir/zsh-history-substring-search" pull --quiet || true
    fi

    echo -e "${GREEN}✅ Zsh plugins installed${NC}"
}

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
        "mc"            # Midnight Commander (file manager)
        "go"            # Go programming language
        "python@3.11"   # Python
        "openjdk"       # Java
        "gnupg"         # GPG for commit signing
        "pinentry-mac"  # macOS pinentry for GPG passphrase prompts
        "gh"            # GitHub CLI
        "git-secrets"   # Prevent committing secrets/credentials
    )

    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            echo -e "  ${GREEN}✅ $package already installed${NC}"
        else
            echo "  Installing $package..."
            brew install "$package" || echo -e "  ${RED}⚠️  Failed to install $package${NC}"
        fi
    done

    echo -e "${GREEN}✅ Homebrew packages installed${NC}"
}

install_nvm() {
    if [ ! -d "$HOME/.nvm" ]; then
        echo -e "${YELLOW}📦 Installing NVM (Node Version Manager)...${NC}"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

        # Source NVM for current session
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        echo -e "${GREEN}✅ NVM installed${NC}"
    else
        echo -e "${GREEN}✅ NVM already installed${NC}"
    fi
}

install_ghostty_config() {
    echo -e "${YELLOW}👻 Installing Ghostty configuration...${NC}"

    local src="$SCRIPT_DIR/.config/ghostty/config"
    local dest_dir="$HOME_DIR/.config/ghostty"
    local dest="$dest_dir/config"

    if [ ! -f "$src" ]; then
        echo -e "  ${RED}⚠️  ghostty config not found at $src — skipping${NC}"
        return 0
    fi

    mkdir -p "$dest_dir"

    if [ -f "$dest" ] && ! cmp -s "$src" "$dest"; then
        echo -e "  ${YELLOW}💾 Backing up existing config to config.backup${NC}"
        cp "$dest" "$dest.backup"
    fi

    cp "$src" "$dest"
    echo -e "  ${GREEN}✅ Ghostty config installed to $dest${NC}"
    echo -e "  ${CYAN}💡 Reload in Ghostty with Cmd+Shift+, (or restart Ghostty)${NC}"
}

install_fonts() {
    echo -e "${YELLOW}🔤 Installing Nerd Fonts...${NC}"

    local fonts=(
        "font-meslo-lg-nerd-font"   # Required for Agnoster theme
        "font-hack-nerd-font"       # Popular programming font
    )

    for font in "${fonts[@]}"; do
        if brew list --cask "$font" &>/dev/null; then
            echo -e "  ${GREEN}✅ $font already installed${NC}"
        else
            echo "  Installing $font..."
            brew install --cask "$font" || echo -e "  ${RED}⚠️  Failed to install $font${NC}"
        fi
    done

    echo -e "${GREEN}✅ Nerd Fonts installed${NC}"
}

install_ghostty() {
    echo -e "${YELLOW}👻 Installing Ghostty...${NC}"

    if brew list --cask ghostty &>/dev/null; then
        echo -e "  ${GREEN}✅ ghostty already installed (via Homebrew)${NC}"
    elif [ -d "/Applications/Ghostty.app" ]; then
        echo -e "  ${GREEN}✅ ghostty already installed (under /Applications)${NC}"
    else
        echo "  Installing ghostty..."
        brew install --cask ghostty || echo -e "  ${RED}⚠️  Failed to install ghostty${NC}"
    fi

    echo -e "${GREEN}✅ Ghostty installed${NC}"
}

install_pipx() {
    if ! command_exists pipx; then
        echo -e "${YELLOW}📦 Installing pipx...${NC}"
        brew install pipx
        pipx ensurepath
        echo -e "${GREEN}✅ pipx installed${NC}"
    else
        echo -e "${GREEN}✅ pipx already installed${NC}"
    fi
}

setup_fzf() {
    if command_exists fzf && [ ! -f "$HOME/.fzf.zsh" ]; then
        echo -e "${YELLOW}⚙️  Setting up FZF...${NC}"
        "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
        echo -e "${GREEN}✅ FZF configured${NC}"
    elif [ -f "$HOME/.fzf.zsh" ]; then
        echo -e "${GREEN}✅ FZF already configured${NC}"
    fi
}

install_claude_code() {
    echo -e "${YELLOW}📦 Installing Claude Code CLI...${NC}"

    if brew list --cask claude-code &>/dev/null; then
        echo -e "${GREEN}✅ Claude Code CLI already installed (via Homebrew)${NC}"
        command_exists claude && claude --version
    elif command_exists claude; then
        echo -e "${GREEN}✅ Claude Code CLI already installed${NC}"
        claude --version
    else
        echo -e "${YELLOW}   Installing Claude Code via Homebrew...${NC}"
        if brew install --cask claude-code; then
            echo -e "${GREEN}✅ Claude Code CLI installed successfully${NC}"
            command_exists claude && claude --version
        else
            echo -e "${YELLOW}⚠️  Failed to install Claude Code CLI${NC}"
            return
        fi
    fi

    authenticate_claude_code
}

authenticate_claude_code() {
    echo -e "${YELLOW}🔑 Authenticating Claude Code...${NC}"

    # Already authenticated if session file exists
    if [ -f "$HOME/.claude/.credentials.json" ] || [ -f "$HOME/.claude/auth.json" ]; then
        echo -e "${GREEN}✅ Claude Code already authenticated${NC}"
        return
    fi

    if [ "$INTERACTIVE_MODE" = true ]; then
        echo -e "${BLUE}   Starting browser-based authentication...${NC}"
        claude auth login
    elif [ -n "${ANTHROPIC_API_KEY:-}" ]; then
        echo -e "${GREEN}✅ ANTHROPIC_API_KEY is set — Claude Code will use it automatically${NC}"
    else
        echo -e "${YELLOW}⚠️  No authentication configured.${NC}"
        echo -e "${YELLOW}   Run 'claude auth login' after setup, or set ANTHROPIC_API_KEY.${NC}"
    fi
}

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
    if [ -n "$GIT_NAME" ]; then
        git config --global user.name "$GIT_NAME"
        echo -e "  ${GREEN}✅ Git user name set to: $GIT_NAME${NC}"
    elif [ -z "$(git config --global user.name)" ]; then
        if [ "$INTERACTIVE_MODE" = true ]; then
            echo ""
            echo -e "${BLUE}   Git user name is not configured.${NC}"
            read -p "   Enter your Git user name (or press Enter to skip): " git_name
            if [ -n "$git_name" ]; then
                git config --global user.name "$git_name"
                echo -e "${GREEN}   ✅ Git user name set to: $git_name${NC}"
            fi
        fi
    else
        echo -e "  ${GREEN}✅ Git user name already configured: $(git config --global user.name)${NC}"
    fi

    if [ -n "$GIT_EMAIL" ]; then
        git config --global user.email "$GIT_EMAIL"
        echo -e "  ${GREEN}✅ Git user email set to: $GIT_EMAIL${NC}"
    elif [ -z "$(git config --global user.email)" ]; then
        if [ "$INTERACTIVE_MODE" = true ]; then
            echo ""
            echo -e "${BLUE}   Git user email is not configured.${NC}"
            read -p "   Enter your Git user email (or press Enter to skip): " git_email
            if [ -n "$git_email" ]; then
                git config --global user.email "$git_email"
                echo -e "${GREEN}   ✅ Git user email set to: $git_email${NC}"
            fi
        fi
    else
        echo -e "  ${GREEN}✅ Git user email already configured: $(git config --global user.email)${NC}"
    fi

    # Configure GPG signing
    # Only enable signing when a key is provided AND its secret key is actually
    # present in the keyring — otherwise every commit fails with "No secret key".
    echo "  Configuring GPG signing..."

    # Prefer explicit env var; fall back to any existing configured key.
    local signing_key="${GIT_SIGNING_KEY:-$(git config --global user.signingkey 2>/dev/null || echo "")}"

    if [ -n "$signing_key" ] && command_exists gpg && gpg --list-secret-keys "$signing_key" &>/dev/null; then
        git config --global user.signingkey "$signing_key" 2>/dev/null || true
        git config --global commit.gpgsign true 2>/dev/null || true
        echo -e "  ${GREEN}✅ GPG signing enabled with key: $signing_key${NC}"
    else
        git config --global commit.gpgsign false 2>/dev/null || true
        if [ -n "$signing_key" ]; then
            echo -e "  ${YELLOW}⚠️  Signing key '$signing_key' has no secret key in this keyring — commit signing left disabled.${NC}"
        else
            echo -e "  ${YELLOW}⚠️  No GPG signing key available — commit signing left disabled.${NC}"
            echo -e "     ${YELLOW}Set GIT_USER_SIGNING_KEY (and import the key) to enable it.${NC}"
        fi
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

    # Configure git-secrets to scan for credentials before committing
    if command_exists git-secrets || command_exists git\ secrets || brew list git-secrets &>/dev/null; then
        echo "  Configuring git-secrets..."
        # Install hooks into a template dir so every newly cloned/init'd repo gets them
        local git_template_dir="$HOME/.git-templates/git-secrets"
        mkdir -p "$git_template_dir"
        git secrets --install -f "$git_template_dir" &>/dev/null || true
        git config --global init.templateDir "$git_template_dir" 2>/dev/null || true
        # Register common AWS credential patterns globally
        git secrets --register-aws --global &>/dev/null || true
        echo -e "  ${GREEN}✅ git-secrets configured (AWS patterns + repo template hooks)${NC}"
    fi

    echo -e "${GREEN}✅ Git configured${NC}"
}

# =============================================================================
# INTERACTIVE WIZARD FUNCTIONS
# =============================================================================

collect_user_info() {
    echo -e "${BOLD}${BLUE}Step 1: User Information${NC}"
    echo -e "${BLUE}─────────────────────────────────────────────────────${NC}"
    echo ""

    # Check if git is already configured
    if command -v git &> /dev/null; then
        EXISTING_GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
        EXISTING_GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
        EXISTING_SIGNING_KEY=$(git config --global user.signingkey 2>/dev/null || echo "")

        if [ -n "$EXISTING_GIT_NAME" ]; then
            prompt_with_default "Git user name" "$EXISTING_GIT_NAME" "GIT_NAME"
        else
            prompt_with_default "Git user name" "" "GIT_NAME"
        fi

        if [ -n "$EXISTING_GIT_EMAIL" ]; then
            prompt_with_default "Git user email" "$EXISTING_GIT_EMAIL" "GIT_EMAIL"
        else
            prompt_with_default "Git user email" "" "GIT_EMAIL"
        fi

        if [ -n "$EXISTING_SIGNING_KEY" ]; then
            prompt_with_default "GPG signing key" "$EXISTING_SIGNING_KEY" "GIT_SIGNING_KEY"
        else
            prompt_with_default "GPG signing key (or press Enter to skip)" "1CF7369F7EEAAF61" "GIT_SIGNING_KEY"
        fi
    else
        echo -e "${YELLOW}⚠️  Git is not installed. You can configure it later.${NC}"
        prompt_with_default "Git user name (optional)" "" "GIT_NAME"
        prompt_with_default "Git user email (optional)" "" "GIT_EMAIL"
        prompt_with_default "GPG signing key (optional)" "1CF7369F7EEAAF61" "GIT_SIGNING_KEY"
    fi
}

collect_installation_options() {
    echo ""
    echo -e "${BOLD}${BLUE}Step 2: Installation Options${NC}"
    echo -e "${BLUE}─────────────────────────────────────────────────────${NC}"
    echo ""

    prompt_yes_no "Install zsh configuration files?" "y" "INSTALL_ZSH_CONFIG"
    prompt_yes_no "Install all dependencies (Homebrew, tools, etc.)?" "y" "INSTALL_DEPENDENCIES"

    if [[ "$INSTALL_DEPENDENCIES" == "y" ]]; then
        prompt_yes_no "Install Node.js LTS after setup?" "n" "INSTALL_NODE_LTS"
    fi

    prompt_yes_no "Run tests after installation?" "y" "RUN_TESTS"
}

show_setup_summary() {
    echo ""
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${GREEN}Setup Summary${NC}"
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Git Configuration:${NC}"
    if [ -n "$GIT_NAME" ]; then
        echo -e "  ${GREEN}✓${NC} Name: $GIT_NAME"
    else
        echo -e "  ${YELLOW}○${NC} Name: (not set)"
    fi
    if [ -n "$GIT_EMAIL" ]; then
        echo -e "  ${GREEN}✓${NC} Email: $GIT_EMAIL"
    else
        echo -e "  ${YELLOW}○${NC} Email: (not set)"
    fi
    if [ -n "$GIT_SIGNING_KEY" ]; then
        echo -e "  ${GREEN}✓${NC} GPG Key: $GIT_SIGNING_KEY"
    else
        echo -e "  ${YELLOW}○${NC} GPG Key: (not set)"
    fi
    echo ""
    echo -e "${CYAN}Installation Steps:${NC}"
    if [[ "$INSTALL_ZSH_CONFIG" == "y" ]]; then
        echo -e "  ${GREEN}✓${NC} Install zsh configuration"
    else
        echo -e "  ${RED}✗${NC} Skip zsh configuration"
    fi
    if [[ "$INSTALL_DEPENDENCIES" == "y" ]]; then
        echo -e "  ${GREEN}✓${NC} Install dependencies"
        if [[ "$INSTALL_NODE_LTS" == "y" ]]; then
            echo -e "    ${GREEN}→${NC} Install Node.js LTS"
        fi
    else
        echo -e "  ${RED}✗${NC} Skip dependencies"
    fi
    if [[ "$RUN_TESTS" == "y" ]]; then
        echo -e "  ${GREEN}✓${NC} Run tests"
    else
        echo -e "  ${RED}✗${NC} Skip tests"
    fi
    echo ""
}

# =============================================================================
# MAIN EXECUTION FLOW
# =============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --non-interactive)
                INTERACTIVE_MODE=false
                shift
                ;;
            --skip-zsh)
                INSTALL_ZSH_CONFIG=false
                shift
                ;;
            --skip-deps)
                INSTALL_DEPENDENCIES=false
                shift
                ;;
            --install-node)
                INSTALL_NODE_LTS=true
                shift
                ;;
            --skip-tests)
                RUN_TESTS=false
                shift
                ;;
            --help|-h)
                echo "Mac Setup - All-in-One Installation Script"
                echo ""
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --non-interactive    Run in non-interactive mode (no prompts)"
                echo "  --skip-zsh          Skip zsh configuration installation"
                echo "  --skip-deps         Skip dependency installation"
                echo "  --install-node      Install Node.js LTS"
                echo "  --skip-tests        Skip running tests"
                echo "  -h, --help          Show this help message"
                echo ""
                echo "Environment Variables:"
                echo "  GIT_USER_NAME        Set Git user name"
                echo "  GIT_USER_EMAIL       Set Git user email"
                echo "  GIT_USER_SIGNING_KEY Set GPG signing key"
                echo "  ANTHROPIC_API_KEY    Authenticate Claude Code (skips browser auth)"
                echo ""
                echo "Examples:"
                echo "  $0                                    # Interactive mode (recommended)"
                echo "  $0 --non-interactive                  # Non-interactive with all defaults"
                echo "  $0 --non-interactive --install-node   # Install everything including Node.js"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

main() {
    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}❌ Error: This script is designed for macOS only.${NC}"
        exit 1
    fi

    # Parse command line arguments
    parse_arguments "$@"

    # Show banner if interactive
    if [ "$INTERACTIVE_MODE" = true ]; then
        show_banner
    else
        echo -e "${BLUE}🚀 Mac Setup - Running in non-interactive mode${NC}"
        echo ""
    fi

    # Collect user information in interactive mode
    if [ "$INTERACTIVE_MODE" = true ]; then
        collect_user_info
        collect_installation_options
        show_installation_summary "$INSTALL_ZSH_CONFIG" "$INSTALL_DEPENDENCIES"
        show_setup_summary

        # Confirmation
        prompt_yes_no "Proceed with installation?" "y" "CONFIRM"

        if [[ "$CONFIRM" != "y" ]]; then
            echo -e "${YELLOW}Installation cancelled.${NC}"
            exit 0
        fi
    else
        # Use environment variables in non-interactive mode
        GIT_NAME="${GIT_USER_NAME:-}"
        GIT_EMAIL="${GIT_USER_EMAIL:-}"
        GIT_SIGNING_KEY="${GIT_USER_SIGNING_KEY:-}"

        show_installation_summary "$INSTALL_ZSH_CONFIG" "$INSTALL_DEPENDENCIES"
    fi

    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}Starting Installation...${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    # Step 1-2: Install shell framework first so our config overwrites it
    if [[ "$INSTALL_DEPENDENCIES" == "y" ]] || [[ "$INSTALL_DEPENDENCIES" == "true" ]]; then
        echo -e "${BOLD}${BLUE}Step 1: Installing Homebrew${NC}"
        echo ""
        install_homebrew
        echo ""

        echo -e "${BOLD}${BLUE}Step 2: Installing Oh My Zsh${NC}"
        echo ""
        install_oh_my_zsh
        echo ""

        echo -e "${BOLD}${BLUE}Step 3: Installing Zsh Plugins${NC}"
        echo ""
        install_zsh_plugins
        echo ""
    fi

    # Step 4: Install zsh configuration (after Oh My Zsh so our .zshrc wins)
    if [[ "$INSTALL_ZSH_CONFIG" == "y" ]] || [[ "$INSTALL_ZSH_CONFIG" == "true" ]]; then
        echo -e "${BOLD}${BLUE}Step 4: Installing Zsh Configuration${NC}"
        echo ""
        install_zsh_configuration
        echo ""
    fi

    if [[ "$INSTALL_DEPENDENCIES" == "y" ]] || [[ "$INSTALL_DEPENDENCIES" == "true" ]]; then
        echo -e "${BOLD}${BLUE}Step 5: Installing Homebrew Packages${NC}"
        echo ""
        install_brew_packages
        echo ""

        echo -e "${BOLD}${BLUE}Step 6: Installing Fonts${NC}"
        echo ""
        install_fonts
        echo ""

        echo -e "${BOLD}${BLUE}Step 6b: Installing Ghostty${NC}"
        echo ""
        install_ghostty
        echo ""

        echo -e "${BOLD}${BLUE}Step 6c: Installing Ghostty configuration${NC}"
        echo ""
        install_ghostty_config
        echo ""

        echo -e "${BOLD}${BLUE}Step 7: Installing NVM${NC}"
        echo ""
        install_nvm
        echo ""

        echo -e "${BOLD}${BLUE}Step 8: Installing pipx${NC}"
        echo ""
        install_pipx
        echo ""

        echo -e "${BOLD}${BLUE}Step 9: Setting up FZF${NC}"
        echo ""
        setup_fzf
        echo ""

        echo -e "${BOLD}${BLUE}Step 10: Installing Claude Code CLI${NC}"
        echo ""
        install_claude_code
        echo ""

        echo -e "${BOLD}${BLUE}Step 11: Configuring Git${NC}"
        echo ""
        configure_git
        echo ""
    fi

    # Optional: Install Node.js LTS
    if [[ "$INSTALL_NODE_LTS" == "y" ]] || [[ "$INSTALL_NODE_LTS" == "true" ]]; then
        echo -e "${BOLD}${BLUE}Installing Node.js LTS...${NC}"
        echo ""

        # Source NVM if it exists
        export NVM_DIR="$HOME/.nvm"
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            source "$NVM_DIR/nvm.sh"
            nvm install --lts
            nvm use --lts
            echo -e "${GREEN}✅ Node.js LTS installed${NC}"
        else
            echo -e "${YELLOW}⚠️  NVM not found. Please install dependencies first.${NC}"
        fi
        echo ""
    fi

    # Optional: Run tests
    if [[ "$RUN_TESTS" == "y" ]] || [[ "$RUN_TESTS" == "true" ]]; then
        echo -e "${BOLD}${BLUE}Running Tests...${NC}"
        echo ""
        if [ -f "$SCRIPT_DIR/test.sh" ]; then
            bash "$SCRIPT_DIR/test.sh"
        else
            echo -e "${YELLOW}⚠️  test.sh not found. Skipping tests.${NC}"
        fi
        echo ""
    fi

    # Reload zsh configuration
    echo -e "${BOLD}${BLUE}Reloading Zsh Configuration...${NC}"
    echo ""
    if [ -f "$HOME/.zshrc" ]; then
        # shellcheck disable=SC1091
        source "$HOME/.zshrc" 2>/dev/null && \
            echo -e "${GREEN}✅ ~/.zshrc reloaded${NC}" || \
            echo -e "${YELLOW}⚠️  ~/.zshrc reload had warnings (this is usually okay in non-zsh shells)${NC}"
    fi
    echo ""

    # Final summary
    echo ""
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${GREEN}🎉 Installation Complete!${NC}"
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "  1. Open a new Ghostty window to see the updated font"
    if [[ "$INSTALL_NODE_LTS" != "y" ]] && [[ "$INSTALL_NODE_LTS" != "true" ]] && [[ "$INSTALL_DEPENDENCIES" == "y" || "$INSTALL_DEPENDENCIES" == "true" ]]; then
        echo -e "  2. Install Node.js LTS: ${YELLOW}nvm install --lts${NC}"
    fi
    echo "  3. Start using your new setup!"
    echo ""
    echo -e "${GREEN}Happy coding! 🚀${NC}"
    echo ""
}

# Run main function
main "$@"
