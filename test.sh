#!/bin/bash

# Installation Test Script
# Verifies that the Mac CLI setup is correctly installed

set +e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNED=0
TESTS_TOTAL=0
CRITICAL_FAILED=0

run_test() {
    local test_name="$1"
    local is_critical="$2"
    shift 2

    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    printf "Testing: %-52s" "$test_name..."

    local output
    output=$("$@" 2>&1)
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        if [ "$is_critical" = "true" ]; then
            echo -e "${RED}✗ FAILED${NC}"
            [ -n "$output" ] && echo -e "    ${RED}→ $output${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            CRITICAL_FAILED=$((CRITICAL_FAILED + 1))
        else
            echo -e "${YELLOW}⚠ WARNING${NC}"
            [ -n "$output" ] && echo -e "    ${YELLOW}→ $output${NC}"
            TESTS_WARNED=$((TESTS_WARNED + 1))
        fi
        return 1
    fi
}

file_exists()    { [ -f "$1" ]; }
dir_exists()     { [ -d "$1" ]; }
command_exists() { command -v "$1" >/dev/null 2>&1; }
grep_file()      { grep -q "$1" "$2"; }
symlink_exists() { [ -L "$1" ]; }

echo -e "${BLUE}🧪 Mac CLI Setup - Installation Test${NC}"
echo "=========================================="
echo ""

# ---------------------------------------------------------------------------
echo -e "${BLUE}Zsh Config Files:${NC}"
run_test ".zshrc exists"          true  file_exists "$HOME/.zshrc"
run_test ".zsh directory exists"  true  dir_exists  "$HOME/.zsh"

if [ -d "$HOME/.zsh" ]; then
    for f in config exports aliases functions history options tools; do
        run_test "$f.zsh exists" true file_exists "$HOME/.zsh/$f.zsh"
    done
else
    echo -e "${YELLOW}⚠ Skipping config file tests (.zsh directory not found)${NC}"
fi

# ---------------------------------------------------------------------------
echo ""
echo -e "${BLUE}Config Content:${NC}"
if [ -f "$HOME/.zshrc" ]; then
    run_test ".zshrc sources .zsh/*.zsh files" true \
        grep_file '\.zsh/' "$HOME/.zshrc"
fi
if [ -f "$HOME/.zsh/aliases.zsh" ]; then
    run_test "ls aliased to eza"      true  grep_file "alias ls='eza"        "$HOME/.zsh/aliases.zsh"
    run_test "ll aliased to eza -l"   true  grep_file "alias ll='eza"        "$HOME/.zsh/aliases.zsh"
    run_test "la aliased to eza -la"  true  grep_file "alias la='eza"        "$HOME/.zsh/aliases.zsh"
    run_test "cat aliased to bat"     true  grep_file "alias cat='bat"       "$HOME/.zsh/aliases.zsh"
    run_test "vi aliased to nvim"     true  grep_file "alias vi='nvim'"      "$HOME/.zsh/aliases.zsh"
    run_test "python aliased to python3" true grep_file "alias python=python3" "$HOME/.zsh/aliases.zsh"
    run_test "pip aliased to pip3"    true  grep_file "alias pip=pip3"       "$HOME/.zsh/aliases.zsh"
    run_test "grep aliased to rg"     true  grep_file "alias grep='rg'"      "$HOME/.zsh/aliases.zsh"
    run_test "claude alias defined"   false grep_file "alias claude="        "$HOME/.zsh/aliases.zsh"
    run_test "cc alias defined"       false grep_file "alias cc='claude'"    "$HOME/.zsh/aliases.zsh"
fi
if [ -f "$HOME/.zsh/functions.zsh" ]; then
    run_test "mkcd function defined"    true  grep_file 'mkcd()'   "$HOME/.zsh/functions.zsh"
    run_test "ccstart function defined" false grep_file 'ccstart()' "$HOME/.zsh/functions.zsh"
    run_test "ccfile function defined"  false grep_file 'ccfile()'  "$HOME/.zsh/functions.zsh"
    run_test "ccgit function defined"   false grep_file 'ccgit()'   "$HOME/.zsh/functions.zsh"
    run_test "ccask function defined"   false grep_file 'ccask()'   "$HOME/.zsh/functions.zsh"
    run_test "ccnew function defined"   false grep_file 'ccnew()'   "$HOME/.zsh/functions.zsh"
