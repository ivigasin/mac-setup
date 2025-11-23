#!/bin/bash

# Mac Setup Wizard
# Interactive wizard to set up a new Mac with all configurations
#
# Copyright © 2024 Igor Vigasin
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

# Clear screen
clear

# Banner
echo -e "${BLUE}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║           🚀 Mac Setup Wizard                             ║"
echo "║                                                           ║"
echo "║     Automated Mac CLI Setup & Configuration               ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Error: This script is designed for macOS only.${NC}"
    exit 1
fi

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

# Function to show what will be installed and enabled
show_installation_summary() {
    local install_zsh="$1"
    local install_deps="$2"
    
    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}What Will Be Installed & Enabled${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [[ "$install_zsh" == "y" ]]; then
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
    
    if [[ "$install_deps" == "y" ]]; then
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
        
        echo -e "${CYAN}🛠️  CLI Tools (via Homebrew):${NC}"
        echo -e "  ${GREEN}✓${NC} eza (modern ls replacement)"
        echo -e "  ${GREEN}✓${NC} bat (modern cat replacement)"
        echo -e "  ${GREEN}✓${NC} ripgrep (rg - fast grep)"
        echo -e "  ${GREEN}✓${NC} fzf (fuzzy finder)"
        echo -e "  ${GREEN}✓${NC} zoxide (smart cd)"
        echo -e "  ${GREEN}✓${NC} fd (fast find)"
        echo ""
        
        echo -e "${CYAN}💻 Development Tools:${NC}"
        echo -e "  ${GREEN}✓${NC} NVM (Node Version Manager)"
        echo -e "  ${GREEN}✓${NC} Go (Go programming language)"
        echo -e "  ${GREEN}✓${NC} Python 3.11"
        echo -e "  ${GREEN}✓${NC} OpenJDK (Java Development Kit)"
        echo -e "  ${GREEN}✓${NC} pipx (Python application installer)"
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

# Collect user information
echo -e "${BOLD}${BLUE}Step 1: User Information${NC}"
echo -e "${BLUE}─────────────────────────────────────────────────────${NC}"
echo ""

# Git configuration
GIT_NAME=""
GIT_EMAIL=""
GIT_SIGNING_KEY=""

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

echo ""
echo -e "${BOLD}${BLUE}Step 2: Installation Options${NC}"
echo -e "${BLUE}─────────────────────────────────────────────────────${NC}"
echo ""

# Installation options
INSTALL_ZSH_CONFIG="y"
INSTALL_DEPENDENCIES="y"
INSTALL_NODE_LTS="n"
RUN_TESTS="y"

prompt_yes_no "Install zsh configuration files?" "y" "INSTALL_ZSH_CONFIG"
prompt_yes_no "Install all dependencies (Homebrew, tools, etc.)?" "y" "INSTALL_DEPENDENCIES"

if [[ "$INSTALL_DEPENDENCIES" == "y" ]]; then
    prompt_yes_no "Install Node.js LTS after setup?" "n" "INSTALL_NODE_LTS"
fi

prompt_yes_no "Run tests after installation?" "y" "RUN_TESTS"

# Show what will be installed
show_installation_summary "$INSTALL_ZSH_CONFIG" "$INSTALL_DEPENDENCIES"

# Summary
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

# Confirmation
prompt_yes_no "Proceed with installation?" "y" "CONFIRM"

if [[ "$CONFIRM" != "y" ]]; then
    echo -e "${YELLOW}Installation cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${BLUE}Starting Installation...${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Export variables for setup.sh
export GIT_USER_NAME="$GIT_NAME"
export GIT_USER_EMAIL="$GIT_EMAIL"
export GIT_SIGNING_KEY="$GIT_SIGNING_KEY"

# Step 1: Install zsh configuration
if [[ "$INSTALL_ZSH_CONFIG" == "y" ]]; then
    echo -e "${BOLD}${BLUE}📦 Step 1: Installing zsh configuration...${NC}"
    echo ""
    cd "$SCRIPT_DIR"
    bash "$SCRIPT_DIR/install.sh"
    echo ""
fi

# Step 2: Install dependencies
if [[ "$INSTALL_DEPENDENCIES" == "y" ]]; then
    echo -e "${BOLD}${BLUE}📦 Step 2: Installing dependencies...${NC}"
    echo ""
    cd "$SCRIPT_DIR"
    bash "$SCRIPT_DIR/setup.sh"
    echo ""
fi

# Step 3: Install Node.js LTS if requested
if [[ "$INSTALL_NODE_LTS" == "y" ]]; then
    echo -e "${BOLD}${BLUE}📦 Step 3: Installing Node.js LTS...${NC}"
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

# Step 4: Run tests
if [[ "$RUN_TESTS" == "y" ]]; then
    echo -e "${BOLD}${BLUE}🧪 Step 4: Running tests...${NC}"
    echo ""
    cd "$SCRIPT_DIR"
    if [ -f "$SCRIPT_DIR/test.sh" ]; then
        bash "$SCRIPT_DIR/test.sh"
    else
        echo -e "${YELLOW}⚠️  test.sh not found. Skipping tests.${NC}"
    fi
    echo ""
fi

# Final summary
echo ""
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}🎉 Installation Complete!${NC}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo -e "  1. Restart your terminal or run: ${YELLOW}source ~/.zshrc${NC}"
if [[ "$INSTALL_NODE_LTS" != "y" ]] && [[ "$INSTALL_DEPENDENCIES" == "y" ]]; then
    echo -e "  2. Install Node.js LTS: ${YELLOW}nvm install --lts${NC}"
fi
echo "  3. Start using your new setup!"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
echo ""
