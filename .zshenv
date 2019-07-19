# zsh exports

export GOPATH=/Users/charlieduong/Documents/home/projects/golang
export CARGOPATH=~/.cargo
export ENVIRONMENT=dev

export ANDROID_HOME=$HOME/android-sdk

export LANG="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export EDITOR=nvim

PATH="$HOME/.fnm:$PATH"

PATH="$HOME/.cargo/bin:$PATH"

# python
PATH="$HOME:/home/charlie/.local/lib/python2.7/site-packages:$PATH"

# ruby
PATH=":$HOME/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$PATH"

# terraform
PATH=":$HOME/terraform:$PATH"

# flutter
PATH=":$HOME/flutter/bin:$PATH"

# android platform tools
PATH=":$HOME/android-sdk/platform-tools:$PATH"
# android emulator
PATH=":$HOME/android-sdk/emulator:$PATH"

#go
PATH="$GOPATH/bin:$PATH"

# rust/cargo
PATH="$CARGOPATH/.bin:$PATH"

export PATH

# make fzf respect .gitignore
export FZF_DEFAULT_COMMAND='rg --files'
