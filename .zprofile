# helper functions

function lastPassCopy () {
  lpass show --password ${1} | pbcopy
}

# usage: replace <search term> <replacement> <files/dirs>
function replace () {
  grep -rl ${1} ${@:3} | xargs sed -i '' "s/${1}/${2}/g"
}

# aliases
alias cdw='cd ~/Documents/home/projects/open-source/windbreaker-io'
alias cdp='cd ~/Documents/home/projects/private'
alias cdo='cd ~/Documents/home/projects/open-source'
alias cdg='cd ~/Documents/home/projects/golang'

alias cdl='cd ~/Documents/work/lifeomic'

alias killn='killall node'

alias kblm='kb-el-switcher "Mechanical Keyboard"'
alias kbld='kb-el-switcher "Default profile"'

# when 3 finger swipe is broken
alias wtf='killall -kill Dock'
# when chunkwm acts up
alias ffs='brew services restart chunkwm'

alias rmswp='find . -name "*.sw*" -ok rm {} +'

alias chromedriver='~/Documents/chromedriver'

alias imgcat='~/Documents/scripts/imgcat.sh'

alias awsgen='~/Documents/scripts/awsgen.sh'
alias pawsgen='~/Documents/scripts/personal-awsgen.sh'

alias octave='/usr/local/octave/3.8.0/bin/octave-3.8.0'
alias adb='/usr/local/opt/android-sdk/platform-tools/adb'
alias mp='markdown-preview'
alias m='less'

alias weather="~/scripts/weather.sh"

alias loadnvm='source ~/.nvm/nvm.sh'

alias ns='npm start'
alias nt='npm test'
alias ys='yarn start'
alias yt='yarn test'

alias notes='pushd ~/Documents/notes; vim; popd'

set -o ignoreeof

# nvm use default

export PATH="$HOME/.cargo/bin:$PATH"

alias okta='lpass show --password okta.com | ~/Documents/work/okta.sh'
alias lpcp='lastPassCopy'

alias lodash='lifeomic-deployment-dashboard'
alias lodiff='lifeomic-deployment-diff lifeomic-dev lifeomic-prod'

alias git-recent="git for-each-ref --sort=committerdate refs/heads/ \
  --format='%(HEAD) \
  %(color:yellow)%(refname:short)%(color:reset) - \
  %(color:red)%(objectname:short)%(color:reset) - \
  %(contents:subject) - \
  %(authorname) \
  (%(color:green)%(committerdate:relative)%(color:reset))'"
