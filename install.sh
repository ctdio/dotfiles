#!/bin/bash

DOTFILES_DIR="$(cd $(dirname "$BASH_SOURCE[0]") && pwd)"

function installMacPrograms () {
  echo "Installing zsh, tmux, neovim, chunkwm, and skhd..."

  brew tap crisidev/homebrew-chunkwm

  brew install \
    zsh \
    tmux \
    neovim \
    koekeishiya/formulae/skhd

  brew install --HEAD chunkwm

  brew upgrade

  brew services start skhd
  brew services start chunkwm
}

function installLinuxPrograms () {
  echo "Installing zsh, tmux, and neovim..."

  apt update

  apt install -y \
    zsh \
    tmux \
    neovim

  apt upgrade
}

function main () {
  echo "Installing..."

  local system = "${uname}"

  if [[ "$system" == 'Darwin' ]]; then
    echo "MacOS detected, installing programs for Mac..."
    installMacPrograms
  elif [[ "$system" == "Linux" ]]; then
    # assume Ubuntu for now
    echo "Linux detected, installing programs for Linux..."
    installLinuxPrograms
  fi

  echo "Fetching antigen..."
  curl -L git.io/antigen > antigen.zsh

  echo "Installing rustup..."
  curl https://sh.rustup.rs -sSf | sh

  echo "Linking dotfiles..."
  # iterate through all files
  # and symlink them to home
  for filename in $(ls -A); do
    if [ ${filename} != ".git" ]; then
      echo "Linking ${filename} to ~/${filename}"
      ln -nsf ${DOTFILES_DIR}/${filename} ~/${filename}
    fi
  done

  echo "Linking oni.config.tsx to ~/.config/oni/config.tsx"
  ln -nsf ${DOTFILES_DIR}/oni.config.tsx ~/.config/oni/config.tsx

  echo "Linking .vimrc to ~/.config/nvim/init.vim"
  ln -nsf ${DOTFILES_DIR}/.vimrc ~/.config/nvim/init.vim

  # install vim plugins
  echo "Installing vim plugins..."
  vim +PlugInstall +PlugUpdate +qall

  echo "Install complete!"
}

main
