source ~/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle lein
antigen bundle command-not-found

# syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# syntax highlighting bundle.
antigen bundle mafredri/zsh-async
antigen bundle sindresorhus/pure

# Tell Antigen that you're done.
antigen apply

# fnm
export PATH=$HOME/.fnm:$PATH
eval "`fnm env --multi`"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
