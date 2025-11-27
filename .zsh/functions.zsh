# Custom Functions

# Create directory and cd into it
mkcd(){ mkdir -p "$1" && cd "$1"; }

# Claude Code helper functions

# Initialize Claude Code in current directory with optional message
ccstart() {
    if [ ! -f ".claude/settings.json" ]; then
        echo "Initializing Claude Code in $(pwd)..."
        claude --init
    fi
    if [ -n "$1" ]; then
        claude "$1"
    else
        claude
    fi
}

# Run Claude Code with a specific file context
ccfile() {
    if [ -z "$1" ]; then
        echo "Usage: ccfile <file> [message]"
        return 1
    fi
    if [ ! -f "$1" ]; then
        echo "Error: File '$1' not found"
        return 1
    fi
    if [ -n "$2" ]; then
        claude --file "$1" "$2"
    else
        claude --file "$1"
    fi
}

# Run Claude Code on git changes
ccgit() {
    local message="${1:-Review my changes}"
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository"
        return 1
    fi
    claude "$message"
}

# Quick Claude Code chat
ccask() {
    if [ -z "$1" ]; then
        echo "Usage: ccask <question>"
        return 1
    fi
    claude "$@"
}

# Create a new project with Claude Code setup
ccnew() {
    if [ -z "$1" ]; then
        echo "Usage: ccnew <project-name>"
        return 1
    fi
    mkdir -p "$1" && cd "$1" && claude --init
    echo "Created new project: $1"
}
