# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an automated macOS setup repository for configuring a new Mac with CLI tools, zsh configuration, and development environments. mise is the backbone: a small bootstrap (`setup.sh`) installs mise, mise tasks run every setup step, Homebrew installs packages from a `Brewfile`, and mise manages the language runtimes.

## Script Architecture

```
setup.sh                  # bootstrap: installs mise (~/.local/bin) if missing, then `exec mise run setup "$@"`
mise.toml                 # project config; tasks are auto-discovered from mise-tasks/
mise-tasks/               # one bash file task per step (run any alone: `mise run <step>`)
  setup                   #   orchestrator: flags (#USAGE), wizard, summary, runs steps in order
  brew                    #   install/update Homebrew (Intel + Apple Silicon)
  omz                     #   Oh My Zsh + plugins
  zsh-config              #   ~/.zshrc, ~/.zsh/*.zsh, Neovim config
  brew-bundle             #   `brew bundle install --no-upgrade` from Brewfile (--upgrade to upgrade)
  ghostty                 #   copy .config/ghostty/config
  vscode-cli              #   ensure the `code` CLI is on PATH
  runtimes                #   copy .config/mise/config.toml to ~/.config/mise/, add shims to ~/.zprofile, `mise install`
  fzf                     #   FZF key bindings
  claude                  #   Claude Code CLI install + auth
  git                     #   Git defaults, GPG signing, colors, aliases, git-secrets
  test                    #   runs test.sh
lib/common.sh             # colors + helpers sourced by every task (command_exists, prompt_*, install_config_file, load_brew_env)
Brewfile                  # CLI tools, GUI casks (guarded if the app already exists in /Applications), fonts
.config/mise/config.toml  # global runtimes: node lts, python 3.11, go latest, java temurin-21
test.sh / uninstall.sh    # verification / reversal
```

Runtimes (node, python, go, java) are **not** installed via Homebrew or nvm — only mise. Interactive zsh activates mise in `.zsh/tools.zsh`; non-interactive shells get mise shims from `~/.zprofile`.

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

## Zsh Configuration Structure

The zsh configuration is split into modular files in the `.zsh/` directory:

- **config.zsh** - Oh My Zsh theme (Agnoster) and plugins configuration
- **exports.zsh** - Environment variables (LANG, EDITOR, PATH, Go bin, FZF, bat)
- **aliases.zsh** - Command aliases (modern tool replacements like eza, bat)
- **functions.zsh** - Custom shell functions
- **history.zsh** - History settings
- **options.zsh** - Zsh options
- **tools.zsh** - Tool-specific configurations (FZF, zoxide, mise activation)

The main `.zshrc` file sources all these files from `~/.zsh/`.

## Common Commands

### Initial Setup
```bash
# Interactive setup (recommended)
./setup.sh

# Non-interactive setup with all defaults
./setup.sh --non-interactive

# Non-interactive with custom options
./setup.sh --non-interactive --skip-zsh --skip-tests

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

# Run a single step
mise tasks ls
mise run brew-bundle   # after editing Brewfile
mise run runtimes      # after editing .config/mise/config.toml
mise run git
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
- `--install-node` - No-op, kept for compatibility (Node.js LTS is always installed by mise)
- `--skip-tests` - Skip running tests
- `-h, --help` - Show help message

## Git Configuration

The `git` task (mise-tasks/git) automatically configures Git with:
- Default branch: `main`
- Pull strategy: rebase
- GPG signing: auto-enabled only when the signing key's secret key exists in the keyring; otherwise left disabled (no hardcoded fallback key)
- Credential helper: macOS Keychain
- Comprehensive color settings
- Extensive aliases (st, ci, co, br, df, dc, lg, lp, lol, lola, grog, who, undo, unlock)

Git configuration accepts environment variables (GIT_USER_NAME, GIT_USER_EMAIL, GIT_USER_SIGNING_KEY) in non-interactive mode, or prompts interactively if not set.

## Homebrew Installation

The `brew` task handles Homebrew installation with:
- Automatic architecture detection (Intel vs Apple Silicon)
- PATH configuration for current session and persistence via ~/.zprofile
- Error handling and verification
- Automatic updates after installation

Homebrew paths:
- Apple Silicon: `/opt/homebrew/bin/brew`
- Intel: `/usr/local/bin/brew`

## Important Implementation Notes

### Task Structure
- Each file in `mise-tasks/` is an executable bash script with `#MISE description=...` headers; tasks that read stdin use `#MISE raw=true`.
- Every task starts with `set -e` and `source "$MISE_PROJECT_ROOT/lib/common.sh"` (test.sh uses `set +e`).
- `mise-tasks/setup` declares its flags with `#USAGE flag ...`; mise exposes them as `usage_<flag>` env vars (e.g. `usage_skip_deps=true`).
- The orchestrator runs each step via `mise run --quiet <step>` and exports `INTERACTIVE_MODE`, `GIT_NAME`, `GIT_EMAIL`, `GIT_SIGNING_KEY` to them.
- `lib/common.sh` loads Homebrew's shellenv for both architectures and sets `SCRIPT_DIR` (= `MISE_PROJECT_ROOT`) for relative paths.
- Installation flags (INSTALL_ZSH_CONFIG, INSTALL_DEPENDENCIES, RUN_TESTS) control flow in the orchestrator.

### Adding Things
- A Homebrew CLI/app/font → add a line to `Brewfile` (guard GUI casks with `unless File.exist?("/Applications/...")`).
- A language runtime → add it to `.config/mise/config.toml` `[tools]`.
- A new setup step → new file in `mise-tasks/` + a `run_step` line in `mise-tasks/setup` + an entry in `show_installation_summary`.

### Git Configuration Flow
The configure_git() function (mise-tasks/git):
1. Checks for environment variables (GIT_USER_NAME, GIT_USER_EMAIL, GIT_USER_SIGNING_KEY)
2. Falls back to existing git config values
3. Prompts user if values are missing (only in interactive mode)
4. Always configures color settings and aliases

### Testing Philosophy
- Critical tests must pass (configuration files, zsh loading)
- Optional tests warn but don't fail (tools, plugins)
- test.sh returns exit code 0 if critical tests pass

### File Modification
When modifying setup tasks:
- Maintain consistent color output scheme (RED, GREEN, YELLOW, BLUE, CYAN, NC)
- Preserve the confirmation prompts in interactive mode
- Keep the installation summary display functions
- Maintain both interactive and non-interactive modes
- Don't modify PATH exports in exports.zsh without understanding user-specific paths (e.g., Rancher Desktop section)
- When adding new installation tasks, follow the existing pattern:
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
Claude Code CLI is installed by the `claude` task via Homebrew (skipped when a native install is already on PATH):
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

- Node.js: LTS (mise)
- Python: 3.11 (mise)
- Go: latest (mise)
- Java: Temurin 21 (mise)
- Theme: Agnoster
- Editor: neovim
- Bat theme: Dracula
- Ghostty font: MesloLGS Nerd Font 13
- Ghostty config: `.config/ghostty/config` — Nerd Font, splits, iTerm2-style Cmd bindings
