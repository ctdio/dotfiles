# uncomment to profile
# zmodload zsh/zprof

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Instant prompt mode: verbose (1), quiet (2), off (3)
# See https://github.com/romkatv/powerlevel10k/blob/master/README.md#instant-prompt
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# history
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY

# Use -C to only check for completion fields when .zompdump is missing or
# outdated. Necessary for making shell
autoload -Uz compinit && compinit -C

if [ -f '/opt/homebrew/bin/brew' ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# hack to get better colors in tmux
alias tmux='TERM=screen-256color tmux'

function zvm_after_init() {
  # install fzf keybindings
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  # enable fzf-git
  [ -f ~/.fzf-git.sh/fzf-git.sh ] && source ~/.fzf-git.sh/fzf-git.sh

  bindkey '^K' autosuggest-accept
}

# Load antidote
source ${HOMEBREW_PREFIX}/opt/antidote/share/antidote/antidote.zsh

# Check if plugins cache exists, regenerate if needed
if [[ ! -f ${ZDOTDIR:-$HOME}/.zsh_plugins.zsh || ${ZDOTDIR:-$HOME}/.zsh_plugins.txt -nt ${ZDOTDIR:-$HOME}/.zsh_plugins.zsh ]]; then
  antidote bundle < ${ZDOTDIR:-$HOME}/.zsh_plugins.txt > ${ZDOTDIR:-$HOME}/.zsh_plugins.zsh
fi

# Source plugins
source ${ZDOTDIR:-$HOME}/.zsh_plugins.zsh
autoload -Uz promptinit && promptinit

bindkey -v

# Lazy load gcloud
function gcloud() {
  # Remove this function, subsequent calls will use the real gcloud
  unfunction gcloud

  # The next line updates PATH for the Google Cloud SDK.
  if [ -f '/Users/charlieduong/google-cloud-sdk/path.zsh.inc' ]; then
    . '/Users/charlieduong/google-cloud-sdk/path.zsh.inc';
  fi

  # The next line enables shell command completion for gcloud.
  if [ -f '/Users/charlieduong/google-cloud-sdk/completion.zsh.inc' ]; then
    . '/Users/charlieduong/google-cloud-sdk/completion.zsh.inc';
  fi

  # Now run the real gcloud command
  command gcloud "$@"
}

if type zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

fpath=(~/.zcomp $fpath);

# Lazy load luamake
luamake() {
  unfunction luamake
  alias luamake=~/.lua-language-server/3rd/luamake/luamake
  luamake "$@"
}

eval "$(/Users/charlieduong/.local/bin/mise activate zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Lazy load thefuck
thefuck() {
  unfunction thefuck
  eval $(command thefuck --alias)
  "$@"
}

# uncomment to profile
# zprof
