#!/usr/bin/env bash
# =============================================================================
# uninstall.sh — Reverse everything installed/configured by setup.sh
# =============================================================================
# Removes: zsh config, Homebrew packages & casks, Oh My Zsh + plugins, NVM,
# pipx, FZF config, Ghostty config, and the Git settings/aliases setup.sh adds.
#
# By default it does NOT remove Homebrew itself or your Git identity
# (user.name/email/signingkey) — those are opt-in via flags.
#
# Usage:
#   ./uninstall.sh                     # interactive, asks for confirmation
#   ./uninstall.sh --non-interactive   # no prompts (alias: -y)
#   ./uninstall.sh --dry-run           # print what would happen, change nothing
#   ./uninstall.sh --remove-homebrew   # also uninstall Homebrew entirely
#   ./uninstall.sh --purge-git-identity# also unset git user.name/email/signingkey
#   ./uninstall.sh -h | --help
# =============================================================================

# NOTE: intentionally NOT using `set -e` — one failed removal shouldn't abort
# the whole cleanup. Individual commands are guarded with `|| true`.

# ----- Colors ---------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ----- Paths ----------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

# ----- Flags ----------------------------------------------------------------
INTERACTIVE_MODE=true
DRY_RUN=false
REMOVE_HOMEBREW=false
PURGE_GIT_IDENTITY=false

# =============================================================================
# Helpers
# =============================================================================
command_exists() { command -v "$1" &>/dev/null; }

# run <description> <command...> — respects --dry-run
run() {
    local desc="$1"; shift
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${CYAN}[dry-run]${NC} $desc"
        return 0
    fi
    echo -e "  ${YELLOW}➜${NC} $desc"
    "$@" 2>/dev/null || true
}

confirm() {
    [ "$INTERACTIVE_MODE" = false ] && return 0
    local reply
    printf "%b" "${CYAN}$1 [y/N]: ${NC}"
    read -r reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

show_help() {
    cat <<EOF
${BOLD}uninstall.sh${NC} — reverse everything installed by setup.sh

Options:
  --non-interactive, -y   Run without confirmation prompts
  --dry-run               Show what would be removed without removing anything
  --remove-homebrew       Also uninstall Homebrew entirely (DESTRUCTIVE)
  --purge-git-identity    Also unset git user.name / user.email / user.signingkey
  -h, --help              Show this help

By default Homebrew itself and your Git identity are preserved.
EOF
}

# =============================================================================
# Removal steps
# =============================================================================

remove_zsh_config() {
    echo -e "${BOLD}${BLUE}Removing Zsh configuration${NC}"

    # Restore backup if setup.sh made one, otherwise remove our .zshrc
    if [ -f "$HOME_DIR/.zshrc.backup" ]; then
        run "restore ~/.zshrc from ~/.zshrc.backup" bash -c \
            'mv -f "$HOME/.zshrc.backup" "$HOME/.zshrc"'
    elif [ -f "$HOME_DIR/.zshrc" ]; then
        run "remove ~/.zshrc" rm -f "$HOME_DIR/.zshrc"
    fi

    [ -d "$HOME_DIR/.zsh" ] && run "remove ~/.zsh/ directory" rm -rf "$HOME_DIR/.zsh"
    echo ""
}

remove_brew_packages() {
    echo -e "${BOLD}${BLUE}Removing Homebrew packages${NC}"
    if ! command_exists brew; then
        echo -e "  ${YELLOW}⚠️  brew not found — skipping${NC}"
        echo ""
        return
    fi

    local packages=(
        eza bat ripgrep fzf zoxide fd neovim go
        "python@3.11" openjdk gnupg pinentry-mac gh pipx
    )
    for pkg in "${packages[@]}"; do
        if brew list "$pkg" &>/dev/null; then
            run "uninstall $pkg" brew uninstall --ignore-dependencies "$pkg"
        else
            echo -e "  ${GREEN}✓${NC} $pkg not installed"
        fi
    done

    local casks=(
        ghostty claude-code font-meslo-lg-nerd-font font-hack-nerd-font
    )
    for cask in "${casks[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            run "uninstall cask $cask" brew uninstall --cask "$cask"
        else
            echo -e "  ${GREEN}✓${NC} cask $cask not installed"
        fi
    done
    echo ""
}

remove_fzf_config() {
    echo -e "${BOLD}${BLUE}Removing FZF configuration${NC}"
    [ -f "$HOME_DIR/.fzf.zsh" ] && run "remove ~/.fzf.zsh" rm -f "$HOME_DIR/.fzf.zsh"
    [ -f "$HOME_DIR/.fzf.bash" ] && run "remove ~/.fzf.bash" rm -f "$HOME_DIR/.fzf.bash"
    echo ""
}

remove_ghostty_config() {
    echo -e "${BOLD}${BLUE}Removing Ghostty configuration${NC}"
    if [ -f "$HOME_DIR/.config/ghostty/config" ]; then
        run "remove ~/.config/ghostty/config" rm -f "$HOME_DIR/.config/ghostty/config"
        # remove the dir only if now empty
        run "remove ~/.config/ghostty (if empty)" rmdir "$HOME_DIR/.config/ghostty"
    else
        echo -e "  ${GREEN}✓${NC} no Ghostty config found"
    fi
    echo ""
}

remove_oh_my_zsh() {
    echo -e "${BOLD}${BLUE}Removing Oh My Zsh and plugins${NC}"
    if [ -d "$HOME_DIR/.oh-my-zsh" ]; then
        run "remove ~/.oh-my-zsh" rm -rf "$HOME_DIR/.oh-my-zsh"
    else
        echo -e "  ${GREEN}✓${NC} Oh My Zsh not installed"
    fi
    echo ""
}

remove_nvm() {
    echo -e "${BOLD}${BLUE}Removing NVM${NC}"
    if [ -d "$HOME_DIR/.nvm" ]; then
        run "remove ~/.nvm" rm -rf "$HOME_DIR/.nvm"
    else
        echo -e "  ${GREEN}✓${NC} NVM not installed"
    fi
    echo ""
}

remove_git_config() {
    echo -e "${BOLD}${BLUE}Reverting Git configuration${NC}"
    if ! command_exists git; then
        echo -e "  ${YELLOW}⚠️  git not found — skipping${NC}"
        echo ""
        return
    fi

    local settings=(
        init.defaultBranch pull.rebase commit.gpgsign credential.helper
    )
    local aliases=(
        st ci br co df dc lg who lp undo lol lola ls git grog unlock
    )
    local color_keys=(
        color.ui
        color.branch.current color.branch.local color.branch.remote
        color.diff.meta color.diff.frag color.diff.old color.diff.new
        color.status.added color.status.changed color.status.untracked
    )

    for key in "${settings[@]}"; do
        run "unset $key" git config --global --unset "$key"
    done
    for a in "${aliases[@]}"; do
        run "unset alias.$a" git config --global --unset "alias.$a"
    done
    for key in "${color_keys[@]}"; do
        run "unset $key" git config --global --unset "$key"
    done

    if [ "$PURGE_GIT_IDENTITY" = true ]; then
        echo -e "  ${YELLOW}Purging git identity...${NC}"
        run "unset user.name"       git config --global --unset user.name
        run "unset user.email"      git config --global --unset user.email
        run "unset user.signingkey" git config --global --unset user.signingkey
    else
        echo -e "  ${CYAN}ℹ️  Keeping git identity (user.name/email/signingkey). Use --purge-git-identity to remove.${NC}"
    fi
    echo ""
}

remove_homebrew() {
    echo -e "${BOLD}${BLUE}Removing Homebrew${NC}"
    if ! command_exists brew; then
        echo -e "  ${GREEN}✓${NC} Homebrew not installed"
        echo ""
        return
    fi
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${CYAN}[dry-run]${NC} run official Homebrew uninstall script"
        echo ""
        return
    fi
    echo -e "  ${YELLOW}➜${NC} running official Homebrew uninstaller..."
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)" || true
    echo ""
}

