#!/bin/bash

DOTFILES_DIR="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

function main () {
  echo "Installing..."

  linkDotfiles

  echo "Fetching antigen..."
  curl -L git.io/antigen > antigen.zsh

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

  echo "Linking .vimrc to ~/.config/nvim/init.vim"
  mkdir -p ~/.config/nvim
  ln -nsf ${DOTFILES_DIR}/.vimrc ~/.config/nvim/init.vim

  mkdir -p ~/.config/i3
  ln -nsf ${DOTFILES_DIR}/.i3config ~/.config/i3/config

  mkdir -p ~/.config/i3blocks
  ln -nsf ${DOTFILES_DIR}/.i3blocks.conf ~/.config/i3blocks/config
}

main
