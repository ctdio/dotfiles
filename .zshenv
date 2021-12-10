# zsh exports

export YARN_PATH=~/.asdf/installs/nodejs/12.16.2/.npm

export ENVIRONMENT=dev

export ANDROID_HOME=$HOME/android-sdk

export PATH=$PATH:/opt/homebrew/bin
export PATH=$PATH:$HOME/nvim.appimage
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

export LANG="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export EDITOR=~/nvim.appimage

# yarn bin
PATH="${YARN_PATH}/bin:$PATH"

export PATH

# make fzf respect .gitignore
export FZF_DEFAULT_COMMAND='rg --files'
