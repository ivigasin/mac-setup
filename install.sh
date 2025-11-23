#!/bin/bash

# Mac Setup Installation Script
# This script sets up zsh configuration on a new Mac
#
# Copyright © 2025 Igor Vigasin
# Created by Igor Vigasin

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🚀 Starting Mac CLI Setup..."
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error: This script is designed for macOS only.${NC}"
    exit 1
fi

# Function to show what will be installed and enabled
show_installation_summary() {
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}What Will Be Installed & Enabled${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${BLUE}📁 Zsh Configuration Files:${NC}"
    echo -e "  ${GREEN}✓${NC} ~/.zshrc (main configuration file)"
    echo -e "  ${GREEN}✓${NC} ~/.zsh/config.zsh (Oh My Zsh config)"
    echo -e "  ${GREEN}✓${NC} ~/.zsh/exports.zsh (environment variables)"
    echo -e "  ${GREEN}✓${NC} ~/.zsh/aliases.zsh (command aliases)"
    echo -e "  ${GREEN}✓${NC} ~/.zsh/functions.zsh (custom functions)"
    echo -e "  ${GREEN}✓${NC} ~/.zsh/history.zsh (history settings)"
    echo -e "  ${GREEN}✓${NC} ~/.zsh/options.zsh (zsh options)"
    echo -e "  ${GREEN}✓${NC} ~/.zsh/tools.zsh (tool configurations)"
    echo ""
    
    echo -e "${BLUE}📝 Editor Configuration:${NC}"
    echo -e "  ${GREEN}✓${NC} ~/.config/nvim/init.lua (Neovim configuration)"
    echo ""
    
    echo -e "${BLUE}📝 Notes:${NC}"
    echo -e "  ${YELLOW}•${NC} Existing ~/.zshrc will be backed up to ~/.zshrc.backup"
    echo -e "  ${YELLOW}•${NC} ~/.zsh directory will be created if it doesn't exist"
    echo ""
    
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

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

# Create .zsh directory if it doesn't exist
echo -e "${YELLOW}📁 Creating ~/.zsh directory...${NC}"
mkdir -p "$HOME_DIR/.zsh"

# Copy zsh configuration files
if [ -d "$SCRIPT_DIR/.zsh" ] && [ "$(ls -A "$SCRIPT_DIR/.zsh" 2>/dev/null)" ]; then
    echo -e "${YELLOW}📋 Copying zsh configuration files...${NC}"
    cp -r "$SCRIPT_DIR/.zsh/"* "$HOME_DIR/.zsh/"
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
echo "Next steps:"
echo "  1. Install dependencies by running: ./setup.sh"
echo "  2. Test the installation by running: ./test.sh"
echo "  3. Restart your terminal or run: source ~/.zshrc"
echo ""
