if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
  alias pbcopy='clip.exe'
elif [[ "$(uname)" = 'Linux' ]]; then
  alias pbcopy='xclip -selection clipboard'
  alias nvim='~/nvim.appimage'

  keychain -q id_rsa
  . ~/.keychain/`uname -n`-sh
fi

# aliases
alias lock='i3lock -i ~/Pictures/wallpapers/wp6012329-valorant-wallpapers.png -n -p default -t'

alias cdw='cd ~/projects/open-source/windbreaker-io'
alias cdp='cd ~/projects/private'
alias cdo='cd ~/projects/open-source'
alias cdoj='cd ~/projects/open-source/jupiterone'
alias cdg='cd ~/projects/golang'

alias cdj='cd ~/work/jupiterone'

alias killn='killall node'

alias kblm='kb-el-switcher "Mechanical Keyboard"'
alias kbld='kb-el-switcher "Default profile"'

alias oni='~/Onivim2-x86_64.AppImage'

alias vim='nvim'
alias wtf='~/wtfutil'

# when chunkwm acts up
alias ffs='brew services restart chunkwm'

alias rmswp='find . -name "*.sw*" -ok rm {} +'

alias chromedriver='~/chromedriver'

alias imgcat='~/scripts/imgcat.sh'

alias awsgen='~/scripts/awsgen.sh'

alias octave='/usr/local/octave/3.8.0/bin/octave-3.8.0'
alias m='bat'

alias weather="~/scripts/weather.sh"

alias loadnvm='source ~/.nvm/nvm.sh'

alias ns='npm start'
alias nt='npm test'
alias ys='yarn start'
alias yt='yarn test'

alias wn='vim ~/projects/private/notes/work/daily.md'

alias control-center='env XDG_CURRENT_DESKTOP=GNOME gnome-control-center'

set -o ignoreeof

alias letmedeploy='~/work/gsuite.sh'
alias lpcp='lastPassCopy'

alias j1deploys='npx jupiterone-deployment-dashboard'

# alias notes='pushd ~/projects/private/notes; vim; popd'
# dnote aliases
alias n='dnote view'
alias nv='n'
alias ne='dnote edit'
alias na='dnote add'
alias nf='dnote find'
alias nr='dnote remove'

alias git-recent="git for-each-ref --sort=committerdate refs/heads/ \
  --format='%(HEAD) \
  %(color:yellow)%(refname:short)%(color:reset) - \
  %(color:red)%(objectname:short)%(color:reset) - \
  %(contents:subject) - \
  %(authorname) \
  (%(color:green)%(committerdate:relative)%(color:reset))'"

# helper functions

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

function j1deploystatus() {
  j1deploys --service ${1:-"$(cat project.name)"}
}

function mp () {
  grip --pass $(lpass show --notes grip-token) $@
}
eval "$(/opt/homebrew/bin/brew shellenv)"
