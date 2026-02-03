#!/usr/bin/env zsh
# ============================================================================
# Claude Code Agent Mode - Shell Integration
# ============================================================================
#
# A shell integration for Claude Code that provides three agent modes:
# - agent(fast): Fast responses using Haiku with streaming output
# - agent(interactive): Full interactive mode with all features
# - agent(cmd): Command generation mode that seeds shell with generated commands
#
# Terminal Context (Opt-in):
# You can enable automatic injection of recent terminal output into prompts
# by setting CLAUDE_AGENT_ENABLE_TERMINAL_CONTEXT=1. This gives Claude
# awareness of what's visible in your terminal, including command output,
# errors, and any other visible text. The integration automatically detects
# and uses the best capture method:
# - tmux: Uses `tmux capture-pane` to get scrollback buffer
# - iTerm2: Uses AppleScript to capture visible content
# - Fallback: Uses command history if no terminal capture is available
#
# Set CLAUDE_AGENT_ENABLE_TERMINAL_CONTEXT=1 to enable this feature.
# Configure the number of lines with CLAUDE_AGENT_TERMINAL_CONTEXT_LINES.
#
# Installation:
# 1. Source this file in your shell configuration
# 2. Install required binaries (agent-stream-parser) to your PATH
# 3. Configure keybindings (see below)
#
# Configuration:
# Set these environment variables before sourcing this file:
#
#   CLAUDE_AGENT_CMD - Base command to use (default: "claude")
#   CLAUDE_AGENT_BASE_ARGS - Args for all modes (default: "")
#   CLAUDE_AGENT_FAST_ARGS - Args for fast mode (default: "--model haiku -p")
#   CLAUDE_AGENT_CMD_ARGS - Args for cmd mode (default: "--model haiku -p")
#   CLAUDE_AGENT_INTERACTIVE_ARGS - Args for interactive mode (default: "")
#   CLAUDE_AGENT_DEFAULT_MODE - Default mode on Ctrl+A (default: "fast")
#                                Options: "fast", "interactive", "cmd"
#   CLAUDE_AGENT_STREAM_PARSER - Path to stream parser (default: "agent-stream-parser")
#   CLAUDE_AGENT_ENABLE_TERMINAL_CONTEXT - Enable terminal context injection (default: "0")
#                                           Set to "1" to enable
#   CLAUDE_AGENT_TERMINAL_CONTEXT_LINES - Number of history lines to include (default: "50")
#   CLAUDE_AGENT_ENABLE_HISTORY - Store AI queries in shell history (default: "0")
#                                  Set to "1" to enable
#
# Example:
#   export CLAUDE_AGENT_CMD="claude"
#   export CLAUDE_AGENT_BASE_ARGS="--add-dir ~/.ai/plans --dangerously-skip-permissions"
#   export CLAUDE_AGENT_FAST_ARGS="--model haiku -p"
#   export CLAUDE_AGENT_CMD_ARGS="--model haiku -p"
#   export CLAUDE_AGENT_INTERACTIVE_ARGS=""
#   export CLAUDE_AGENT_DEFAULT_MODE="fast"
#   export CLAUDE_AGENT_STREAM_PARSER="$HOME/dotfiles/shell-integrations/zsh/agent-stream-parser/agent-stream-parser"
#   export CLAUDE_AGENT_ENABLE_TERMINAL_CONTEXT="0"  # Set to "1" to enable
#   export CLAUDE_AGENT_TERMINAL_CONTEXT_LINES="50"
#   export CLAUDE_AGENT_ENABLE_HISTORY="0"  # Set to "1" to enable
#
# Keybindings:
# - Ctrl+A: Toggle agent mode on/off
# - Tab (in agent mode): Cycle through modes
# - Enter: Execute with selected mode
#
# Optional: Configure Starship prompt to show agent mode
# Add to starship.toml:
#   [env_var.CLAUDE_AGENT_MODE]
#   format = "[$env_value]($style) "
#   style = "bold 243"
#   disabled = false
#
# ============================================================================

