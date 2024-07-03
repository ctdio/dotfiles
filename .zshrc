# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# uncomment to profile
# zmodload zsh/zprof

# history
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY

bindkey '^K'  autosuggest-accept

autoload -Uz compinit && compinit

if [ -f '/opt/homebrew/bin/brew' ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# hack to get better colors in tmux
alias tmux='TERM=screen-256color tmux'

# .zshrc
source ${HOMEBREW_PREFIX}/opt/antidote/share/antidote/antidote.zsh
antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt
autoload -Uz promptinit && promptinit

bindkey -v

# install fzf keybindings
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# enable fzf-git
[ -f ~/.fzf-git.sh/fzf-git.sh ] && source ~/.fzf-git.sh/fzf-git.sh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/charlieduong/google-cloud-sdk/path.zsh.inc' ]; then
  . '/Users/charlieduong/google-cloud-sdk/path.zsh.inc';
fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/charlieduong/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/charlieduong/google-cloud-sdk/completion.zsh.inc'; fi

if type zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

fpath=(~/.zcomp $fpath);

alias luamake=~/.lua-language-server/3rd/luamake/luamake

eval "$(/Users/charlieduong/.local/bin/mise activate zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# uncomment to profile
# zprof

eval $(thefuck --alias)
