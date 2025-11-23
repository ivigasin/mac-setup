# Mac CLI Setup

Automated setup script for configuring a new Mac with my preferred CLI tools and zsh configuration.

## Features

- 🪄 **Interactive Wizard** - One-command setup with guided configuration
- 🎨 **Oh My Zsh** with Agnoster theme
- 🔌 **Zsh plugins**: autosuggestions, syntax highlighting, history substring search, fzf
- 🛠️ **Modern CLI tools**: eza, bat, ripgrep, fzf, zoxide
- 📦 **Development tools**: NVM, Go, Python, Java
- 📁 **Modular configuration**: Split into organized files
- ⚙️ **Git configuration**: Automatic setup with GPG signing, aliases, and color schemes

## Quick Start

### 🪄 Automated Setup (Recommended)

The easiest way to set up everything is using the interactive wizard:

```bash
git clone <your-repo-url> ~/mac-setup
cd ~/mac-setup
./wizard.sh
```

The wizard will:
- ✅ Collect your Git configuration (name, email, GPG key)
- ✅ Let you choose what to install
- ✅ Run all installation steps automatically
- ✅ Optionally install Node.js LTS
- ✅ Run tests to verify everything works

**That's it!** The wizard handles everything for you.

### Manual Setup

If you prefer to run the steps manually:

#### 1. Clone this repository

```bash
git clone <your-repo-url> ~/mac-setup
cd ~/mac-setup
```

#### 2. Install zsh configuration

```bash
./install.sh
```

This will:
- Create `~/.zsh` directory
- Copy all configuration files
- Install `.zshrc` (backing up existing one if present)

#### 3. Install dependencies

```bash
./setup.sh
```

This will install:
- **Homebrew** (if not installed) - Automatically detects Intel/Apple Silicon and configures PATH
- Oh My Zsh
- Required zsh plugins
- CLI tools (eza, bat, ripgrep, fzf, zoxide, etc.)
- Development tools (NVM, Go, Python, Java)
- pipx
- **Git configuration** - Sets up common Git settings, aliases, and prompts for user name/email if not configured

**Note:** Homebrew installation is fully automated and handles:
- ✅ Automatic detection of Intel vs Apple Silicon Macs
- ✅ PATH configuration for current session and persistence
- ✅ Error handling and verification
- ✅ Automatic updates after installation

#### 4. Test the installation

```bash
./test.sh
```

This will verify that:
- All configuration files are in place
- Required tools are installed
- Zsh configuration loads correctly
- Aliases and functions are defined

#### 5. Restart your terminal

```bash
source ~/.zshrc
```

Or simply open a new terminal window.

## Manual Installation

If you prefer to install manually:

1. Copy `.zsh` directory to `~/.zsh`
2. Copy `.zshrc` to `~/.zshrc`
3. Install dependencies manually (see `setup.sh` for reference)

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

### Development Tools
- **NVM** - Node Version Manager
- **Go** - Go programming language
- **Python 3.11** - Python interpreter
- **OpenJDK** - Java Development Kit
- **pipx** - Python application installer

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
./install.sh
./test.sh  # Verify the update
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

**Copyright © 2024 Igor Vigasin**

Created with ❤️ by Igor Vigasin