# Configuration defaults
: ${CLAUDE_AGENT_CMD:="claude"}
: ${CLAUDE_AGENT_BASE_ARGS:=""}
: ${CLAUDE_AGENT_FAST_ARGS:="--model haiku -p"}
: ${CLAUDE_AGENT_CMD_ARGS:="--model haiku -p"}
: ${CLAUDE_AGENT_INTERACTIVE_ARGS:=""}
: ${CLAUDE_AGENT_DEFAULT_MODE:="fast"}
: ${CLAUDE_AGENT_STREAM_PARSER:="agent-stream-parser"}
: ${CLAUDE_AGENT_ENABLE_TERMINAL_CONTEXT:="0"}
: ${CLAUDE_AGENT_TERMINAL_CONTEXT_LINES:="50"}
: ${CLAUDE_AGENT_ENABLE_HISTORY:="0"}

# Global state variables
typeset -g CLAUDE_SAVED_HIGHLIGHTERS=()

# ============================================================================
# Helper Functions
# ============================================================================

# Update prompt to show current mode (for Starship integration)
function update-agent-mode-prompt() {
  if [[ "$CLAUDE_AGENT_GEN_MODE" == "1" ]]; then
    export CLAUDE_AGENT_MODE="agent(cmd)"
  elif [[ "$CLAUDE_AGENT_FAST" == "1" ]]; then
    export CLAUDE_AGENT_MODE="agent(fast)"
  else
    export CLAUDE_AGENT_MODE="agent(interactive)"
  fi
  zle reset-prompt
}

