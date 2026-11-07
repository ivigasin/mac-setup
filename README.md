# Mac CLI Setup

Automated setup script for configuring a new Mac with my preferred CLI tools and zsh configuration.

## Features

- 🪄 **Interactive Wizard** - One-command setup with guided configuration
- 🎨 **Oh My Zsh** with Agnoster theme
- 🔌 **Zsh plugins**: autosuggestions, syntax highlighting, history substring search, fzf
- 🛠️ **Modern CLI tools**: eza, bat, ripgrep, fzf, zoxide, gh
- 📦 **Language runtimes via [mise](https://mise.jdx.dev)**: Node.js, Python, Go, Java — with per-project versions
- 🍺 **Homebrew + Brewfile**: CLI tools, apps and fonts declared in one file
- 🖥️ **Terminal**: Ghostty with Nerd Font and iTerm2-style keybindings
- 🤖 **AI Development**: Claude Code CLI with helpful aliases and functions
- 📁 **Modular configuration**: Split into organized files
- ⚙️ **Git configuration**: Automatic setup with GPG signing, aliases, and color schemes

## Quick Start

### 🪄 Interactive Setup (Recommended)

The easiest way to set up everything is using the interactive installer:

```bash
git clone <your-repo-url> ~/mac-setup
cd ~/mac-setup
./setup.sh
```

The interactive setup will:
- ✅ Collect your Git configuration (name, email, GPG key)
- ✅ Let you choose what to install
- ✅ Run all installation steps automatically
- ✅ Run tests to verify everything works

**That's it!** The setup script handles everything for you.

### How it works

`setup.sh` is a small bootstrap: it installs [mise](https://mise.jdx.dev) if missing and runs `mise run setup`.
Every step is a mise task in `mise-tasks/`, so you can re-run any one of them on its own:

```bash
mise tasks ls          # list all steps
mise run brew-bundle   # install anything new added to the Brewfile
mise run runtimes      # (re)install node/python/go/java from .config/mise/config.toml
mise run git           # re-apply Git configuration
mise run zsh-config    # re-copy zsh config files
```

- **Homebrew** packages, apps and fonts are declared in `Brewfile` and installed with `brew bundle` (driven by the `brew-bundle` task).
- **Language runtimes** are declared in `.config/mise/config.toml`, copied to `~/.config/mise/config.toml`, and installed by mise. Projects can pin their own versions with `mise.toml`, `.nvmrc`, `.node-version` or `.python-version`.

### Non-Interactive Setup

For automation or CI/CD environments:

```bash
# Install everything with defaults
./setup.sh --non-interactive

# Or customize with options
./setup.sh --non-interactive --skip-zsh --skip-tests

# With environment variables
GIT_USER_NAME="Your Name" \
GIT_USER_EMAIL="your@email.com" \
GIT_USER_SIGNING_KEY="YOUR_GPG_KEY" \
./setup.sh --non-interactive
```

**Available options:**
- `--non-interactive` - Run without prompts
- `--skip-zsh` - Skip zsh configuration installation
- `--skip-deps` - Skip dependency installation
- `--install-node` - No-op, kept for compatibility (Node.js LTS is always installed by mise)
- `--skip-tests` - Skip running tests
- `-h, --help` - Show help message

### What Gets Installed

The setup script installs:
- **Zsh Configuration** - Modular config files in `~/.zsh/` directory
- **mise** - Runs the setup tasks and manages language runtimes
- **Homebrew** - Automatically detects Intel/Apple Silicon Macs; packages come from `Brewfile`
- **Oh My Zsh** with plugins (autosuggestions, syntax highlighting, etc.)
- **CLI Tools** - eza, bat, ripgrep, fzf, zoxide, fd, neovim, gh
- **Language Runtimes (mise)** - Node.js LTS, Python 3.11, Go (latest), Java (Temurin 21)
- **Python tooling** - uv, pipx
- **Ghostty** - Installed with Nerd Font and iTerm2-style keybindings (`~/.config/ghostty/config`)
- **Nerd Fonts** - font-meslo-lg-nerd-font, font-hack-nerd-font
- **Claude Code CLI** - AI-powered coding assistant
- **Git Configuration** - Aliases, colors, GPG signing, and credentials

**Note:** Homebrew installation is fully automated and handles:
- ✅ Automatic detection of Intel vs Apple Silicon Macs
- ✅ PATH configuration for current session and persistence
- ✅ Error handling and verification
- ✅ Automatic updates after installation

### Testing

Verify your installation:

```bash
./test.sh
```

This checks:
- All configuration files are in place
- Required tools are installed
- Zsh configuration loads correctly
- Aliases and functions are defined

### Restart Your Terminal

```bash
source ~/.zshrc
```

Or simply open a new terminal window.

## Configuration Structure

```
.zsh/
├── config.zsh      # Oh My Zsh configuration (theme, plugins)
├── exports.zsh     # Environment variables and PATH exports
├── aliases.zsh     # All aliases
├── functions.zsh   # Custom functions
├── history.zsh     # History configuration
├── options.zsh     # Zsh options and settings
└── tools.zsh       # Tool-specific configs (FZF, zoxide, etc.)
```

## Included Tools

### CLI Tools
- **eza** - Modern `ls` replacement with icons and git integration
- **bat** - Modern `cat` replacement with syntax highlighting
- **ripgrep (rg)** - Fast grep replacement
- **fzf** - Fuzzy finder
- **zoxide** - Smart `cd` command
- **fd** - Fast find replacement
- **gh** - GitHub CLI for PRs, issues, and repo operations

### Terminal Emulator
- **Ghostty** - Installed with a custom `config` that sets the MesloLGS Nerd Font and mirrors iTerm2 keybindings (Cmd+T tabs, Cmd+D splits, Cmd+Opt+Arrow navigation, etc.). Config lives at `~/.config/ghostty/config`; reload with `Cmd+Shift+,`.

### Development Tools
- **mise** - Polyglot runtime manager; global versions in `~/.config/mise/config.toml`
- **Node.js LTS** - via mise (respects `.nvmrc` / `.node-version` in projects)
- **Python 3.11** - via mise (respects `.python-version`)
- **Go** - via mise (latest)
- **Java (Temurin 21)** - via mise
- **uv / pipx** - Python package and application installers (Homebrew)
- **Claude Code CLI** - AI-powered coding assistant with helpful shell functions

### Git Configuration
The setup script automatically configures Git with:
- **Default branch**: Set to `main`
- **Pull strategy**: Uses rebase by default
- **GPG signing**: Auto-enabled only when a usable secret key is present in the keyring; otherwise left disabled (set `GIT_USER_SIGNING_KEY` and import the key to enable)
- **Color output**: Comprehensive color configuration for branches, diffs, and status
- **Credential helper**: Configured for macOS Keychain
- **Extensive aliases**: 
  - `st` (status), `ci` (commit), `co` (checkout), `br` (branch)
  - `df` (diff), `dc` (diff cached), `lg` (log with patches)
  - `lp` (pretty log), `lol`/`lola` (graph log), `grog` (detailed graph log)
  - `who` (shortlog), `undo` (reset hard), `unlock` (remove index lock)
- **User configuration**: Prompts for name and email if not already configured

### Zsh Plugins
- **git** - Git aliases and functions
- **zsh-autosuggestions** - Suggests commands as you type
- **zsh-syntax-highlighting** - Syntax highlighting for commands
- **history-substring-search** - Search history with substring matching
- **fzf** - Fuzzy finder integration

### Claude Code Helpers

The setup includes several helpful aliases and functions for working with Claude Code:

**Aliases:**
- `cc` - Short alias for `claude`
- `ccd` - Run Claude Code in current directory
- `cci` - Initialize Claude Code
- `ccv` - Show version
- `cch` - Show help

**Functions:**
- `ccstart [message]` - Initialize and start Claude Code with optional message
- `ccfile <file> [message]` - Run Claude Code with specific file context
- `ccgit [message]` - Run Claude Code in git repository context
- `ccask <question>` - Quick Claude Code question
- `ccnew <project-name>` - Create new project with Claude Code initialized

**Examples:**
```bash
# Quick start in current project
ccstart "help me refactor this code"

# Ask Claude about a specific file
ccfile src/main.js "explain this code"

# Review git changes
ccgit "create a PR description"

# Create new project
ccnew my-awesome-project
```

## Customization

### Adding new aliases

Edit `~/.zsh/aliases.zsh`:

```bash
alias myalias='mycommand'
```

### Adding new environment variables

Edit `~/.zsh/exports.zsh`:

```bash
export MY_VAR="value"
```

### Adding new functions

Edit `~/.zsh/functions.zsh`:

```bash
myfunction() {
    # your code here
}
```

## Updating Configuration

To update your configuration from the repository:

```bash
cd ~/mac-setup
git pull
./setup.sh --non-interactive --skip-deps  # Update config files only
./test.sh  # Verify the update
```

Or run the full interactive setup to update everything:

```bash
./setup.sh
```

## Testing

Run the test script to verify your installation:

```bash
./test.sh
```

The test script checks:
- ✅ Configuration files exist and are properly structured
- ✅ Oh My Zsh and plugins are installed
- ✅ Required CLI tools are available
- ✅ Development tools are installed
- ✅ Aliases and functions are defined
- ✅ Zsh configuration loads without errors
- ✅ Environment variables are set correctly

## Troubleshooting

### Scripts are not executable

```bash
chmod +x setup.sh test.sh uninstall.sh mise-tasks/*
```

### Oh My Zsh plugins not working

Make sure plugins are installed in `~/.oh-my-zsh/custom/plugins/`. Run `setup.sh` to install them automatically.

### PATH issues

Check `~/.zsh/exports.zsh` and ensure all paths are correct for your system.

### A runtime resolves to the wrong version

Run `mise doctor` (should report `activated: yes`) and `mise ls --current` in the directory in question.
Interactive shells activate mise in `~/.zsh/tools.zsh`; non-interactive shells (IDEs, GUI apps) use the shims added to `~/.zprofile`.

## License

MIT

---

**Copyright © 2025 Igor Vigasin**

Created with ❤️ by Igor Vigasin
