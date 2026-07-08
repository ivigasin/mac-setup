# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an automated macOS setup repository for configuring a new Mac with CLI tools, zsh configuration, and development environments. The project uses a single unified bash script for installation and configuration management.

## Script Architecture

The repository uses a single all-in-one script that handles everything:

**setup.sh** - Unified installation script
- Supports both interactive and non-interactive modes
- Installs zsh configuration files (from inline functions)
- Installs Homebrew (handles both Intel and Apple Silicon)
- Installs Oh My Zsh and plugins
- Installs CLI tools via Homebrew (eza, bat, ripgrep, fzf, zoxide, fd, neovim, gh, git-secrets)
- Installs development tools (NVM, Go, Python, Java, pipx, Claude Code CLI)
- Installs Ghostty terminal and copies `.config/ghostty/config` (Nerd Font, iTerm2-style keybindings)
- Configures Git with aliases, colors, GPG signing
- Sets up FZF key bindings
- Optionally installs Node.js LTS and runs tests

### Execution Modes

1. **Interactive Mode** (default)
   - Collects Git configuration (name, email, GPG key)
   - Prompts for installation options
   - Shows installation summary and requests confirmation
   - Handles user input gracefully

2. **Non-Interactive Mode** (`--non-interactive`)
   - Uses environment variables for configuration
   - Runs with default settings or command-line flags
   - Ideal for automation and CI/CD
   - Accepts: GIT_USER_NAME, GIT_USER_EMAIL, GIT_USER_SIGNING_KEY

### Legacy Scripts

The old modular scripts (wizard.sh, install.sh) have been backed up as *.old files but are no longer used.

## Zsh Configuration Structure

The zsh configuration is split into modular files in the `.zsh/` directory:

- **config.zsh** - Oh My Zsh theme (Agnoster) and plugins configuration
- **exports.zsh** - Environment variables (LANG, EDITOR, PATH, NVM, Go, Python, Java)
- **aliases.zsh** - Command aliases (modern tool replacements like eza, bat)
- **functions.zsh** - Custom shell functions
- **history.zsh** - History settings
- **options.zsh** - Zsh options
- **tools.zsh** - Tool-specific configurations (FZF, zoxide)

The main `.zshrc` file sources all these files from `~/.zsh/`.

## Common Commands

### Initial Setup
```bash
# Interactive setup (recommended)
./setup.sh

# Non-interactive setup with all defaults
./setup.sh --non-interactive

# Non-interactive with custom options
./setup.sh --non-interactive --install-node --skip-tests

# With environment variables
GIT_USER_NAME="Name" GIT_USER_EMAIL="email@example.com" ./setup.sh --non-interactive

# Show help and all available options
./setup.sh --help
```

### Updating Configuration
```bash
# Update only zsh configuration files
./setup.sh --non-interactive --skip-deps

# Update everything
./setup.sh --non-interactive

# Interactive update (choose what to update)
./setup.sh
```

### Testing
```bash
# Run all tests
./test.sh

# The test script verifies:
# - Configuration files are in place
# - Oh My Zsh and plugins are installed
# - CLI tools are available
# - Zsh configuration loads without errors
```

### Command-Line Options
- `--non-interactive` - No prompts, use defaults or env vars
- `--skip-zsh` - Skip zsh configuration installation
- `--skip-deps` - Skip dependency installation
- `--install-node` - Install Node.js LTS
- `--skip-tests` - Skip running tests
- `-h, --help` - Show help message

## Git Configuration

The setup.sh script automatically configures Git with:
- Default branch: `main`
- Pull strategy: rebase
- GPG signing: auto-enabled only when the signing key's secret key exists in the keyring; otherwise left disabled (no hardcoded fallback key)
- Credential helper: macOS Keychain
- Comprehensive color settings
- Extensive aliases (st, ci, co, br, df, dc, lg, lp, lol, lola, grog, who, undo, unlock)

Git configuration accepts environment variables (GIT_USER_NAME, GIT_USER_EMAIL, GIT_USER_SIGNING_KEY) in non-interactive mode, or prompts interactively if not set.

## Homebrew Installation