# Capture terminal context (visible terminal buffer)
function capture-terminal-context() {
  # Check if terminal context is enabled
  if [[ "${CLAUDE_AGENT_ENABLE_TERMINAL_CONTEXT:-0}" != "1" ]]; then
    return
  fi

  local num_lines="${CLAUDE_AGENT_TERMINAL_CONTEXT_LINES:-50}"
  local terminal_output=""

  # Try different methods to capture actual terminal output
  # Method 1: tmux (if we're in a tmux session)
  if [[ -n "$TMUX" ]]; then
    terminal_output=$(tmux capture-pane -p -S -${num_lines} 2>/dev/null)

  # Method 2: iTerm2 (if available)
  elif [[ "$TERM_PROGRAM" == "iTerm.app" ]] && command -v osascript >/dev/null 2>&1; then
    # Use AppleScript to get visible text from iTerm2
    terminal_output=$(osascript -e "
      tell application \"iTerm\"
        tell current session of current window
          get contents
        end tell
      end tell
    " 2>/dev/null | tail -n ${num_lines})

  # Method 3: Check if we have a scrollback capture mechanism
  elif [[ -n "$CLAUDE_TERMINAL_BUFFER" ]]; then
    # User can set this variable with their own capture mechanism
    terminal_output="$CLAUDE_TERMINAL_BUFFER"

  # Method 4: Fallback to command history
  else
    terminal_output=$(fc -ln -${num_lines} -1 2>/dev/null | sed 's/^[[:space:]]*//')
  fi

  if [[ -n "$terminal_output" ]]; then
    echo "<terminal_context>"
    echo "Recent terminal output (last ${num_lines} lines visible in terminal):"
    echo ""
    echo "$terminal_output"
    echo "</terminal_context>"
    echo ""
  fi
}

# ============================================================================
# Main Agent Mode Functions
# ============================================================================

# Toggle agent mode on/off
claude-agent-mode() {
  if [[ -n "$CLAUDE_AGENT_MODE" ]]; then
    # Exit agent mode
    unset CLAUDE_AGENT_MODE
    unset CLAUDE_AGENT_FAST
    unset CLAUDE_AGENT_GEN_MODE

    # Re-enable syntax highlighting
    if (( ${#CLAUDE_SAVED_HIGHLIGHTERS[@]} > 0 )); then
      ZSH_HIGHLIGHT_HIGHLIGHTERS=("${CLAUDE_SAVED_HIGHLIGHTERS[@]}")
      CLAUDE_SAVED_HIGHLIGHTERS=()
    fi
    region_highlight=()

    BUFFER=""
    CURSOR=0
    zle reset-prompt
  else
    # Enter agent mode - set to default mode
    case "$CLAUDE_AGENT_DEFAULT_MODE" in
      cmd)
        export CLAUDE_AGENT_GEN_MODE=1
        unset CLAUDE_AGENT_FAST
        ;;
      interactive)
        unset CLAUDE_AGENT_FAST
        unset CLAUDE_AGENT_GEN_MODE
        ;;
      fast|*)
        export CLAUDE_AGENT_FAST=1
        unset CLAUDE_AGENT_GEN_MODE
        ;;
    esac
    update-agent-mode-prompt

    # Clear current line
    BUFFER=""
    CURSOR=0

    # Disable syntax highlighting by saving and clearing highlighters
    if (( ${+ZSH_HIGHLIGHT_HIGHLIGHTERS} )); then
      CLAUDE_SAVED_HIGHLIGHTERS=("${ZSH_HIGHLIGHT_HIGHLIGHTERS[@]}")
      ZSH_HIGHLIGHT_HIGHLIGHTERS=()
    fi
    region_highlight=()
  fi
}

# Toggle between fast, interactive, and cmd modes
claude-agent-toggle-mode() {
  if [[ -n "$CLAUDE_AGENT_MODE" ]]; then
    # Cycle through modes: fast -> interactive -> cmd -> fast
    if [[ "$CLAUDE_AGENT_GEN_MODE" == "1" ]]; then
      # cmd -> fast
      export CLAUDE_AGENT_FAST=1
      unset CLAUDE_AGENT_GEN_MODE
    elif [[ "$CLAUDE_AGENT_FAST" == "1" ]]; then
      # fast -> interactive
      export CLAUDE_AGENT_FAST=0
      unset CLAUDE_AGENT_GEN_MODE
    else
      # interactive -> cmd
      unset CLAUDE_AGENT_FAST
      export CLAUDE_AGENT_GEN_MODE=1
    fi
    update-agent-mode-prompt
  else
    # Not in agent mode, use normal completion
    zle expand-or-complete
  fi
}

# Custom accept-line for agent mode
claude-agent-accept-line() {
  if [[ -n "$CLAUDE_AGENT_MODE" ]]; then
    # Store the command
    local agent_command="$BUFFER"
    local is_cmd_mode=0
    local is_fast_mode=0

    # Determine which mode we're in BEFORE unsetting variables
    if [[ "$CLAUDE_AGENT_GEN_MODE" == "1" ]]; then
      is_cmd_mode=1
    fi
    if [[ "$CLAUDE_AGENT_FAST" == "1" ]]; then
      is_fast_mode=1
    fi

    # Reset to normal mode
    unset CLAUDE_AGENT_MODE
    unset CLAUDE_AGENT_FAST
    unset CLAUDE_AGENT_GEN_MODE

    # Re-enable syntax highlighting
    if (( ${#CLAUDE_SAVED_HIGHLIGHTERS[@]} > 0 )); then
      ZSH_HIGHLIGHT_HIGHLIGHTERS=("${CLAUDE_SAVED_HIGHLIGHTERS[@]}")
      CLAUDE_SAVED_HIGHLIGHTERS=()
    fi
    region_highlight=()

    # Handle cmd mode - seed shell with generated command
    if [[ $is_cmd_mode -eq 1 ]]; then
      # Capture terminal context
      local terminal_context=$(capture-terminal-context)

      # Augment the user prompt with command generation instructions
      local augmented_prompt="${terminal_context}${agent_command}

CRITICAL INSTRUCTIONS:
- You are in COMMAND GENERATION mode
- Your task is to research and generate a shell command, NOT to execute it
- You MAY use read-only tools (Read, Grep, Glob) to research the codebase
- DO NOT use mutation tools (Bash, Write, Edit, NotebookEdit, etc.)
- DO NOT execute any commands
- Research the codebase as needed to understand context
- Output ONLY the final executable shell command on the last line
- No markdown, no code blocks, no backticks - just the raw command"

      # Create temp file to capture output while streaming
      local temp_output=$(mktemp)

      # Show streaming output and capture to temp file
      print "\nGenerating command...\n"
      ${CLAUDE_AGENT_CMD} ${=CLAUDE_AGENT_BASE_ARGS} ${=CLAUDE_AGENT_CMD_ARGS} --verbose --output-format stream-json --include-partial-messages ${(qq)augmented_prompt} 2>/dev/null | ${CLAUDE_AGENT_STREAM_PARSER} | tee "$temp_output"

      # Use the last non-empty line as the command
      # Filter out lines that are just whitespace or ANSI escape codes
      local generated_cmd=$(cat "$temp_output" | sed 's/\x1b\[[0-9;]*m//g' | grep -v '^[[:space:]]*$' | tail -1)

      # Clean up temp file
      rm -f "$temp_output"

      # Seed the buffer with the generated command
      print "\n"
      BUFFER="$generated_cmd"
      CURSOR=${#BUFFER}
      zle reset-prompt
    else
      # Handle fast mode or interactive mode
      local mode_args=""
      local use_stream_parser=0

      # Capture terminal context once for both modes
      local terminal_context=$(capture-terminal-context)

      if [[ $is_fast_mode -eq 1 ]]; then
        # Prepend fast mode instructions
        agent_command="${terminal_context}FAST MODE - CRITICAL INSTRUCTIONS:
- DO NOT ask questions or prompt for clarification
- DO NOT use the AskUserQuestion tool
- Make reasonable assumptions and proceed with the task
- Use available tools (Read, Grep, Glob) to gather any needed context
- Provide immediate, direct, actionable responses
- Be concise and get straight to the point

USER REQUEST:
${agent_command}"
        mode_args="${CLAUDE_AGENT_FAST_ARGS}"
        use_stream_parser=1
      else
        # Interactive mode - just prepend terminal context
        agent_command="${terminal_context}${agent_command}"
        mode_args="${CLAUDE_AGENT_INTERACTIVE_ARGS}"
      fi

      # Build the full command
      local full_cmd="${CLAUDE_AGENT_CMD}"
      if [[ -n "$CLAUDE_AGENT_BASE_ARGS" ]]; then
        full_cmd="${full_cmd} ${CLAUDE_AGENT_BASE_ARGS}"
      fi
      if [[ -n "$mode_args" ]]; then
        full_cmd="${full_cmd} ${mode_args}"
      fi

      # Build the full command line
      local full_cmd_line
      if [[ $use_stream_parser -eq 1 ]]; then
        full_cmd_line="${full_cmd} --verbose --output-format stream-json --include-partial-messages ${(qq)agent_command} | ${CLAUDE_AGENT_STREAM_PARSER}"
      else
        full_cmd_line="${full_cmd} ${(qq)agent_command}"
      fi

      # Define a temporary function with the command embedded
      # The function will add the real command to history and remove itself
      eval "function __cc() {
        local original_cmd=${(qq)full_cmd_line}

        # Set up trap to clean up on interrupt or exit
        trap '[[ -n \${functions[__cc]} ]] && unset -f __cc; return 130' INT
        trap '[[ -n \${functions[__cc]} ]] && unset -f __cc' EXIT

        ${full_cmd_line}
        local exit_code=\$?

        # Add the original command to history (if enabled)
        if [[ \"\${CLAUDE_AGENT_ENABLE_HISTORY:-0}\" == \"1\" ]]; then
          print -s \"\$original_cmd\"
        fi

        return \$exit_code
      }"

      # Set buffer to just call the function
      BUFFER="__cc"

      # Call the original accept-line
      zle .accept-line
    fi
  else
    # Normal accept-line behavior
    zle .accept-line
  fi
}

# ============================================================================
# Widget Registration
# ============================================================================

zle -N claude-agent-mode
zle -N claude-agent-toggle-mode
zle -N accept-line claude-agent-accept-line

# ============================================================================
# Keybinding Setup Function
# ============================================================================
# Call this function after vi-mode or other plugins have loaded
# For zsh-vi-mode, add to zvm_after_init() hook

function setup-claude-agent-keybindings() {
  # Check if using vi mode (no subshell - use zsh's (M) modifier)
  if [[ -n "${keymaps[(r)viins]}" ]]; then
    bindkey -M viins '^A' claude-agent-mode
    bindkey -M viins '^I' claude-agent-toggle-mode  # Tab
    bindkey -M vicmd '^A' claude-agent-mode
    bindkey -M vicmd '^I' claude-agent-toggle-mode  # Tab
  else
    # Standard mode bindings
    bindkey '^A' claude-agent-mode
    bindkey '^I' claude-agent-toggle-mode  # Tab
  fi
}

# Note: Keybindings are set up by the calling script (e.g., plugins.zsh)
# Call setup-claude-agent-keybindings after sourcing this file
