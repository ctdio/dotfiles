# uncomment to profile
# zmodload zsh/zprof

# =====================================
# Base Configuration
# =====================================

# Add dotfiles bin to PATH
export PATH="$HOME/dotfiles/bin:$PATH"

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY

# Prevent accidental exit with Ctrl+D
set -o ignoreeof

# Set GPG_TTY for SSH agent passphrase prompts (gpg-agent)
if [[ "$(uname)" == "Linux" ]]; then
  export GPG_TTY=$(tty)
fi

DOTFILES_DIR=~/dotfiles

# Load tools first (sets up fpath)
source ${DOTFILES_DIR}/zsh/tools.zsh

# Add custom completions to fpath (after tools, before compinit)
fpath=(~/.zcomp $fpath)

# Fast compinit - use compiled cache
# Regenerate with: rm ~/.zcompdump* && compinit && zcompile ~/.zcompdump
autoload -Uz compinit && compinit -C

# Load remaining configurations
source ${DOTFILES_DIR}/zsh/plugins.zsh
source ${DOTFILES_DIR}/zsh/aliases.zsh
source ${DOTFILES_DIR}/zsh/functions.zsh

# uncomment to profile
# zprof

# 10x shell integration
# source /Users/charlieduong/.10x/shell-integration.sh
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
