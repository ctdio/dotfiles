# zsh exports

export NVM_DIR="/Users/charlieduong/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

export GOPATH=/Users/charlieduong/Documents/home/projects/golang
export ENVIRONMENT=dev
export PC_PLATFORM_PROPERTY_FILE=~/purecloud/service.properties


export ANDROID_HOME=/usr/local/opt/android-sdk

export LANG="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export EDITOR=vim

export FZF_DEFAULT_COMMAND='
  (git ls-tree -r --name-only HEAD ||
         find . -path "*/\.*" -prune -o -type f -print -o -type l -print |
        sed s/^..//) 2> /dev/null'

PATH=/Users/charlieduong/.nvm/versions/node/v6.9.1/bin:$PATH
PATH=$GOPATH/bin:$PATH
export PATH
