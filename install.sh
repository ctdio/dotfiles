#!/bin/bash

DOTFILES_DIR="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

function main () {
  echo "Installing..."

  link_dotfiles

  install_fzf_git
  install_asdf
  install_ansible
  run_ansible_playbooks

  echo "Install complete!"
}

function fetch_antigen () {
  echo "Fetching antigen..."
  curl -L git.io/antigen > ~/antigen.zsh
}

function install_fzf_git () {
  echo "Installing fzf"
  if [ ! -d ~/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
  else
    echo "fzf is already installed. Skipping."
  fi

  if [ ! -d ~/.fzf-git.sh ]; then
    echo "Installing fzf-git"
    git clone https://github.com/junegunn/fzf-git.sh ~/.fzf-git.sh
  else
    echo "fzf-git.sh is already installed. Skipping."
  fi
}

function install_ansible () {
  if [[ "$(uname)" = 'Linux' ]]; then
    apt install ansible
  elif [[ "$(uname)" = 'Darwin' ]]; then
    brew install ansible
  fi
}

function install_asdf () {
  if [ ! -d ~/.asdf ]; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2
  else
    echo "asdf is already installed. Skipping."
  fi
}

function run_ansible_playbooks () {
  ansible-playbook ./playbooks/setup-asdf.yaml
  ansible-playbook ./playbooks/install-brew-packages.yaml
  ansible-playbook ./playbooks/install-cargo-packages.yaml
  ansible-playbook ./playbooks/install-golang-packages.yaml
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
