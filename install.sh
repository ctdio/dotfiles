#!/bin/bash

DOTFILES_DIR="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

function installMacPrograms () {
  echo "Installing zsh, tmux, yarn, neovim, chunkwm, and skhd..."

  brew tap crisidev/homebrew-chunkwm

  brew install \
    zsh \
    tmux \
    yarn \
    neovim \
    koekeishiya/formulae/skhd

  brew install --HEAD chunkwm

  brew upgrade

  brew services start skhd
  brew services start chunkwm
}

function installLinuxPrograms () {
  echo "Installing curl, zsh, tmux, yarn, ruby, and neovim..."

  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

  sudo apt update

  sudo apt install -y \
    curl \
    zsh \
    tmux \
    yarn \
    ruby \
    ruby-dev \
    neovim

  sudo apt upgrade
}

function main () {
  echo "Installing..."

  local SYSTEM="$(uname)"

  case ${SYSTEM} in
  'Darwin')
    echo "MacOS detected, installing programs for Mac..."
    installMacPrograms
    ;;
  'Linux')
    # assume Ubuntu for now
    echo "Linux detected, installing programs for Linux..."
    installLinuxPrograms
    ;;
  *)
    echo "${SYSTEM} is not supported"
  esac


  echo "Fetching antigen..."
  curl -L git.io/antigen > antigen.zsh

  echo "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash


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
  mkdir -p ~/.config/oni
  ln -nsf ${DOTFILES_DIR}/oni.config.tsx ~/.config/oni/config.tsx

  echo "Linking .vimrc to ~/.config/nvim/init.vim"
  mkdir -p ~/.config/nvim
  ln -nsf ${DOTFILES_DIR}/.vimrc ~/.config/nvim/init.vim

  # install vim plugins
  echo "Installing vim plugins..."
  vim +PlugInstall +PlugUpdate +qall

  echo "Install complete!"
}

main
