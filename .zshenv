# zsh exports

export YARN_PATH=~/.asdf/installs/nodejs/12.16.2/.npm

export ENVIRONMENT=dev

export ANDROID_HOME=$HOME/android-sdk

export PATH=$PATH:/opt/homebrew/bin
export PATH=$PATH:$HOME/.cargo/bin
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

# yarn bin
PATH="${YARN_PATH}/bin:$PATH"

export PATH

# make fzf respect .gitignore
export FZF_DEFAULT_COMMAND='rg --files'

# fnm (node)

export PATH="/var/folders/kb/64q38z99551c8_452v5t2fjh0000gn/T/fnm_multishells/17774_1639200762536/bin":$PATH
export FNM_MULTISHELL_PATH="/var/folders/kb/64q38z99551c8_452v5t2fjh0000gn/T/fnm_multishells/17774_1639200762536"
export FNM_DIR="/Users/charlieduong/.fnm"
export FNM_LOGLEVEL="info"
export FNM_NODE_DIST_MIRROR="https://nodejs.org/dist"
export FNM_ARCH="arm64"

# libpq
export PATH="/opt/homebrew/opt/libpq/bin:$PATH" >> ~/.zshrc

if [ -n "$PYTHONPATH" ]; then
    export PYTHONPATH='/opt/homebrew/Cellar/pdm/1.12.0/libexec/lib/python3.10/site-packages/pdm/pep582':$PYTHONPATH
else
    export PYTHONPATH='/opt/homebrew/Cellar/pdm/1.12.0/libexec/lib/python3.10/site-packages/pdm/pep582'
fi
export OPENBLAS=$(/opt/homebrew/bin/brew --prefix openblas)

# editor
if [[ "$(uname)" = 'Linux' ]]; then
  export EDITOR=~/nvim.appimage
else
  export EDITOR=nvim
fi
. "$HOME/.cargo/env"