fi
if [ -f "$HOME/.zsh/exports.zsh" ]; then
    run_test "EDITOR exported"           true  grep_file 'export EDITOR'           "$HOME/.zsh/exports.zsh"
    run_test "VISUAL exported"           true  grep_file 'export VISUAL'            "$HOME/.zsh/exports.zsh"
    run_test "LANG exported"             true  grep_file 'export LANG'              "$HOME/.zsh/exports.zsh"
    run_test "LC_ALL exported"           true  grep_file 'export LC_ALL'            "$HOME/.zsh/exports.zsh"
    run_test "BAT_THEME set to Dracula"  true  grep_file 'BAT_THEME.*Dracula'       "$HOME/.zsh/exports.zsh"
    run_test "FZF_DEFAULT_COMMAND set"   false grep_file 'FZF_DEFAULT_COMMAND'      "$HOME/.zsh/exports.zsh"
    run_test "FZF_DEFAULT_OPTS set"      false grep_file 'FZF_DEFAULT_OPTS'         "$HOME/.zsh/exports.zsh"
fi
if [ -f "$HOME/.zsh/config.zsh" ]; then
    run_test "Agnoster theme configured"         true  grep_file 'agnoster'                 "$HOME/.zsh/config.zsh"
    run_test "zsh-autosuggestions plugin listed" true  grep_file 'zsh-autosuggestions'      "$HOME/.zsh/config.zsh"
    run_test "zsh-syntax-highlighting listed"    true  grep_file 'zsh-syntax-highlighting'  "$HOME/.zsh/config.zsh"
fi
if [ -f "$HOME/.zsh/tools.zsh" ]; then
    run_test "fzf sourced in tools.zsh"    false grep_file '\.fzf\.zsh'       "$HOME/.zsh/tools.zsh"
    run_test "zoxide init in tools.zsh"    false grep_file 'zoxide init'       "$HOME/.zsh/tools.zsh"
fi

# ---------------------------------------------------------------------------
echo ""
echo -e "${BLUE}Zsh Runtime:${NC}"
if [ -f "$HOME/.zshrc" ]; then
    run_test "zsh sources .zshrc without errors" true \
        zsh -c "source $HOME/.zshrc"
fi
run_test "mkcd creates and enters directory" true \
    zsh -c "source $HOME/.zsh/functions.zsh 2>/dev/null; tmp=\$(mktemp -d); cd \"\$tmp\"; mkcd testdir && [ \"\$(pwd)\" = \"\$tmp/testdir\" ]; rc=\$?; rm -rf \"\$tmp\"; exit \$rc"

# ---------------------------------------------------------------------------
echo ""
echo -e "${BLUE}Oh My Zsh:${NC}"
run_test "Oh My Zsh directory exists"  false dir_exists "$HOME/.oh-my-zsh"
run_test "Oh My Zsh main script"       false file_exists "$HOME/.oh-my-zsh/oh-my-zsh.sh"
run_test "zsh-autosuggestions cloned"  false dir_exists "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
run_test "zsh-syntax-highlighting cloned" false dir_exists "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
run_test "history-substring-search cloned" false \
    dir_exists "$HOME/.oh-my-zsh/custom/plugins/zsh-history-substring-search"

# ---------------------------------------------------------------------------
echo ""
echo -e "${BLUE}CLI Tools:${NC}"
run_test "eza installed"    false command_exists eza
run_test "bat installed"    false command_exists bat
run_test "rg installed"     false command_exists rg
run_test "fzf installed"    false command_exists fzf
run_test "zoxide installed" false command_exists zoxide
run_test "fd installed"     false command_exists fd
run_test "neovim installed" false command_exists nvim
run_test "mc installed"     false command_exists mc
run_test "gh installed"     false command_exists gh
run_test "git-secrets installed" false bash -c "command -v git-secrets >/dev/null 2>&1 || git secrets --version >/dev/null 2>&1 || brew list git-secrets >/dev/null 2>&1"
run_test "Ghostty installed" false bash -c "[ -d /Applications/Ghostty.app ] || brew list --cask ghostty >/dev/null 2>&1"
run_test "VS Code installed" false bash -c "[ -d '/Applications/Visual Studio Code.app' ] || brew list --cask visual-studio-code >/dev/null 2>&1"
run_test "code CLI available"  false command_exists code
run_test "Ghostty config installed" false file_exists "$HOME/.config/ghostty/config"

if command_exists bat; then
    run_test "bat --version succeeds" false bash -c "bat --version >/dev/null"
