# Load antidote plugin manager
if [[ "$(uname)" == "Linux" ]]; then
  source ~/.antidote/antidote.zsh
elif [[ "$(uname)" == "Darwin" ]]; then
  source ${HOMEBREW_PREFIX}/opt/antidote/share/antidote/antidote.zsh
fi

# Check if plugins cache exists, regenerate if needed
if [[ ! -f ${ZDOTDIR:-$HOME}/.zsh_plugins.zsh || ${ZDOTDIR:-$HOME}/.zsh_plugins.txt -nt ${ZDOTDIR:-$HOME}/.zsh_plugins.zsh ]]; then
  antidote bundle < ${ZDOTDIR:-$HOME}/.zsh_plugins.txt > ${ZDOTDIR:-$HOME}/.zsh_plugins.zsh
fi

# Source plugins
source ${ZDOTDIR:-$HOME}/.zsh_plugins.zsh

# Vi mode
bindkey -v

# Register the TV git branches widget
zle -N _tv_git_branches

# Git branches picker using television
_tv_git_branches() {
  local result=$(tv git-branches)
  if [[ -n "$result" ]]; then
    LBUFFER+="$result"
  fi
  zle reset-prompt
}

# Configure Claude Code agent mode
export CLAUDE_AGENT_CMD="claude"
export CLAUDE_AGENT_BASE_ARGS="--add-dir ~/.ai/plans --dangerously-skip-permissions"
export CLAUDE_AGENT_FAST_ARGS="--model haiku -p"
export CLAUDE_AGENT_CMD_ARGS="--model haiku -p"
export CLAUDE_AGENT_INTERACTIVE_ARGS=""
export CLAUDE_AGENT_DEFAULT_MODE="fast"
export CLAUDE_AGENT_STREAM_PARSER="$HOME/dotfiles/claude-agent-mode/cc-stream-parser"

# Load Claude Code agent mode integration
source ~/dotfiles/claude-agent-mode/claude-code-agent.zsh

# ZVM after init hook (for keybindings)
function zvm_after_init() {
  # install fzf keybindings
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  # enable fzf-git
  [ -f ~/.fzf-git.sh/fzf-git.sh ] && source ~/.fzf-git.sh/fzf-git.sh

  # Use regular bindkey for custom widgets
  bindkey -M viins '^K' autosuggest-accept
  bindkey -M viins '^G' _tv_git_branches  # Ctrl+G

  # Setup Claude Code agent mode keybindings
  setup-claude-agent-keybindings
}
