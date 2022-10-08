autoload -Uz compinit && compinit

# hack to get better colors in tmux
alias tmux='TERM=screen-256color tmux'

source ~/antigen.zsh
. ${HOME}/.asdf/asdf.sh

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

# added by travis gem
[ -f /home/charlie/.travis/travis.sh ] && source /home/charlie/.travis/travis.sh

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

alias luamake=~/.lua-language-server/3rd/luamake/luamake
