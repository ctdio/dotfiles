# zsh exports

export ENVIRONMENT=dev

export ANDROID_HOME=$HOME/android-sdk

export PATH=$PATH:/opt/homebrew/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.lua-language-server/bin
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# libpq
export PATH="/opt/homebrew/opt/libpq/bin:$PATH" >> ~/.zshrc

export LANG="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# make fzf respect .gitignore
export FZF_DEFAULT_COMMAND='rg --files'

if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
  alias pbcopy='clip.exe'
elif [[ "$(uname)" = 'Linux' ]]; then
  alias pbcopy='xclip -selection clipboard'
fi

if [[ "$(uname)" = 'Linux' ]]; then
  export EDITOR=~/nvim.appimage
  alias nvim='~/nvim.appimage'
else
  export EDITOR=nvim
fi
