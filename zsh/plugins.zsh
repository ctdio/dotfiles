# Ultra-fast plugin loading - no plugin manager overhead
# Plugins are stored in ~/dotfiles/zsh/plugins/
# To update: cd ~/dotfiles/zsh/plugins/<plugin> && git pull

DOTFILES_ZSH="${DOTFILES_DIR:-$HOME/dotfiles}/zsh"

# ============================================================================
# Immediate loads (fast plugins only)
# ============================================================================

# Autosuggestions - very fast (~4ms)
source "$DOTFILES_ZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Vi mode - use builtin, lazy-load full plugin
bindkey -v

# Set up edit-command-line (vv to edit in $EDITOR)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'vv' edit-command-line

# ============================================================================
# Deferred loading - syntax highlighting loads on first keystroke
# ============================================================================

_syntax_hl_loaded=0
_load_syntax_highlighting() {
  (( _syntax_hl_loaded )) && return
  _syntax_hl_loaded=1
  source "$DOTFILES_ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
}

# Trigger on first keystroke via zle widget
_lazy_self_insert() {
  _load_syntax_highlighting
  # Rebind to normal self-insert and replay the key
  zle .self-insert
}
zle -N self-insert _lazy_self_insert

# ============================================================================
# Lazy-loaded plugins - load on first use
# ============================================================================

# zsh-vi-mode - load on first Escape press, then hand off to zvm
_zvm_loaded=0
_load_zvm() {
  (( _zvm_loaded )) && return
  _zvm_loaded=1

  # Load zvm - it will set up its own keybindings
  source "$DOTFILES_ZSH/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh"

  # Re-run after_init hook for our custom keybindings
  (( ${+functions[zvm_after_init]} )) && zvm_after_init
}

_lazy_vi_cmd_mode() {
  if (( ! _zvm_loaded )); then
    _load_zvm
    # After loading, call zvm's escape handler directly
    # zvm binds escape to zvm_vi_vicmd_mode in viins
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
  [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
  [[ -f ~/.fzf-git.sh/fzf-git.sh ]] && source ~/.fzf-git.sh/fzf-git.sh
}

# ============================================================================
# Widgets and keybindings
# ============================================================================

# TV git branches widget
_tv_git_branches() {
  local result=$(tv git-branches)
  [[ -n "$result" ]] && LBUFFER+="$result"
  zle reset-prompt
}
zle -N _tv_git_branches

# fzf widgets with lazy loading
_fzf_history_widget() { _load_fzf; zle fzf-history-widget 2>/dev/null || zle history-incremental-search-backward }
_fzf_file_widget() { _load_fzf; zle fzf-file-widget 2>/dev/null }
zle -N _fzf_history_widget
zle -N _fzf_file_widget

# ============================================================================
# Claude Code integration
# ============================================================================

# Configure Claude Code agent mode
export CLAUDE_AGENT_CMD="claude"
export CLAUDE_AGENT_BASE_ARGS="--add-dir ~/.ai/plans --dangerously-skip-permissions"
export CLAUDE_AGENT_FAST_ARGS="--model haiku -p"
export CLAUDE_AGENT_CMD_ARGS="--model haiku -p"
export CLAUDE_AGENT_INTERACTIVE_ARGS=""
export CLAUDE_AGENT_DEFAULT_MODE="fast"
export CLAUDE_AGENT_STREAM_PARSER="$HOME/dotfiles/shell-integrations/zsh/cc-stream-parser"
export CLAUDE_AGENT_ENABLE_TERMINAL_CONTEXT="1"
export CLAUDE_AGENT_TERMINAL_CONTEXT_LINES="50"

source ~/dotfiles/shell-integrations/zsh/claude-code-zsh-integration.zsh

# ============================================================================
# Keybinding setup
# ============================================================================

_setup_keybindings() {
  bindkey -M viins '^R' _fzf_history_widget
  bindkey -M viins '^T' _fzf_file_widget
  bindkey -M viins '^K' autosuggest-accept
  bindkey -M viins '^G' _tv_git_branches
  setup-claude-agent-keybindings
}

# Set up keybindings now
_setup_keybindings

# ZVM after init hook - re-applies keybindings after zvm loads
zvm_after_init() {
  _setup_keybindings
}
