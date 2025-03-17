set -o ignoreeof

alias cdp='cd ~/projects/private'
alias cdo='cd ~/projects/open-source'
alias cdj='cd ~/work/jupiterone'

alias killn='killall node'

alias oni='~/Onivim2-x86_64.AppImage'

alias l='ls -la'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias nvim-no-sesh='nvim "+let g:auto_session_enabled = v:false"'
alias vim-no-sesh='nvim-no-sesh'
alias dbui='nvim -c "DBUI"'
alias wtf='~/wtfutil'

alias pr='gh pr view --web'

alias rmswp='find . -name "*.sw*" -ok rm {} +'

alias m='bat'

alias ns='npm start'
alias nt='npm test'
alias ys='yarn start'
alias yt='yarn test'
alias ungron='gron --ungron'

alias notes='pushd ~/obsidian; nvim; popd'

alias ai="aider --read=~/dotfiles/prompts/system.md"
alias ai-r1="ai --architect --model=fireworks_ai/accounts/fireworks/models/deepseek-r1 --editor-model=claude-3-5-sonnet-20241022"
alias ai-o3="ai --architect --model=o3-mini --editor-model=claude-3-5-sonnet-20241022"

# vim to claude code
function vcc () {
  local uuid=$(uuidgen)
  local temp_file="/tmp/prompt-${uuid}.md"
  touch ${temp_file}
  echo "# System Prompt\n" >> ${temp_file}
  cat ~/dotfiles/prompts/system.md >> ${temp_file}

  echo "\n" >> ${temp_file}
  echo "-------------------------------------------------------" >> ${temp_file}
  echo "\n\n# Instructions\n\n" >> ${temp_file}

  local sha_before_edit=$(sha256sum ${temp_file} | awk '{print $1}')
  # open file in vim, move to bottom of file, center view on cursor
  vim ${temp_file} -c "norm G" -c "norm zz" -c "norm i"
  local sha_after_edit=$(sha256sum ${temp_file} | awk '{print $1}')

  if [[ ${sha_before_edit} == ${sha_after_edit} ]]; then
    echo "No changes made to prompt. Not sending to Claude."
  else
    echo "Wrote prompt to ${temp_file}"
    # add system prompt to context upon loading
    claude ${temp_file}
  fi
}

# helper functions
function fcd () {
  local directories=$(ls -d */)
  local chosen_directory=$(echo "${directories}" | fzf)

  if type z &> /dev/null; then
    z ${chosen_directory}
  else
    cd ${chosen_directory}
  fi
}

function fgd() {
  local preview="git diff $@ --color=always {1}"
  git diff $@ --name-only | fzf -m --ansi --preview ${preview}
}

function fgco() {
  local preview='git log --color=always {1}'
  local branch_desc=$(git branch $@ -vv | fzf -m --ansi --preview ${preview})
  local branch="$(echo "${branch_desc}" | awk '{print $1}')"
  git checkout ${branch}
}

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

function lastPassCopy () {
  lpass show --password ${1} | pbcopy
}

# usage: replace <search term>
function replace () {
  rg --files | xargs sed -i "s/${1}/${2}/g"
}

function fnvim () {
  local file_path="$(rg --files | fzf)"
  nvim ${file_path}
}

eval "$(mise activate zsh --shims)"

# Added by OrbStack: command-line tools and integration
# Comment this line if you don't want it to be added again.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
