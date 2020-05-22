#!/bin/bash

DOTFILES_DIR="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

function main () {
  echo "Installing..."

  linkDotfiles

  setupAsdf

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

  setupVim

  echo "Install complete!"
}

function linkDotfiles () {
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

  echo "Linking alacritty.yml to ~/.config/alacritty/alacritty.yml"
  mkdir -p ~/.config/alacritty
  ln -nsf ${DOTFILES_DIR}/alacritty.yml ~/.config/alacritty/alacritty.yml

  echo "Linking .vimrc to ~/.config/nvim/init.vim"
  mkdir -p ~/.config/nvim
  ln -nsf ${DOTFILES_DIR}/.vimrc ~/.config/nvim/init.vim

  mkdir -p ~/.config/i3
  ln -nsf ${DOTFILES_DIR}/.i3config ~/.config/i3/config

  mkdir -p ~/.config/i3blocks
  ln -nsf ${DOTFILES_DIR}/.i3blocks.conf ~/.config/i3blocks/config

}

function installMacPrograms () {
  brew tap crisidev/homebrew-chunkwm

  brew install \
    python2 \
    zsh \
    tmux \
    cmake \
    bat \
    koekeishiya/formulae/skhd

  brew install --HEAD chunkwm

  brew upgrade

  brew services start skhd
  brew services start chunkwm
}

function installLinuxPrograms () {
  sudo apt update

  sudo apt install -y \
    curl \
    zsh \
    tmux
    i3wm \
    i3blocks \
    ripgrep

  sudo apt upgrade
}

function setupAsdf () {
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.8

  asdf plugin add nodejs
  asdf plugin add rust
  asdf plugin add yarn
  asdf plugin add python
  asdf plugin add terraform
  asdf plugin add ruby
}

function setupVim () {
  # install vim plugins
  curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
  mv nvim.appimage $HOME
  chmod u+x ~/nvim.appimage

  echo "Install vim plugged"
  # vim
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  # neovim
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  echo "Installing vim plugins..."
  vim +PlugInstall +PlugUpdate +qall
  nvim +PlugInstall +PlugUpdate +qall
  nvim +CocInstall coc-json coc-tsserver coc-html coc-python coc-jest coc-sh coc-tslint-plugin coc-eslint coc-docker +qall
}

main
