# zsh exports

export ENVIRONMENT=dev

export GOKU_EDN_CONFIG_FILE=~/dotfiles/karabiner/karabiner.edn

export DATABRICKS_CONFIG_PROFILE=default

export ANDROID_HOME=${HOME}/android-sdk

export PATH=${PATH}:${HOME}/.local/bin
export PATH=${PATH}:${HOME}/dotfiles/scripts
export PATH=${PATH}:/opt/homebrew/bin
export PATH=${PATH}:${HOME}/.cargo/bin
export PATH=${PATH}:${HOME}/.lua-language-server/bin
export PATH=${PATH}:${HOME}/.zls/zig-out/bin
export PATH=${PATH}:${ANDROID_HOME}/emulator
export PATH=${PATH}:${ANDROID_HOME}/tools
export PATH=${PATH}:${ANDROID_HOME}/tools/bin
export PATH=${PATH}:${ANDROID_HOME}/platform-tools
export PATH=${PATH}:${ANDROID_HOME}/platform-tools
export PATH=${PATH}:${HOME}/.fzf/bin
export PATH=${PATH}:${HOME}/.turso


export FPATH="$HOME/.zcomp:$FPATH"

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

# pnpm
export PNPM_HOME="/home/charlieduong/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

export MODULAR_HOME="/Users/charlieduong/.modular"
export PATH="/Users/charlieduong/.modular/pkg/packages.modular.com_mojo/bin:$PATH"

export EDITOR="nvim"

RG_IGNORE=$(cat <<EOM
.Trash
.ansible
.antigen
.asdf
.aws
.bun
.cache
.cargo
.conda
.docker
.earthly
.fig
.fzf
.git
.hex
.ipython
.ivy2
.jupyter
.obsidian
.kube
.local
.localized
.lua-language-server
.minikube
.modular
.node
.please
.prettierd
.rtx
.rustup
.tmux
.vim
.yalc
Library
Downloads
google-cloud-sdk
miniconda3
node_modules
spark
product-scraper
EOM
)

RG_IGNORE_FORMATTED="$(echo "${RG_IGNORE}" | tr '\n' ',')"

export FZF_DEFAULT_COMMAND="rg --files --hidden -g '!{${RG_IGNORE_FORMATTED}}'"
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"

if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
  alias pbcopy='clip.exe'
elif [[ "$(uname)" = 'Linux' ]]; then
  alias pbcopy='xclip -selection clipboard'
fi

if [ -f "$HOME/.env" ]; then
  export $(grep -v '^#' $HOME/.env | xargs)
fi

# Mise (runtime version manager) - loaded for all shells
if [[ "$(uname)" == "Linux" ]]; then
  eval "$(~/.local/bin/mise activate zsh)"
elif [[ "$(uname)" == "Darwin" ]]; then
  eval "$(/Users/charlieduong/.local/bin/mise activate zsh)"
fi