The setup.sh script handles Homebrew installation with:
- Automatic architecture detection (Intel vs Apple Silicon)
- PATH configuration for current session and persistence via ~/.zprofile
- Error handling and verification
- Automatic updates after installation

Homebrew paths:
- Apple Silicon: `/opt/homebrew/bin/brew`
- Intel: `/usr/local/bin/brew`

## Important Implementation Notes

### Script Structure
The setup.sh script is organized into distinct sections:
1. **Utility Functions** - Helper functions (command_exists, file_exists, etc.)
2. **Display Functions** - Banner, installation summary, setup summary
3. **Zsh Configuration Installation** - Config file copying and installation
4. **Dependency Installation Functions** - Individual installers for each tool
5. **Interactive Wizard Functions** - User input collection and option prompts
6. **Main Execution Flow** - Argument parsing and orchestration

### Script Execution Context
- Uses `set -e` for error handling (except test.sh which uses `set +e`)
- INTERACTIVE_MODE flag controls prompting behavior
- Sources Homebrew shellenv for both architectures
- Uses SCRIPT_DIR for relative path resolution
- Installation flags (INSTALL_ZSH_CONFIG, INSTALL_DEPENDENCIES, etc.) control flow

### Git Configuration Flow
The configure_git() function:
1. Checks for environment variables (GIT_USER_NAME, GIT_USER_EMAIL, GIT_USER_SIGNING_KEY)
2. Falls back to existing git config values
3. Prompts user if values are missing (only in interactive mode)
4. Always configures color settings and aliases

### Testing Philosophy
- Critical tests must pass (configuration files, zsh loading)
- Optional tests warn but don't fail (tools, plugins)
- test.sh returns exit code 0 if critical tests pass

### File Modification
When modifying setup.sh:
- Maintain consistent color output scheme (RED, GREEN, YELLOW, BLUE, CYAN, NC)
- Preserve the confirmation prompts in interactive mode
- Keep the installation summary display functions
- Maintain both interactive and non-interactive modes
- Don't modify PATH exports in exports.zsh without understanding user-specific paths (e.g., Rancher Desktop section)
- When adding new installation functions, follow the existing pattern:
  1. Check if already installed
  2. Display installation progress with colors
  3. Handle errors gracefully
  4. Confirm successful installation

### Color Scheme
All scripts use consistent ANSI color codes:
- RED: Errors
- GREEN: Success/checkmarks
- YELLOW: Warnings/prompts
- BLUE: Headers/section titles
- CYAN: User input prompts (wizard only)

## Claude Code CLI Setup

The repository includes automated installation and helpful utilities for Claude Code CLI.

### Installation
Claude Code CLI is automatically installed by setup.sh via Homebrew:
- Installed with `brew install --cask claude-code`
- Available via `claude` command and various aliases

### Aliases
Quick shortcuts for common Claude Code operations:
- `cc` - Short alias for `claude`
- `ccd` - Run Claude Code in current directory
- `cci` - Initialize Claude Code in current directory
- `ccv` - Show Claude Code version
- `cch` - Show Claude Code help

### Helper Functions

**ccstart [message]**
- Initializes Claude Code if not already initialized
- Optionally starts with a message
- Usage: `ccstart` or `ccstart "help me refactor this code"`

**ccfile <file> [message]**
- Run Claude Code with a specific file context
- Usage: `ccfile src/main.js "explain this code"`

**ccgit [message]**
- Run Claude Code in git repository context
- Defaults to "Review my changes"
- Usage: `ccgit` or `ccgit "create PR description"`

**ccask <question>**
- Quick Claude Code question
- Usage: `ccask "how do I use async/await in Python?"`

**ccnew <project-name>**
- Create new directory, cd into it, and initialize Claude Code
- Usage: `ccnew my-new-project`

## Default Tool Versions

- Python: 3.11
- NVM: v0.40.3
- Theme: Agnoster
- Editor: neovim
- Bat theme: Dracula
- Ghostty font: MesloLGS Nerd Font 13
- Ghostty config: `.config/ghostty/config` — Nerd Font, splits, iTerm2-style Cmd bindings
