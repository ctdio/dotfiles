# history
SAVEHIST=1000  # Save most-recent 1000 lines
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY

autoload -Uz compinit && compinit

if [ -f '/opt/homebrew/bin/brew' ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# hack to get better colors in tmux
alias tmux='TERM=screen-256color tmux'

eval "$(rtx activate zsh)"
eval "$(rtx hook-env)"

# .zshrc
source ${HOMEBREW_PREFIX}/opt/antidote/share/antidote/antidote.zsh
antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt
autoload -Uz promptinit && promptinit && prompt pure

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

# pnpm
export PNPM_HOME="/home/charlieduong/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/charlieduong/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/charlieduong/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/charlieduong/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/charlieduong/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export MODULAR_HOME="/Users/charlieduong/.modular"
export PATH="/Users/charlieduong/.modular/pkg/packages.modular.com_mojo/bin:$PATH"
