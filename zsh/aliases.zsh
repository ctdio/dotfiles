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

# External tools
alias wtf='~/wtfutil'
alias m='bat'
alias ungron='gron --ungron'

# Git aliases
alias pr='gh pr view --web'

# Node/Yarn aliases
alias ns='npm start'
alias nt='npm test'
alias ys='yarn start'
alias yt='yarn test'

# AI tools
alias ai="aider --read=~/dotfiles/prompts/system.md"
alias ai-r1="ai --architect --model=fireworks_ai/accounts/fireworks/models/deepseek-r1 --editor-model=claude-3-5-sonnet-20241022"
alias ai-o3="ai --architect --model=o3-mini --editor-model=claude-3-5-sonnet-20241022"
alias cc='claude --dangerously-skip-permissions'
alias ca='cursor-agent -f --fullscreen'
alias agent="cd ~/projects/open-source/agent && bun run agent.ts"
