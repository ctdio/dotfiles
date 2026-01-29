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
alias rbb='ralph "Use ralph bugbot skill. Look for bugbot feedback and address feedback until bugbot stops reporting issues." -m 10 -c "BUGBOT RESOLVED"'

