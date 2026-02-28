

#
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set your theme
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
plugins=(git z sudo)

# zsh-autosuggestions config (must be set before the plugin is sourced)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Source plugins explicitly — more reliable than Oh My Zsh plugin array in Docker
source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- THE CLEANUP PART ---
# Load all custom config files from your dedicated directory
if [ -d "$HOME/.zsh_custom" ]; then
  for file in "$HOME/.zsh_custom"/*.zsh; do
    source "$file"
  done
fi
# User configuration







# Aliases
# navigation
alias ui="cd apps/builder/ui"
alias api="cd apps/builder/api"
alias base="cd ../../.."

# navigation
alias ptests="make test-builder-backend && cd apps/builder/api && uv run pytest --testmon -xvs"

# frontend checks
alias formatf="pnpm run format"
alias typecheckf="pnpm run check-types"
alias lintf="pnpm run lint"
alias testf="pnpm run test"
alias checkf="formatf && typecheckf && testf"

# backend checks
alias lintb="uv run ruff check . --fix"
alias formatb="uv run ruff format"

# docker
alias stopall='docker stop $(docker ps -q)'
alias serve="make serve"
alias run="make open"
