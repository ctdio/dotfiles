# PATH additions
export PATH="/Users/charlieduong/.bun/bin:$PATH"

# Navigation aliases
alias cdp='cd ~/projects/private'
alias cdo='cd ~/projects/open-source'
alias cdj='cd ~/work/jupiterone'

# System utilities
alias killn='killall node'
alias l='ls -la'
alias rmswp='find . -name "*.sw*" -ok rm {} +'

# Editor aliases
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias nvim-no-sesh='nvim "+let g:auto_session_enabled = v:false"'
alias vim-no-sesh='nvim-no-sesh'
alias dbui='nvim -c "DBUI"'
alias notes='pushd ~/obsidian; nvim; popd'
alias plans='pushd ~/.ai/plans; nvim; popd'

# External tools
alias wtf='~/wtfutil'
alias m='bat'
alias ungron='gron --ungron'

# Git aliases (minimal set, replaces oh-my-zsh git plugin)
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gc='git commit --verbose'
alias gc!='git commit --verbose --amend'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gl='git pull'
alias glg='git log --oneline --graph --decorate'
alias glo='git log --oneline'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias grb='git rebase'
alias grbi='git rebase -i'
alias gst='git status'
alias gss='git status --short'
alias gsw='git switch'
alias gswc='git switch -c'
alias pr='gh pr view --web'

# Node/Yarn aliases
alias ns='npm start'
alias nt='npm test'
alias ys='yarn start'
alias yt='yarn test'

# AI tools
function cc() {
  if command -v claude-chill &>/dev/null; then
    claude-chill -- claude --add-dir ~/.ai --dangerously-skip-permissions "$@"
  else
    claude --add-dir ~/.ai --dangerously-skip-permissions "$@"
  fi
}
alias cc-no-chill='claude --add-dir ~/.ai --dangerously-skip-permissions'
alias oc='opencode'
alias ca='cursor-agent -f'
alias agent="cd ~/projects/open-source/agent && bun run agent.ts"
alias rbb='ralph "Address all unresolved bugbot feedback and CI failures on this PR. Use the ctdio-ralph-bugbot skill and follow its steps exactly. Do not skip steps or exit early." -m 10 -c "BUGBOT RESOLVED"'

function ralph-implement-plan() {
  local plan=""
  local agent=""
  local model=""
  local -a ralph_opts=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -a|--agent)
        agent="$2"
        shift 2
        ;;
      -M|--model)
        model="$2"
        shift 2
        ;;
      *)
        plan="$1"
        shift
        ;;
    esac
  done

  if [[ -z "$plan" ]]; then
    echo "Usage: ralph-implement-plan <plan-name> [-a agent] [-M model]"
    return 1
  fi

  [[ -n "$agent" ]] && ralph_opts+=(-a "$agent")
  [[ -n "$model" ]] && ralph_opts+=(-M "$model")

  # Convert to uppercase and replace special chars with spaces
  local completion_promise=$(echo "$plan" | tr '[:lower:]' '[:upper:]' | sed 's/[^A-Z0-9]/ /g' | tr -s ' ' | xargs)
  completion_promise="${completion_promise} IMPLEMENTED"

  local prompt
  prompt=$(cat <<EOF
Your FIRST action MUST be to load the ctdio-feature-implementation skill by invoking:
  /ctdio-feature-implementation
This is NON-NEGOTIABLE. Do not proceed without loading the skill first.

Implement the ${plan} plan located in ~/.ai/plans.
The skill will guide the full orchestration workflow once loaded.

If agent team tools are available (TeamCreate, SendMessage, TaskList), you MUST use
them. Do not implement phases yourself — delegate to agent teammates.
EOF
)

  ralph "${ralph_opts[@]}" "$prompt" -m 25 -n 5 -c "$completion_promise"
}

