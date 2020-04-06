if [[ "${SYSTEM}" -eq 'Linux' ]]; then
  alias pbcopy='xclip -selection clipboard'
fi

# aliases
alias lock='i3lock -n -p default -i ~/Pictures/wallpapers/ipad.png -t'

alias cdw='cd ~/projects/open-source/windbreaker-io'
alias cdp='cd ~/projects/private'
alias cdo='cd ~/projects/open-source'
alias cdg='cd ~/projects/golang'


alias cdl='cd ~/work/lifeomic'

alias killn='killall node'

alias kblm='kb-el-switcher "Mechanical Keyboard"'
alias kbld='kb-el-switcher "Default profile"'

# when chunkwm acts up
alias ffs='brew services restart chunkwm'

alias rmswp='find . -name "*.sw*" -ok rm {} +'

alias chromedriver='~/chromedriver'

alias imgcat='~/scripts/imgcat.sh'

alias awsgen='~/scripts/awsgen.sh'

alias octave='/usr/local/octave/3.8.0/bin/octave-3.8.0'
alias mp='markdown-preview'
alias m='bat'

alias weather="~/scripts/weather.sh"

alias loadnvm='source ~/.nvm/nvm.sh'

alias ns='npm start'
alias nt='npm test'
alias ys='yarn start'
alias yt='yarn test'

alias notes='pushd ~/projects/private/notes; vim; popd'
alias wn='vim ~/projects/private/notes/work/daily.md'

alias control-center='env XDG_CURRENT_DESKTOP=GNOME gnome-control-center'

set -o ignoreeof

alias okta='lpass show --password okta.com | ~/work/okta.sh'
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

# helper functions

function lastPassCopy () {
  lpass show --password ${1} | pbcopy
}

# usage: replace <search term> <replacement> <files/dirs>
function replace () {
  grep -rl ${1} ${@:3} | xargs sed -i '' "s/${1}/${2}/g"
}

function fnvim () {
  local file_path="$(rg --files | fzf)"
  nvim ${file_path}
}

function lostatus () {
  lodash --service ${1:-"$(cat project.name)"}
}


# startup
fnm use 8.12 --quiet
eval "$(rbenv init -)"
test -s "$HOME/.kiex/scripts/kiex" && source "$HOME/.kiex/scripts/kiex"

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

keychain -q id_rsa
. ~/.keychain/`uname -n`-sh

export PATH="$HOME/.cargo/bin:$PATH"
