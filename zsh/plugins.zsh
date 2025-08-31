# Load antidote plugin manager
if [[ "$(uname)" == "Linux" ]]; then
  source /usr/share/zsh-antidote/antidote.zsh
elif [[ "$(uname)" == "Darwin" ]]; then
  source ${HOMEBREW_PREFIX}/opt/antidote/share/antidote/antidote.zsh
fi

# Check if plugins cache exists, regenerate if needed
if [[ ! -f ${ZDOTDIR:-$HOME}/.zsh_plugins.zsh || ${ZDOTDIR:-$HOME}/.zsh_plugins.txt -nt ${ZDOTDIR:-$HOME}/.zsh_plugins.zsh ]]; then
  antidote bundle < ${ZDOTDIR:-$HOME}/.zsh_plugins.txt > ${ZDOTDIR:-$HOME}/.zsh_plugins.zsh
fi

# Source plugins
source ${ZDOTDIR:-$HOME}/.zsh_plugins.zsh

# Vi mode
bindkey -v

# Register the TV git branches widget
zle -N _tv_git_branches

# Git branches picker using television
_tv_git_branches() {
  local result=$(tv git-branches)
  if [[ -n "$result" ]]; then
    LBUFFER+="$result"
  fi
  zle reset-prompt
}

# ZVM after init hook (for keybindings)
function zvm_after_init() {
  # install fzf keybindings
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  # enable fzf-git
  [ -f ~/.fzf-git.sh/fzf-git.sh ] && source ~/.fzf-git.sh/fzf-git.sh

  bindkey '^K' autosuggest-accept
  bindkey '^G' _tv_git_branches  # Ctrl+G
}
