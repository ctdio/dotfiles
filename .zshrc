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

. ~/.asdf/asdf.sh

fpath=(/completions /usr/local/share/zsh/site-functions /usr/share/zsh/vendor-functions /usr/share/zsh/vendor-completions /usr/share/zsh/functions/Calendar /usr/share/zsh/functions/Chpwd /usr/share/zsh/functions/Completion /usr/share/zsh/functions/Completion/AIX /usr/share/zsh/functions/Completion/BSD /usr/share/zsh/functions/Completion/Base /usr/share/zsh/functions/Completion/Cygwin /usr/share/zsh/functions/Completion/Darwin /usr/share/zsh/functions/Completion/Debian /usr/share/zsh/functions/Completion/Linux /usr/share/zsh/functions/Completion/Mandriva /usr/share/zsh/functions/Completion/Redhat /usr/share/zsh/functions/Completion/Solaris /usr/share/zsh/functions/Completion/Unix /usr/share/zsh/functions/Completion/X /usr/share/zsh/functions/Completion/Zsh /usr/share/zsh/functions/Completion/openSUSE /usr/share/zsh/functions/Exceptions /usr/share/zsh/functions/MIME /usr/share/zsh/functions/Math /usr/share/zsh/functions/Misc /usr/share/zsh/functions/Newuser /usr/share/zsh/functions/Prompts /usr/share/zsh/functions/TCP /usr/share/zsh/functions/VCS_Info /usr/share/zsh/functions/VCS_Info/Backends /usr/share/zsh/functions/Zftp /usr/share/zsh/functions/Zle /home/charlieduong/.antigen/bundles/robbyrussell/oh-my-zsh/lib /home/charlieduong/.antigen/bundles/robbyrussell/oh-my-zsh/plugins/git /home/charlieduong/.antigen/bundles/robbyrussell/oh-my-zsh/plugins/lein /home/charlieduong/.antigen/bundles/robbyrussell/oh-my-zsh/plugins/command-not-found /home/charlieduong/.antigen/bundles/zsh-users/zsh-syntax-highlighting /home/charlieduong/.antigen/bundles/mafredri/zsh-async /home/charlieduong/.antigen/bundles/sindresorhus/pure)

autoload -Uz compinit && compinit

# added by travis gem
[ -f /home/charlie/.travis/travis.sh ] && source /home/charlie/.travis/travis.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# hack to get better colors in tmux
alias tmux='TERM=screen-256color tmux'
