set -o ignoreeof

alias cdp='cd ~/projects/private'
alias cdo='cd ~/projects/open-source'
alias cdj='cd ~/work/jupiterone'

alias killn='killall node'

alias oni='~/Onivim2-x86_64.AppImage'

alias vim='nvim'
alias wtf='~/wtfutil'

alias rmswp='find . -name "*.sw*" -ok rm {} +'

alias m='bat'

alias weather="~/scripts/weather.sh"

alias ns='npm start'
alias nt='npm test'
alias ys='yarn start'
alias yt='yarn test'
alias ungron='gron --ungron'

alias notes='pushd ~/obsidian; nvim; popd'

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

function j1deploys () {
  npx jupiterone-deployment-dashboard
}

function j1deploystatus() {
  j1deploys --service ${1:-"$(cat project.name)"}
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

eval "$(/opt/homebrew/bin/brew shellenv)"
