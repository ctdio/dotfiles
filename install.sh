#!/bin/bash

DOTFILES_DIR="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

function main () {
  echo "Installing..."

  link_dotfiles

  echo "Fetching antigen..."
  curl -L git.io/antigen > antigen.zsh

  echo "Install complete!"
}

function link_dotfiles () {
  echo "Linking dotfiles..."
  # iterate through all files
  # and symlink them to home
  for filename in $(ls -A); do
    if [ ${filename} != ".git" ]; then
      echo "Linking ${filename} to ~/${filename}"
      ln -nsf ${DOTFILES_DIR}/${filename} ~/${filename}
    fi
  done

  echo "Linking nvim to ~/.config/nvim"
  ln -nsf ${DOTFILES_DIR}/nvim ~/.config/nvim
}

main
