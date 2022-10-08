#!/bin/bash

DOTFILES_DIR="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

function main () {
  echo "Installing..."

  link_dotfiles

  install_fzf_git
  install_asdf
  install_ansible

  # most language servers will be installed via playbooks
  #run_ansible_playbooks

  # lua language server requires a little more work
  install_ninja
  install_lua_language_server

  asdf reshim

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
    sudo apt install ansible
  elif [[ "$(uname)" = 'Darwin' ]]; then
    brew install ansible
  fi

  ansible-galaxy collection install community.general
}

function install_asdf () {
  if [ ! -d ~/.asdf ]; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2
    . ${HOME}/.asdf/asdf.sh
  else
    echo "asdf is already installed. Skipping."
  fi
}

function install_ninja () {
  if [[ "$(uname)" = 'Linux' ]]; then
    sudo apt install ninja-build
  elif [[ "$(uname)" = 'Darwin' ]]; then
    brew install ninja
  fi
}

function install_lua_language_server () {
  if [ ! -f ~/.lua-language-server/bin/lua-language-server ]; then
    echo "Installing lua-language-server"
    git clone --depth=1 \
      https://github.com/sumneko/lua-language-server \
      ~/.lua-language-server
    cd ~/.lua-language-server

    git submodule update --depth 1 --init --recursive

    cd 3rd/luamake
    ./compile/install.sh
    cd ../..
    ./3rd/luamake/luamake rebuild
  else
    echo "lua-language-server is already installed"
  fi
}

function run_ansible_playbooks () {
  if [[ "$(uname)" = 'Darwin' ]]; then
    ansible-playbook ./playbooks/install-brew-packages.yaml
  fi

  ansible-playbook ./playbooks/setup-asdf.yaml
  ansible-playbook ./playbooks/install-cargo-packages.yaml
  ansible-playbook ./playbooks/install-golang-packages.yaml
  ansible-playbook ./playbooks/install-npm-packages.yaml
}

function link_dotfiles () {
  echo "Linking dotfiles..."
  # iterate through all files
  # and symlink them to home
  for filename in $(ls -A ${DOTFILES_DIR}); do
    if [ ${filename} != ".git" ]; then
      echo "Linking ${filename} to ~/${filename}"
      ln -nsf ${DOTFILES_DIR}/${filename} ~/${filename}
    fi
  done

  echo "Linking nvim to ~/.config/nvim"
  ln -nsf ${DOTFILES_DIR}/nvim ~/.config/nvim
}

main
