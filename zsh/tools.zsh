# Tool initializations

# Homebrew (if available)
if [ -f '/opt/homebrew/bin/brew' ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Zoxide (better cd)
if type zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# Mise (runtime version manager)
eval "$(/Users/charlieduong/.local/bin/mise activate zsh)"

# Starship prompt
eval "$(starship init zsh)"

# Turso CLI
. "$HOME/.turso/env"

# Additional PATH entries
export PATH="/Users/charlieduong/.opencode/bin:$PATH"
export PATH="/Users/charlieduong/bin:$PATH"

# LM Studio CLI
export PATH="$PATH:/Users/charlieduong/.lmstudio/bin"

# Source additional scripts
source ~/dotfiles/scripts/wt

# OrbStack integration (commented out)
# source ~/.orbstack/shell/init.zsh 2>/dev/null || :