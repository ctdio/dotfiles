# Vim Claude - open vim to write a prompt, then pipe to claude
function vc() {
  local temp_file=$(mktemp /tmp/claude_prompt.XXXXXX)
  vim "$temp_file"

  if [ -s "$temp_file" ]; then
    cat "$temp_file" | claude $@
  else
    echo "No content provided, aborting."
  fi

  rm -f "$temp_file"
}

# Sync agent prompt files
function sync-agent-prompts() {
  # Create directories if they don't exist
  mkdir -p ~/.claude ~/.codex ~/.config/opencode

  # Combine all prompt files
  local combined_prompts=$(cat ~/dotfiles/prompts/base.mdc ~/dotfiles/prompts/locality-of-behavior.mdc ~/dotfiles/prompts/typescript.mdc)

  # Write to all three locations
  echo "$combined_prompts" > ~/.claude/CLAUDE.md
  echo "$combined_prompts" > ~/.codex/AGENTS.md
  echo "$combined_prompts" > ~/.config/opencode/AGENTS.md

  # Calculate metrics
  local char_count=$(echo "$combined_prompts" | wc -c | tr -d ' ')
  local word_count=$(echo "$combined_prompts" | wc -w | tr -d ' ')
  local line_count=$(echo "$combined_prompts" | wc -l | tr -d ' ')
  local file_size=$(du -h ~/.claude/CLAUDE.md | cut -f1)
  # Accurate token count using tiktoken
  local token_count=$(echo "$combined_prompts" | uvx --from tiktoken-cli tiktoken - 2>/dev/null | wc -l | tr -d ' ')

  echo "Synced agent prompts to:"
  echo "  ~/.claude/CLAUDE.md"
  echo "  ~/.codex/AGENTS.md"
  echo "  ~/.config/opencode/AGENTS.md"
  echo ""
  echo "File stats:"
  echo "  Size: $file_size"
  echo "  Lines: $line_count"
  echo "  Words: $word_count"
  echo "  Characters: $char_count"
  echo "  Tokens: $token_count"
}

# Benchmark zsh startup time
function timezsh () {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

# FZF directory navigation
function fcd () {
  local directories=$(ls -d */)
  local chosen_directory=$(echo "${directories}" | fzf)

  if type z &> /dev/null; then
    z ${chosen_directory}
  else
    cd ${chosen_directory}
  fi
}

# FZF git diff viewer
function fgd() {
  local preview="git diff $@ --color=always {1}"
  git diff $@ --name-only | fzf -m --ansi --preview ${preview}
}

# FZF git checkout
function fgco() {
  local preview='git log --color=always {1}'
  local branch_desc=$(git branch $@ -vv | fzf -m --ansi --preview ${preview})
  local branch="$(echo "${branch_desc}" | awk '{print $1}')"
  git checkout ${branch}
}

# Display utilities (Linux)
function fixdisplays () {
  local display_id=$(xrandr | grep "^DP" | grep " connected " | awk '{print $1}')
  echo "Making \"${display_id}\" the primary display..."
  xrandr --output ${display_id} --size 3440x1440
  echo "Turning off laptop screen..."
  xrandr --output eDP-1 --off
  echo "Done."
}

function fixdisplayshome () {
  xrandr --output eDP-1 --off
  echo "Done."
}

# LastPass utility
function lastPassCopy () {
  lpass show --password ${1} | pbcopy
}

# Search and replace across files
function replace () {
  rg --files | xargs sed -i "s/${1}/${2}/g"
}

# FZF file search and open in nvim
function fnvim () {
  local file_path="$(rg --files | fzf)"
  nvim ${file_path}
}

