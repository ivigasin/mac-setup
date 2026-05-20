# Mac CLI Setup

Automated setup script for configuring a new Mac with my preferred CLI tools and zsh configuration.

## Features

- 🪄 **Interactive Wizard** - One-command setup with guided configuration
- 🎨 **Oh My Zsh** with Agnoster theme
- 🔌 **Zsh plugins**: autosuggestions, syntax highlighting, history substring search, fzf
- 🛠️ **Modern CLI tools**: eza, bat, ripgrep, fzf, zoxide, gh
- 📦 **Development tools**: NVM, Go, Python, Java
- 🖥️ **Terminals**: iTerm2 with Nerd Font, kitty with iTerm2-style keybindings
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
- ✅ Optionally install Node.js LTS
- ✅ Run tests to verify everything works

**That's it!** The setup script handles everything for you.

### Non-Interactive Setup

For automation or CI/CD environments:

```bash
# Install everything with defaults
./setup.sh --non-interactive

# Or customize with options
./setup.sh --non-interactive --install-node --skip-tests

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
- `--install-node` - Install Node.js LTS
- `--skip-tests` - Skip running tests
- `-h, --help` - Show help message

### What Gets Installed

The setup script installs:
- **Zsh Configuration** - Modular config files in `~/.zsh/` directory
- **Homebrew** - Automatically detects Intel/Apple Silicon Macs
- **Oh My Zsh** with plugins (autosuggestions, syntax highlighting, etc.)
- **CLI Tools** - eza, bat, ripgrep, fzf, zoxide, fd, neovim, gh
- **Development Tools** - NVM, Go, Python 3.11, Java, pipx
- **iTerm2** - Installed and configured with Nerd Font (MesloLGS NF)
- **kitty** - Installed with iTerm2-style keybindings (`~/.config/kitty/kitty.conf`)
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

### Terminal Emulators
- **iTerm2** - Installed and configured with MesloLGS NF font; dynamic profile `mac-setup` set as default
- **kitty** - Installed with a custom `kitty.conf` that mirrors iTerm2 keybindings (Cmd+T tabs, Cmd+D splits, Cmd+Opt+Arrow navigation, etc.). Config lives at `~/.config/kitty/kitty.conf`; reload with `Cmd+,`.

### Development Tools
- **NVM** - Node Version Manager
- **Go** - Go programming language
- **Python 3.11** - Python interpreter
- **OpenJDK** - Java Development Kit
- **pipx** - Python application installer
- **Claude Code CLI** - AI-powered coding assistant with helpful shell functions

### Git Configuration
The setup script automatically configures Git with:
- **Default branch**: Set to `main`
- **Pull strategy**: Uses rebase by default
- **GPG signing**: Enabled for commits with signing key configured
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
chmod +x install.sh setup.sh test.sh
```

### Oh My Zsh plugins not working

Make sure plugins are installed in `~/.oh-my-zsh/custom/plugins/`. Run `setup.sh` to install them automatically.

### PATH issues

Check `~/.zsh/exports.zsh` and ensure all paths are correct for your system.

## License

MIT

---

**Copyright © 2025 Igor Vigasin**

Created with ❤️ by Igor Vigasin