fi
if command_exists fzf; then
    run_test "fzf key bindings configured (~/.fzf.zsh)" false file_exists "$HOME/.fzf.zsh"
fi

# ---------------------------------------------------------------------------
echo ""
echo -e "${BLUE}Development Tools:${NC}"
run_test "Homebrew installed" false command_exists brew

if command_exists brew; then
    BREW_PREFIX=$(brew --prefix)
    run_test "Homebrew in PATH" false bash -c "echo \"\$PATH\" | grep -q \"$BREW_PREFIX\""
fi

run_test "NVM directory exists" false dir_exists "$HOME/.nvm"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null
run_test "Node.js available"  false command_exists node
run_test "npm available"      false command_exists npm

run_test "Go installed"       false command_exists go
run_test "Python 3 installed" false command_exists python3
run_test "Python >= 3.11" false bash -c "
    for py in python3.11 python3.12 python3.13 /opt/homebrew/bin/python3 python3; do
        if command -v \"\$py\" >/dev/null 2>&1; then
            \"\$py\" -c 'import sys; exit(0 if sys.version_info >= (3,11) else 1)' && exit 0
        fi
    done
    exit 1
"
run_test "pipx installed" false command_exists pipx
run_test "Java installed"  false bash -c "command -v java >/dev/null 2>&1 || [ -d /opt/homebrew/opt/openjdk ] || [ -d /usr/local/opt/openjdk ]"

# ---------------------------------------------------------------------------
echo ""
echo -e "${BLUE}Claude Code:${NC}"
run_test "claude CLI installed"      false command_exists claude
run_test "claude symlink in Homebrew bin" false bash -c '[ -L /opt/homebrew/bin/claude ] || [ -L /usr/local/bin/claude ]'
if command_exists claude; then
    run_test "claude --version succeeds" false claude --version
fi
run_test "Claude Code authenticated" false \
    bash -c "claude auth status 2>/dev/null | grep -q '\"loggedIn\": true' || [ -n \"\$ANTHROPIC_API_KEY\" ]"

# ---------------------------------------------------------------------------
echo ""
echo -e "${BLUE}Git Configuration:${NC}"
if command_exists git; then
    run_test "git user.name set"          false bash -c "git config --global user.name | grep -q ."
    run_test "git user.email set"         false bash -c "git config --global user.email | grep -q ."
    run_test "default branch is main"     false bash -c "git config --global init.defaultBranch | grep -q main"
    run_test "pull.rebase enabled"        false bash -c "git config --global pull.rebase | grep -q true"
    # Signing is only enabled when a usable secret key exists; either value is valid.
    run_test "commit.gpgsign configured"  false bash -c "git config --global commit.gpgsign | grep -qE 'true|false'"
    run_test "credential helper set"      false bash -c "git config --global credential.helper | grep -q ."
    run_test "git alias st defined"       false bash -c "git config --global alias.st | grep -q ."
    run_test "git alias lg defined"       false bash -c "git config --global alias.lg | grep -q ."
    run_test "git alias lola defined"     false bash -c "git config --global alias.lola | grep -q ."
else
    echo -e "${YELLOW}⚠ Skipping git tests (git not installed)${NC}"
fi

# ---------------------------------------------------------------------------
echo ""
echo "=========================================="
echo -e "${BLUE}Test Summary:${NC}"
echo -e "  Total:    $TESTS_TOTAL"
echo -e "  ${GREEN}Passed:   $TESTS_PASSED${NC}"
[ $TESTS_FAILED -gt 0 ] && echo -e "  ${RED}Failed:   $TESTS_FAILED${NC}"
[ $TESTS_WARNED -gt 0 ] && echo -e "  ${YELLOW}Warnings: $TESTS_WARNED${NC}"

if [ $TESTS_TOTAL -gt 0 ]; then
    echo -e "  Rate:     $((TESTS_PASSED * 100 / TESTS_TOTAL))%"
fi
echo ""

if [ $CRITICAL_FAILED -eq 0 ]; then
    if [ $TESTS_WARNED -gt 0 ]; then
        echo -e "${GREEN}✅ Critical tests passed!${NC}"
        echo -e "${YELLOW}⚠️  Some optional components are missing. Run ./setup.sh to install them.${NC}"
    else
        echo -e "${GREEN}🎉 All tests passed!${NC}"
    fi
    exit 0
else
    echo -e "${RED}❌ Critical tests failed. Run ./setup.sh to fix the setup.${NC}"
    exit 1
fi
