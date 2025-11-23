# Oh My Zsh Configuration

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="agnoster"

# Which plugins would you like to load?
plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
	history-substring-search
	fzf
)

source $ZSH/oh-my-zsh.sh
