#!/bin/bash

# Installation Test Script
# Verifies that the Mac CLI setup is correctly installed
#
# Copyright © 2025 Igor Vigasin
# Created by Igor Vigasin

# Don't exit on error - we want to run all tests
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNED=0
TESTS_TOTAL=0
CRITICAL_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local is_critical="${3:-false}"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -n "Testing: $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        if [ "$is_critical" = "true" ]; then
            echo -e "${RED}✗ FAILED${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            CRITICAL_FAILED=$((CRITICAL_FAILED + 1))
        else
            echo -e "${YELLOW}⚠ WARNING${NC}"
            TESTS_WARNED=$((TESTS_WARNED + 1))
        fi
        return 1
    fi
}

# Function to check if file exists
file_exists() {
    [ -f "$1" ]
}

# Function to check if directory exists
dir_exists() {
    [ -d "$1" ]
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${BLUE}🧪 Mac CLI Setup - Installation Test${NC}"
echo "=========================================="
echo ""

# Check if installation has been run
if [ ! -d "$HOME/.zsh" ] && [ ! -f "$HOME/.zshrc" ]; then
    echo -e "${YELLOW}⚠️  Installation not detected. Run ./install.sh first.${NC}"
    echo ""
fi

# Test 1: Check if .zshrc exists (critical)
run_test ".zshrc file exists" "file_exists $HOME/.zshrc" "true"

# Test 2: Check if .zsh directory exists (critical)
run_test ".zsh directory exists" "dir_exists $HOME/.zsh" "true"

# Test 3-9: Check if all config files exist (critical if .zsh exists)
echo ""
echo -e "${BLUE}Configuration Files:${NC}"
if [ -d "$HOME/.zsh" ]; then
    run_test "config.zsh exists" "file_exists $HOME/.zsh/config.zsh" "true"
    run_test "exports.zsh exists" "file_exists $HOME/.zsh/exports.zsh" "true"
    run_test "aliases.zsh exists" "file_exists $HOME/.zsh/aliases.zsh" "true"
    run_test "functions.zsh exists" "file_exists $HOME/.zsh/functions.zsh" "true"
    run_test "history.zsh exists" "file_exists $HOME/.zsh/history.zsh" "true"
    run_test "options.zsh exists" "file_exists $HOME/.zsh/options.zsh" "true"
    run_test "tools.zsh exists" "file_exists $HOME/.zsh/tools.zsh" "true"
else
    echo -e "${YELLOW}⚠ Skipping config file tests (.zsh directory not found)${NC}"
fi

# Test 10: Check if .zshrc sources the config files
echo ""
echo -e "${BLUE}Configuration Loading:${NC}"
if [ -f "$HOME/.zshrc" ]; then
    run_test ".zshrc references .zsh directory" "grep -q '\$HOME/.zsh' $HOME/.zshrc || grep -q 'ZSH_CONFIG_DIR' $HOME/.zshrc" "true"
else
    echo -e "${YELLOW}⚠ Skipping .zshrc test (file not found)${NC}"
fi

# Test 11-12: Check if Oh My Zsh is installed (optional - can be installed by setup.sh)
echo ""
echo -e "${BLUE}Oh My Zsh:${NC}"
run_test "Oh My Zsh directory exists" "dir_exists $HOME/.oh-my-zsh" "false"
run_test "Oh My Zsh main script exists" "file_exists $HOME/.oh-my-zsh/oh-my-zsh.sh" "false"

# Test 13-16: Check if zsh plugins are installed (optional)
echo ""
echo -e "${BLUE}Zsh Plugins:${NC}"
run_test "zsh-autosuggestions plugin exists" "dir_exists $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" "false"
run_test "zsh-syntax-highlighting plugin exists" "dir_exists $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" "false"
run_test "history-substring-search plugin exists" "dir_exists $HOME/.oh-my-zsh/custom/plugins/zsh-history-substring-search || dir_exists $HOME/.oh-my-zsh/plugins/history-substring-search" "false"
run_test "fzf plugin exists" "dir_exists $HOME/.oh-my-zsh/plugins/fzf || command_exists fzf" "false"

# Test 17-22: Check if CLI tools are installed (optional - installed by setup.sh)
echo ""
echo -e "${BLUE}CLI Tools:${NC}"
run_test "eza is installed" "command_exists eza" "false"
run_test "bat is installed" "command_exists bat" "false"
run_test "ripgrep (rg) is installed" "command_exists rg" "false"
run_test "fzf is installed" "command_exists fzf" "false"
run_test "zoxide is installed" "command_exists zoxide" "false"
run_test "fd is installed" "command_exists fd" "false"

# Test 23-26: Check if development tools are installed (optional)
echo ""
echo -e "${BLUE}Development Tools:${NC}"
run_test "Homebrew is installed" "command_exists brew" "false"
run_test "NVM is installed" "dir_exists $HOME/.nvm" "false"
run_test "Go is installed" "command_exists go" "false"
run_test "Python 3 is installed" "command_exists python3" "false"

# Test 27: Check if pipx is installed (optional)
run_test "pipx is installed" "command_exists pipx" "false"

# Test 28: Check if Java is installed (optional)
run_test "Java is installed" "command_exists java || [ -d /opt/homebrew/opt/openjdk ] || [ -d /usr/local/opt/openjdk ]" "false"

# Test 29-30: Check if aliases are defined
echo ""
echo -e "${BLUE}Aliases:${NC}"
# Source the aliases file and check if aliases are set
if [ -f "$HOME/.zsh/aliases.zsh" ]; then
    # Check if common aliases are defined in the file
    run_test "ls alias is defined" "grep -q \"alias ls='eza\" $HOME/.zsh/aliases.zsh" "true"
    run_test "cat alias is defined" "grep -q \"alias cat='bat\" $HOME/.zsh/aliases.zsh" "true"
else
    echo -e "${YELLOW}⚠ Skipping alias tests (aliases.zsh not found)${NC}"
fi

# Test 31: Check if functions are defined
echo ""
echo -e "${BLUE}Functions:${NC}"
if [ -f "$HOME/.zsh/functions.zsh" ]; then
    run_test "mkcd function is defined" "grep -q 'mkcd()' $HOME/.zsh/functions.zsh" "true"
else
    echo -e "${YELLOW}⚠ Skipping function tests (functions.zsh not found)${NC}"
fi

# Test 32: Check if environment variables are set
echo ""
echo -e "${BLUE}Environment Variables:${NC}"
if [ -f "$HOME/.zsh/exports.zsh" ]; then
    run_test "EDITOR is configured" "grep -q 'export EDITOR' $HOME/.zsh/exports.zsh" "true"
    run_test "LANG is configured" "grep -q 'export LANG' $HOME/.zsh/exports.zsh" "true"
else
    echo -e "${YELLOW}⚠ Skipping environment variable tests (exports.zsh not found)${NC}"
fi

# Test 33: Check if FZF is configured
echo ""
echo -e "${BLUE}FZF Configuration:${NC}"
if [ -f "$HOME/.zsh/exports.zsh" ]; then
    run_test "FZF_DEFAULT_COMMAND is set" "grep -q 'FZF_DEFAULT_COMMAND' $HOME/.zsh/exports.zsh" "false"
else
    echo -e "${YELLOW}⚠ Skipping FZF config test (exports.zsh not found)${NC}"
fi

# Test 34: Check if zsh can load the configuration
echo ""
echo -e "${BLUE}Zsh Configuration Loading:${NC}"
if [ -f "$HOME/.zshrc" ]; then
    run_test "zsh can source .zshrc without errors" "zsh -c 'source $HOME/.zshrc' >/dev/null 2>&1" "true"
else
    echo -e "${YELLOW}⚠ Skipping zsh load test (.zshrc not found)${NC}"
fi

# Test 35: Check if Homebrew PATH is configured
echo ""
echo -e "${BLUE}Homebrew Configuration:${NC}"
if command_exists brew; then
    BREW_PREFIX=$(brew --prefix)
    run_test "Homebrew is in PATH" "echo \$PATH | grep -q \"$BREW_PREFIX\"" "false"
else
    echo -e "${YELLOW}⚠ Skipping Homebrew PATH test (Homebrew not installed)${NC}"
fi

# Summary
echo ""
echo "=========================================="
echo -e "${BLUE}Test Summary:${NC}"
echo -e "  Total tests: $TESTS_TOTAL"
echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "  ${RED}Failed (critical): $TESTS_FAILED${NC}"
fi
if [ $TESTS_WARNED -gt 0 ]; then
    echo -e "  ${YELLOW}Warnings (optional): $TESTS_WARNED${NC}"
fi

# Calculate percentage
if [ $TESTS_TOTAL -gt 0 ]; then
    PERCENTAGE=$((TESTS_PASSED * 100 / TESTS_TOTAL))
    echo -e "  Success rate: ${PERCENTAGE}%"
fi

echo ""

# Final result
if [ $CRITICAL_FAILED -eq 0 ]; then
    if [ $TESTS_WARNED -gt 0 ]; then
        echo -e "${GREEN}✅ Critical tests passed!${NC}"
        echo -e "${YELLOW}⚠️  Some optional components are missing.${NC}"
        echo -e "${YELLOW}   Run ./setup.sh to install missing dependencies.${NC}"
        exit 0
    else
        echo -e "${GREEN}🎉 All tests passed! Installation is complete.${NC}"
        exit 0
    fi
else
    echo -e "${RED}❌ Critical tests failed!${NC}"
    echo -e "${YELLOW}   Please run ./install.sh first to install configuration files.${NC}"
    if [ $TESTS_WARNED -gt 0 ]; then
        echo -e "${YELLOW}   Then run ./setup.sh to install missing dependencies.${NC}"
    fi
    exit 1
fi
