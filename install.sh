#!/bin/bash

echo "Installing..."

DOTFILES_DIR="$(cd $(dirname "$BASH_SOURCE[0]") && pwd)"

echo "Installing various tools..."
brew tap crisidev/homebrew-chunkwm

brew install \
  zsh \
  tmux \
  koekeishiya/formulae/skhd

brew install --HEAD chunkwm

brew services start skhd
brew services start chunkwm

echo "Fetching antigen..."
curl -L git.io/antigen > antigen.zsh

echo "Linking dotfiles..."
# iterate through all files
# and symlink them to home
for filename in $(ls -A); do
  if [ ${filename} != ".git" ]; then
    echo "Linking ${filename} to ~/${filename}"
    ln -nsf ${DOTFILES_DIR}/${filename} ~/${filename}
  fi
done

# install vim plugins
echo "Installing vim plugins..."
vim +PlugInstall +PlugUpdate +qall

echo "Install complete!"
