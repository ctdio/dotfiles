#!/bin/bash

DOTFILES_DIR="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

function main () {
  echo "Installing..."

  link_dotfiles
  link_git_hooks
  install_antigen
  install_fzf_git
  install_asdf
  install_ansible

  # most language servers will be installed via playbooks
  #run_ansible_playbooks

  # lua language server requires a little more work
  install_ninja
  install_lua_language_server
  # same with rust language server (rust-analyzer)
  install_rust_analyzer

  asdf reshim

  echo "Install complete!"
}

function link_dotfiles () {
  echo "Linking dotfiles..."
  # iterate through all files
  # and symlink them to home
  for filename in $(ls -A ${DOTFILES_DIR}); do
    if [[ ${filename} != ".git" && ${filename} == .* ]]; then
      echo "Linking ${filename} to ~/${filename}"
      ln -nsf ${DOTFILES_DIR}/${filename} ~/${filename}
    fi
  done

  echo "Linking nvim to ~/.config/nvim"
  ln -nsf ${DOTFILES_DIR}/nvim ~/.config/nvim

  echo "Linking startup.sh to ~/startup.sh"
  ln -nsf ${DOTFILES_DIR}/startup.sh ~/startup.sh
}

function link_git_hooks() {
  echo "Linking git hooks..."

  local source_dir=${DOTFILES_DIR}/hooks
  local destination_dir=${DOTFILES_DIR}/.git/hooks

  for filename in $(ls -A ${source_dir}); do
    local source_file_path=${source_dir}/${filename}
    local destination_file_path=${destination_dir}/${filename}
    echo "Linking ${source_file_path} to ${destination_file_path}"
    ln -nsf ${source_file_path} ${destination_file_path}
  done
}

function install_antigen () {
  echo "Installing antigen..."
  if [[ ! -f ~/antigen.zsh ]]; then
    curl -L git.io/antigen > ~/antigen.zsh
  else
    echo "antigen is already installed. Skipping."
  fi
}

function install_fzf_git () {
  echo "Installing fzf"
  if [[ ! -d ~/.fzf ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
  else
    echo "fzf is already installed. Skipping."
  fi

  if [[ ! -d ~/.fzf-git.sh ]]; then echo "Installing fzf-git"
    git clone https://github.com/junegunn/fzf-git.sh ~/.fzf-git.sh
  else
    echo "fzf-git.sh is already installed. Skipping."
  fi
}

function install_asdf () {
  if [[ ! -d ~/.asdf ]]; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2
    . ${HOME}/.asdf/asdf.sh
  else
    echo "asdf is already installed. Skipping."
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

function install_ninja () {
  if [[ "$(uname)" = 'Linux' ]]; then
    sudo apt install ninja-build
  elif [[ "$(uname)" = 'Darwin' ]]; then
    brew install ninja
  fi
}

function install_lua_language_server () {
  if [[ ! -f ~/.lua-language-server/bin/lua-language-server ]]; then
    echo "Installing lua-language-server"
    git clone \
      --depth=1 \
      --branch 3.5.6 \
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

function install_rust_analyzer () {
  if [[ ! -f ~/.local/bin/rust-analyzer ]]; then
    if [[ "$(uname)" = 'Linux' ]]; then
      echo "Installing rust-analyzer"
      mkdir -p ~/.local/bin
      curl -L https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz \
        | gunzip -c - > ~/.local/bin/rust-analyzer
      chmod +x ~/.local/bin/rust-analyzer
    fi
  else
    echo "rust-analyzer is already installed"
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

main
