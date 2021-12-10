autoload -Uz compinit && compinit

# added by travis gem
[ -f /home/charlie/.travis/travis.sh ] && source /home/charlie/.travis/travis.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# hack to get better colors in tmux
alias tmux='TERM=screen-256color tmux'

source ~/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

antigen bundles <<EOF
  # Bundles from the default repo (robbyrussell's oh-my-zsh).
  git
  lein
  command-not-found
  thefuck

  # syntax highlighting bundle.
  zsh-users/zsh-syntax-highlighting

  # making zsh pretty
  mafredri/zsh-async
EOF

antigen theme af-magic

# Tell Antigen that you're done.
antigen apply

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
