# uncomment to profile
# zmodload zsh/zprof

# =====================================
# Base Configuration
# =====================================

# History settings
SAVEHIST=5000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY

# Prevent accidental exit with Ctrl+D
set -o ignoreeof

# Use -C to only check for completion fields when .zompdump is missing or outdated
autoload -Uz compinit && compinit -C

# Add custom completions to fpath
fpath=(~/.zcomp $fpath)

# =====================================
# Source Modular Configuration
# =====================================

DOTFILES_DIR=~/dotfiles

# Load all modular zsh configurations
source ${DOTFILES_DIR}/zsh/tools.zsh
source ${DOTFILES_DIR}/zsh/plugins.zsh
source ${DOTFILES_DIR}/zsh/aliases.zsh
source ${DOTFILES_DIR}/zsh/functions.zsh

# uncomment to profile
# zprof

# 10x shell integration
# source /Users/charlieduong/.10x/shell-integration.sh