# =============================================================================
# Main
# =============================================================================
main() {
    # Parse args
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --non-interactive|-y) INTERACTIVE_MODE=false ;;
            --dry-run)            DRY_RUN=true ;;
            --remove-homebrew)    REMOVE_HOMEBREW=true ;;
            --purge-git-identity) PURGE_GIT_IDENTITY=true ;;
            -h|--help)            show_help; exit 0 ;;
            *) echo -e "${RED}Unknown option: $1${NC}"; show_help; exit 1 ;;
        esac
        shift
    done

    echo ""
    echo -e "${BOLD}${RED}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${RED}  mac-setup Uninstaller${NC}"
    echo -e "${BOLD}${RED}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "This will remove everything setup.sh installed:"
    echo -e "  • ~/.zshrc (restored from backup if present) and ~/.zsh/"
    echo -e "  • Homebrew packages: eza, bat, ripgrep, fzf, zoxide, fd, neovim,"
    echo -e "    go, python@3.11, openjdk, gnupg, pinentry-mac, gh, pipx"
    echo -e "  • Homebrew casks: ghostty, claude-code, MesloLGS & Hack Nerd Fonts"
    echo -e "  • Oh My Zsh (~/.oh-my-zsh) and plugins"
    echo -e "  • NVM (~/.nvm)"
    echo -e "  • FZF config (~/.fzf.zsh) and Ghostty config (~/.config/ghostty/config)"
    echo -e "  • Git aliases, colors, and settings added by setup.sh"
    echo ""
    if [ "$REMOVE_HOMEBREW" = true ]; then
        echo -e "  ${RED}• Homebrew itself (--remove-homebrew)${NC}"
    else
        echo -e "  ${CYAN}Homebrew itself will be KEPT (use --remove-homebrew to remove).${NC}"
    fi
    if [ "$PURGE_GIT_IDENTITY" = true ]; then
        echo -e "  ${RED}• Git identity: user.name/email/signingkey (--purge-git-identity)${NC}"
    else
        echo -e "  ${CYAN}Git identity will be KEPT (use --purge-git-identity to remove).${NC}"
    fi
    echo ""
    [ "$DRY_RUN" = true ] && echo -e "${BOLD}${CYAN}DRY RUN — nothing will actually be removed.${NC}\n"

    if ! confirm "Proceed with uninstall?"; then
        echo -e "${YELLOW}Aborted. Nothing was changed.${NC}"
        exit 0
    fi
    echo ""

    remove_zsh_config
    remove_fzf_config
    remove_ghostty_config
    remove_brew_packages
    remove_oh_my_zsh
    remove_nvm
    remove_git_config
    [ "$REMOVE_HOMEBREW" = true ] && remove_homebrew

    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
    if [ "$DRY_RUN" = true ]; then
        echo -e "${BOLD}${GREEN}✅ Dry run complete — no changes made.${NC}"
    else
        echo -e "${BOLD}${GREEN}✅ Uninstall complete.${NC}"
        echo -e "${CYAN}Open a new terminal (or your default shell) for changes to take effect.${NC}"
    fi
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

main "$@"
