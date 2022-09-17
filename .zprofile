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

set -o ignoreeof

alias notes='pushd ~/obsidian; nvim; popd'


# helper functions

function j1deploys () {
  npx jupiterone-deployment-dashboard
}

function j1deploystatus() {
  j1deploys --service ${1:-"$(cat project.name)"}
}

function fixdisplays () {
  xrandr --output DP-1-1 --size 3440x1440 && xrandr --output eDP-1-1 --off
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
