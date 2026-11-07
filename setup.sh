#!/bin/bash

# Mac Setup - Bootstrap
# Installs mise (if needed) and hands off to `mise run setup`, which drives
# Homebrew, zsh configuration, language runtimes, Git and Claude Code.
# All options are passed through: ./setup.sh --help
#
# Copyright © 2025 Igor Vigasin
# Created by Igor Vigasin

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Error: This script is designed for macOS only.${NC}"
    exit 1
fi

# mise installs to ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

if ! command -v mise >/dev/null 2>&1; then
    echo -e "${YELLOW}📦 Installing mise...${NC}"
    curl -fsSL https://mise.run | sh || {
        echo -e "${RED}❌ mise installation failed${NC}"
        echo -e "${YELLOW}   Install it manually: curl https://mise.run | sh${NC}"
        exit 1
    }
    echo -e "${GREEN}✅ mise installed: $(mise --version)${NC}"
fi

cd "$SCRIPT_DIR"
mise trust --quiet --yes "$SCRIPT_DIR/mise.toml"

exec mise run setup "$@"
