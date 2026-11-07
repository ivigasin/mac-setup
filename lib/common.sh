#!/bin/bash

# Mac Setup - Shared helpers for mise tasks
# Sourced by every file task in mise-tasks/
#
# Copyright © 2025 Igor Vigasin
# Created by Igor Vigasin

# shellcheck disable=SC2034  # variables below are used by the tasks that source this file

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Repository root (mise sets MISE_PROJECT_ROOT for tasks)
SCRIPT_DIR="${MISE_PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
HOME_DIR="$HOME"

# Interactive unless the orchestrator (or caller) says otherwise
INTERACTIVE_MODE="${INTERACTIVE_MODE:-true}"

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

# Put Homebrew on PATH for this process (tasks run in fresh, non-login shells)
load_brew_env() {
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

# Copy a config file into place, backing up a differing existing copy
install_config_file() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [ -f "$dest" ] && ! cmp -s "$src" "$dest"; then
        echo -e "  ${YELLOW}💾 Backing up existing $(basename "$dest") to $(basename "$dest").backup${NC}"
        command cp -f "$dest" "$dest.backup"
    fi

    command cp -f "$src" "$dest"
}

load_brew_env
