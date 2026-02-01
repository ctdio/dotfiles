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
export PATH=${PATH}:${ANDROID_HOME}/emulator
export PATH=${PATH}:${ANDROID_HOME}/tools
export PATH=${PATH}:${ANDROID_HOME}/tools/bin
export PATH=${PATH}:${ANDROID_HOME}/platform-tools
export PATH=${PATH}:${ANDROID_HOME}/platform-tools
export PATH=${HOME}/.fzf/bin:${PATH}
export PATH=${PATH}:${HOME}/.turso


# fpath set in .zshrc (before compinit)

# libpq
# export PATH="/opt/homebrew/opt/libpq/bin:$PATH" >> ~/.zshrc

# temp, add skim
export PATH="$HOME/projects/open-source/skim/zig-out/bin:$PATH"

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

export MODULAR_HOME="$HOME/.modular"
export PATH="$HOME/.modular/pkg/packages.modular.com_mojo/bin:$PATH"

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

# Use parameter expansion instead of subprocess
RG_IGNORE_FORMATTED="${RG_IGNORE//$'\n'/,}"

export FZF_DEFAULT_COMMAND="rg --files --hidden -g '!{${RG_IGNORE_FORMATTED}}'"
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
export FZF_DEFAULT_OPTS="--cycle"

# Only check WSL on Linux (use $OSTYPE to avoid subprocess)
if [[ "$OSTYPE" == linux* ]]; then
  if [[ -f /proc/version ]] && grep -qEi "(Microsoft|WSL)" /proc/version; then
    alias pbcopy='clip.exe'
  else
    alias pbcopy='xclip -selection clipboard'
  fi
fi

# Load .env without spawning subprocesses
if [[ -f "$HOME/.env" ]]; then
  while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ -z "$key" || "$key" == \#* ]] && continue
    # Remove surrounding quotes from value
    value="${value%\"}"
    value="${value#\"}"
    value="${value%\'}"
    value="${value#\'}"
    export "$key=$value"
  done < "$HOME/.env"
fi

# Mise (runtime version manager)
# Interactive shells: use cached activation + deferred hook
# Non-interactive shells: use shims for compatibility (Cursor, etc.)
MISE_BIN="${HOME}/.local/bin/mise"
MISE_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/mise.zsh"

if [[ -o interactive ]]; then
  # Interactive shell - use cached mise activation for speed
  # Cache the activate script (regenerate with: mise activate zsh --no-hook-env > ~/.cache/zsh/mise.zsh)
  if [[ ! -f "$MISE_CACHE" ]]; then
    mkdir -p "$(dirname "$MISE_CACHE")"
    "$MISE_BIN" activate zsh --no-hook-env > "$MISE_CACHE"
  fi
  source "$MISE_CACHE"

  # Defer hook-env to first prompt (adds ~27ms but only once)
  _mise_hook() {
    eval "$($MISE_BIN hook-env -s zsh)"
  }
  typeset -ag precmd_functions
  precmd_functions=(_mise_hook ${precmd_functions[@]})
  typeset -ag chpwd_functions
  chpwd_functions=(_mise_hook ${chpwd_functions[@]})
else
  # Non-interactive shell - use shims
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi
