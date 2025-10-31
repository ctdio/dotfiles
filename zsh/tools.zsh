# Tool initializations

# Homebrew (if available)
if [ -f '/opt/homebrew/bin/brew' ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Zoxide (better cd)
if type zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# Starship prompt with smart git caching
eval "$(starship init zsh)"

# Smart git status caching for worktree repos
# Only refresh git status after git commands or directory changes
_LAST_PWD=""
_REFRESH_GIT_STATUS=1

# Hook before command execution
function starship_precmd() {
  # Check if directory changed
  if [[ "$PWD" != "$_LAST_PWD" ]]; then
    _REFRESH_GIT_STATUS=1
    _LAST_PWD="$PWD"
  fi

  # In platform repo with worktrees, use cached status unless refresh needed
  if [[ "$PWD" == *"/platform"* ]] && [[ "$_REFRESH_GIT_STATUS" -eq 0 ]]; then
    # Skip expensive git status checks by temporarily disabling
    STARSHIP_GIT_STATUS_DISABLED=1
  else
    unset STARSHIP_GIT_STATUS_DISABLED
    _REFRESH_GIT_STATUS=0
  fi
}

# Hook after command execution - detect git commands
function starship_preexec() {
  case "$1" in
    git*|g\ *|gst|gco|gaa|gcmsg|gp|gl|gd|gs)
      # Next prompt should refresh git status
      _REFRESH_GIT_STATUS=1
      ;;
  esac
}

# Register hooks
autoload -U add-zsh-hook
add-zsh-hook precmd starship_precmd
add-zsh-hook preexec starship_preexec

if [ -f ${HOME}/.turso/env ]; then
  # Turso CLI
  . "${HOME}/.turso/env"
fi

# Additional PATH entries
export PATH="/Users/charlieduong/.opencode/bin:$PATH"
export PATH="/Users/charlieduong/bin:$PATH"

# LM Studio CLI
export PATH="$PATH:/Users/charlieduong/.lmstudio/bin"

# Source additional scripts
source ~/dotfiles/scripts/wt

# OrbStack integration (commented out)
# source ~/.orbstack/shell/init.zsh 2>/dev/null || :
