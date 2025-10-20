# Claude Code Shell Integration

Shell integration for Claude Code with three modes: fast, interactive, and command generation.

## Modes

- **fast**: Quick responses with Haiku, streaming output
- **interactive**: Full Claude Code features
- **cmd**: Generate shell commands from natural language

## Installation

1. Add to your shell config:

```bash
# Optional: Configure (defaults shown)
export CLAUDE_AGENT_CMD="claude"
export CLAUDE_AGENT_BASE_ARGS=""
export CLAUDE_AGENT_FAST_ARGS="--model haiku -p"
export CLAUDE_AGENT_CMD_ARGS="--model haiku -p"
export CLAUDE_AGENT_INTERACTIVE_ARGS=""
export CLAUDE_AGENT_DEFAULT_MODE="fast"
export CLAUDE_AGENT_STREAM_PARSER="/path/to/claude-agent-mode/cc-stream-parser"

source /path/to/claude-agent-mode/claude-code-agent.zsh
```

2. For zsh-vi-mode, add keybindings in `zvm_after_init`:

```bash
function zvm_after_init() {
  setup-claude-agent-keybindings
}
```

3. Optional: Show mode in Starship prompt:

```toml
[env_var.CLAUDE_AGENT_MODE]
format = "[$env_value]($style) "
style = "bold 243"
disabled = false
```

## Usage

- **Ctrl+A**: Toggle agent mode
- **Tab**: Cycle modes (fast → interactive → cmd)
- **Enter**: Execute

## Requirements

- Claude Code CLI
- Bun (for stream parser)
- Zsh

## Files

- `claude-code-agent.zsh`: Main integration
- `cc-stream-parser`: Stream parser wrapper
- `cc-stream-parser.ts`: Parser implementation
