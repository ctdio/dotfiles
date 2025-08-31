#!/bin/bash

DOTFILES_DIR="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

function main () {
  echo "Installing..."

  update_deps

  link_dotfiles
  link_git_hooks
  install_antigen
  install_fzf_git
  install_ansible
  install_tpm

  # most language servers will be installed via playbooks
  run_ansible_playbooks

  # lua language server requires a little more work
  install_ninja
  install_lua_language_server

  # same with rust language server (rust-analyzer)
  install_rust_analyzer

  prepare_neovim

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

  echo "Linking .ghostty-config to ~/.config/ghostty/config"
  mkdir -p ~/.config/ghostty
  ln -nsf ${DOTFILES_DIR}/.ghostty-config ~/.config/ghostty/config

  echo "Linking .aider.conf.yml to ~/.aider.conf.yml"
  ln -nsf ${DOTFILES_DIR}/.aider.conf.yml ~/.aider.conf.yml
  echo "Linking .aider.model.settings.yml to ~/.aider.model.settings.yml"
  ln -nsf ${DOTFILES_DIR}/.aider.model.settings.yml ~/.aider.model.settings.yml


  echo "Linking nvim to ~/.config/nvim"
  ln -nsf ${DOTFILES_DIR}/nvim ~/.config/nvim

  if [[ "$(uname)" = 'Darwin' ]]; then
    echo "Linking cursor settings to ~/Library/Application Support/Cursor/User"
    mkdir -p ~/Library/Application\ Support/Cursor/User
    ln -nsf ${DOTFILES_DIR}/cursor/settings.json ~/Library/Application\ Support/Cursor/User/settings.json
    ln -nsf ${DOTFILES_DIR}/cursor/keybindings.json ~/Library/Application\ Support/Cursor/User/keybindings.json
  fi

  echo "Linking .sketchybarrc to ~/.config/sketchybar/sketchybarrc"
  ln -nsf ${DOTFILES_DIR}/sketchybar ~/.config/sketchybar

  echo "Linking startup.sh to ~/startup.sh"
  ln -nsf ${DOTFILES_DIR}/startup.sh ~/startup.sh

  echo "Linking starship.toml to ~/.config/starship.toml"
  ln -nsf ${DOTFILES_DIR}/starship.toml ~/.config/starship.toml

  echo "Linking television to ~/.config/television"
  ln -nsf ${DOTFILES_DIR}/television ~/.config/television

  echo "Linking claude agents and commands to ~/.claude"
  mkdir -p ~/.claude
  ln -nsf ${DOTFILES_DIR}/claude/agents ~/.claude/agents
  ln -nsf ${DOTFILES_DIR}/claude/commands ~/.claude/commands

  local dotfiles_karabiner_mods_dir=${DOTFILES_DIR}/karabiner
  local os_karabiner_mods_dir=~/.config/karabiner/assets/complex_modifications

  mkdir -p ${os_karabiner_mods_dir}

  echo "Linking karabiner mods..."

  echo "Linking karabiner mods from ${dotfiles_karabiner_mods_dir} to ${os_karabiner_mods_dir}"

  for filename in $(ls -A ${dotfiles_karabiner_mods_dir}); do
    echo "filename: ${filename}"
    if [[ ${filename} != ".git" ]]; then
      echo "Linking ${filename} to ${os_karabiner_mods_dir}/${filename}"
      ln -nsf ${dotfiles_karabiner_mods_dir}/${filename} \
        ${os_karabiner_mods_dir}/${filename}
    fi
  done
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
    ~/.fzf/install \
      --completion \
      --key-bindings \
      --no-update-rc
  else
    echo "fzf is already installed. Skipping."
  fi

  if [[ ! -d ~/.fzf-git.sh ]]; then echo "Installing fzf-git"
    git clone https://github.com/junegunn/fzf-git.sh ~/.fzf-git.sh
  else
    echo "fzf-git.sh is already installed. Skipping."
  fi
}

function update_deps () {
  if [[ "$(uname)" = 'Linux' ]]; then
    if [[ -f /etc/arch-release ]]; then
      yay -Sy
    else
      sudo apt update -y
    fi
  fi
}

function install_ansible () {
  if [[ "$(uname)" = 'Linux' ]]; then
    if [[ -f /etc/arch-release ]]; then
      yay -S ansible --noconfirm
    else
      sudo apt install ansible -y
      ansible || uv pip install ansible
    fi
  elif [[ "$(uname)" = 'Darwin' ]]; then
    brew install ansible
  fi

  ansible-galaxy collection install community.general
}

function install_ninja () {
  if [[ "$(uname)" = 'Linux' ]]; then
    if [[ -f /etc/arch-release ]]; then
      yay -S ninja --noconfirm
    else
      sudo apt install ninja-build -y
    fi
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
      https://github.com/luals/lua-language-server \
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

function install_zig_language_server () {
  if [[ ! -f ~/.zig/bin/zls ]]; then
    echo "Installing zig-language-server"
    git clone https://github.com/zigtools/zls ~/.zls

    cd ~/.zls
    git checkout 0.12.0
    zig build -Doptimize=ReleaseSafe
  else
    echo "zig-language-server is already installed"
  fi
}

function install_rust_analyzer () {
  if [[ ! -f ~/.local/bin/rust-analyzer ]]; then
    echo "Installing rust-analyzer"
    local file='rust-analyzer-x86_64-unknown-linux-gnu.gz'

    case "$(uname)" in
      Linux)
        file='rust-analyzer-x86_64-unknown-linux-gnu.gz'
        ;;
      Darwin)
        file='rust-analyzer-aarch64-apple-darwin.gz'
        ;;
    esac

    local download_path="https://github.com/rust-lang/rust-analyzer/releases/latest/download/${file}"

    mkdir -p ~/.local/bin
    curl -L ${download_path} \
      | gunzip -c - > ~/.local/bin/rust-analyzer
    chmod +x ~/.local/bin/rust-analyzer
  else
    echo "rust-analyzer is already installed"
  fi
}

function run_ansible_playbooks () {
  if [[ "$(uname)" = 'Darwin' ]]; then
    ansible-playbook ./playbooks/install-brew-packages.yaml
  fi

  ansible-playbook ./playbooks/setup-mise.yaml
  ansible-playbook ./playbooks/install-cargo-packages.yaml
  ansible-playbook ./playbooks/install-golang-packages.yaml
  ansible-playbook ./playbooks/install-npm-packages.yaml
  ansible-playbook ./playbooks/install-pypi-packages.yaml
}

function prepare_neovim () {
  if [[ "$(uname)" = 'Linux' ]]; then
    yay -S neovim
  elif [[ "$(uname)" = 'Darwin' ]]; then
    brew install neovim
  fi
}

function install_tpm () {
  if [[ ! -f ~/.tmux/plugins/tpm ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
}

main

