# Ultra-fast plugin loading with zsh-defer
# Plugins are stored in ~/dotfiles/zsh/plugins/
# To update: cd ~/dotfiles/zsh/plugins/<plugin> && git pull

DOTFILES_ZSH="${DOTFILES_DIR:-$HOME/dotfiles}/zsh"

# ============================================================================
# Load zsh-defer first (tiny, enables deferred loading)
# ============================================================================
source "$DOTFILES_ZSH/plugins/zsh-defer/zsh-defer.plugin.zsh"

# ============================================================================
# Immediate loads (must be instant for usability)
# ============================================================================

# Vi mode - must be immediate for typing
bindkey -v

# Basic keybindings that must work immediately
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'vv' edit-command-line

# ============================================================================
# Deferred loads - run after first prompt renders
# ============================================================================

# Autosuggestions (~4ms but feels slow if visible delay)
zsh-defer source "$DOTFILES_ZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Syntax highlighting
zsh-defer source "$DOTFILES_ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Claude Code integration - exports are immediate, source is deferred
export CLAUDE_AGENT_CMD="claude"
export CLAUDE_AGENT_BASE_ARGS="--add-dir ~/.ai/plans --dangerously-skip-permissions"
export CLAUDE_AGENT_FAST_ARGS="--model haiku -p"
export CLAUDE_AGENT_CMD_ARGS="--model haiku -p"
export CLAUDE_AGENT_INTERACTIVE_ARGS=""
export CLAUDE_AGENT_DEFAULT_MODE="fast"
export CLAUDE_AGENT_STREAM_PARSER="$HOME/dotfiles/shell-integrations/zsh/agent-stream-parser/agent-stream-parser"
export CLAUDE_AGENT_ENABLE_TERMINAL_CONTEXT="1"
export CLAUDE_AGENT_TERMINAL_CONTEXT_LINES="50"

zsh-defer source ~/dotfiles/shell-integrations/zsh/claude-code-zsh-integration.zsh

# ============================================================================
# Lazy-loaded plugins - load on first use
# ============================================================================

# zsh-vi-mode - load on first Escape press
_zvm_loaded=0
_load_zvm() {
  (( _zvm_loaded )) && return
  _zvm_loaded=1
  source "$DOTFILES_ZSH/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
  (( ${+functions[zvm_after_init]} )) && zvm_after_init
}

_lazy_vi_cmd_mode() {
  if (( ! _zvm_loaded )); then
    _load_zvm
    zle zvm_vi_vicmd_mode 2>/dev/null || zle vi-cmd-mode
  else
    zle vi-cmd-mode
  fi
}
zle -N _lazy_vi_cmd_mode
bindkey -M viins '\e' _lazy_vi_cmd_mode

# fzf - load on first Ctrl+R or Ctrl+T
_fzf_loaded=0
_load_fzf() {
  (( _fzf_loaded )) && return
  _fzf_loaded=1

  if [[ -f ~/.fzf.zsh ]]; then
    # macOS / Homebrew / manual install
    source ~/.fzf.zsh
  else
    # Debian/Ubuntu package locations
    [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
    [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
  fi

  [[ -f ~/.fzf-git.sh/fzf-git.sh ]] && source ~/.fzf-git.sh/fzf-git.sh
}

# ============================================================================
# Widgets
# ============================================================================

_tv_git_branches() {
  local result=$(tv git-branches)
  [[ -n "$result" ]] && LBUFFER+="$result"
  zle reset-prompt
}
zle -N _tv_git_branches

_fzf_history_widget() { _load_fzf; zle fzf-history-widget 2>/dev/null || zle history-incremental-search-backward }
_fzf_file_widget() { _load_fzf; zle fzf-file-widget 2>/dev/null }
zle -N _fzf_history_widget
zle -N _fzf_file_widget

# ============================================================================
# Keybindings - deferred to run after plugins load
# ============================================================================

_setup_keybindings() {
  bindkey -M viins '^R' _fzf_history_widget
  bindkey -M viins '^T' _fzf_file_widget
  bindkey -M viins '^K' autosuggest-accept
  bindkey -M viins '^G' _tv_git_branches
  (( ${+functions[setup-claude-agent-keybindings]} )) && setup-claude-agent-keybindings
}

# Defer keybinding setup to run after deferred sources complete
zsh-defer _setup_keybindings

# ZVM after init hook - re-applies keybindings after zvm loads
zvm_after_init() {
  _setup_keybindings
}
