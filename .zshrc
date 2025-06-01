# uncomment to profile
# zmodload zsh/zprof

# history
SAVEHIST=5000
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

bindkey -v

if type zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

fpath=(~/.zcomp $fpath);

eval "$(/Users/charlieduong/.local/bin/mise activate zsh)"

eval "$(starship init zsh)"

# uncomment to profile
# zprof
