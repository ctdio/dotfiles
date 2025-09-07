#!/bin/bash

# Dotfiles Installation Script
# Supports: Ubuntu, Debian, Arch Linux, Omarchy, Fedora, openSUSE, macOS
# Usage: ./install.sh [--help|-h]

# Show help message
function show_help() {
  cat << EOF
Dotfiles Installation Script
============================

Supported Operating Systems:
  - macOS (Intel and Apple Silicon)
  - Ubuntu
  - Arch Linux / Omarchy

Usage:
  ./install.sh          Run the installation
  ./install.sh --help   Show this help message

The script will:
  1. Detect your operating system and distribution
  2. Install required system packages
  3. Set up development tools and languages via mise
  4. Install and configure Neovim with plugins
  5. Link all dotfiles to appropriate locations
  6. Install various language servers for development
  7. Install Sway, Waybar, and Wofi for Wayland desktop (Linux only)

Requirements:
  - git and curl must be installed
  - sudo/root access for system package installation
  - Internet connection for downloading packages

For Arch Linux:
  - The script will use yay if available, otherwise pacman

For Ubuntu:
  - The script will use apt package manager

EOF
  exit 0
}

# Parse command line arguments
for arg in "$@"; do
  case $arg in
    --help|-h)
      show_help
      ;;
  esac
done

DOTFILES_DIR="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

# Distribution detection variables
DISTRO=""
PACKAGE_MANAGER=""
PACKAGE_INSTALL_CMD=""
PACKAGE_UPDATE_CMD=""

# Detect Linux distribution and set package manager variables
function detect_distro() {
  if [[ "$(uname)" = 'Linux' ]]; then
    if [[ -f /etc/arch-release ]] || [[ -f /etc/os-release && $(grep -E "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"') =~ ^(arch|omarchy)$ ]]; then
      # Arch Linux or Omarchy
      DISTRO="arch"
      if command -v yay &> /dev/null; then
        PACKAGE_MANAGER="yay"
        PACKAGE_INSTALL_CMD="yay -S --noconfirm"
        PACKAGE_UPDATE_CMD="yay -Sy"
      else
        PACKAGE_MANAGER="pacman"
        PACKAGE_INSTALL_CMD="sudo pacman -S --noconfirm"
        PACKAGE_UPDATE_CMD="sudo pacman -Sy"
      fi
    elif [[ -f /etc/os-release && $(grep -E "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"') == "ubuntu" ]]; then
      # Ubuntu
      DISTRO="ubuntu"
      PACKAGE_MANAGER="apt"
      PACKAGE_INSTALL_CMD="sudo apt install -y"
      PACKAGE_UPDATE_CMD="sudo apt update -y"
    else
      echo "Warning: This script only supports Ubuntu and Arch Linux."
      exit 1
    fi
    
    echo "Detected: $DISTRO (using $PACKAGE_MANAGER)"
  elif [[ "$(uname)" = 'Darwin' ]]; then
    DISTRO="macos"
    PACKAGE_MANAGER="brew"
    PACKAGE_INSTALL_CMD="brew install"
    PACKAGE_UPDATE_CMD="brew update"
    echo "Detected: macOS (using brew)"
  fi
}

function main () {
  echo "Installing..."

  # Detect distribution first
  detect_distro
  
  update_deps

  link_dotfiles
  link_git_hooks
  install_antigen
  install_fzf_git
  install_ansible
  install_tpm
  install_sway_components

  # most language servers will be installed via playbooks
  run_ansible_playbooks

  # lua language server requires a little more work
  # Ensure we're using detected package manager for subsequent installs
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
  elif [[ "$(uname)" = 'Linux' ]]; then
    echo "Linking cursor settings to ~/.config/Cursor/User"
    mkdir -p ~/.config/Cursor
    ln -nsf ${DOTFILES_DIR}/cursor/settings.json ~/.config/Cursor/User/settings.json
    ln -nsf ${DOTFILES_DIR}/cursor/keybindings.json ~/.config/Cursor/User/keybindings.json
  fi

  # Link Hyprland configs for Arch/Omarchy
  if [[ "$(uname)" = 'Linux' && "$DISTRO" = "arch" ]]; then
    echo "Linking hypr files to ~/.config/hypr"
    mkdir -p ~/.config/hypr
    ln -nsf ${DOTFILES_DIR}/omarchy/hypr/autostart.conf ~/.config/hypr/autostart.conf
    ln -nsf ${DOTFILES_DIR}/omarchy/hypr/bindings.conf ~/.config/hypr/bindings.conf
    ln -nsf ${DOTFILES_DIR}/omarchy/hypr/envs.conf ~/.config/hypr/envs.conf
    ln -nsf ${DOTFILES_DIR}/omarchy/hypr/input.conf ~/.config/hypr/input.conf
    ln -nsf ${DOTFILES_DIR}/omarchy/hypr/monitors.conf ~/.config/hypr/monitors.conf
  fi

  echo "Linking .sketchybarrc to ~/.config/sketchybar/sketchybarrc"
  ln -nsf ${DOTFILES_DIR}/sketchybar ~/.config/sketchybar

  echo "Linking startup.sh to ~/startup.sh"
  ln -nsf ${DOTFILES_DIR}/startup.sh ~/startup.sh

  echo "Linking starship.toml to ~/.config/starship.toml"
  ln -nsf ${DOTFILES_DIR}/starship.toml ~/.config/starship.toml

  echo "Linking television to ~/.config/television"
  ln -nsf ${DOTFILES_DIR}/television ~/.config/television

  # Link Sway, Waybar, and Wofi configs for Ubuntu
  if [[ "$(uname)" = 'Linux' && "$DISTRO" = "ubuntu" ]]; then
    echo "Linking sway config to ~/.config/sway"
    mkdir -p ~/.config/sway
    ln -nsf ${DOTFILES_DIR}/ubuntu/sway/config ~/.config/sway/config

    echo "Linking waybar config to ~/.config/waybar"
    mkdir -p ~/.config/waybar
    ln -nsf ${DOTFILES_DIR}/ubuntu/waybar/config ~/.config/waybar/config
    ln -nsf ${DOTFILES_DIR}/ubuntu/waybar/style.css ~/.config/waybar/style.css

    echo "Linking wofi config to ~/.config/wofi"
    mkdir -p ~/.config/wofi
    ln -nsf ${DOTFILES_DIR}/ubuntu/wofi/config ~/.config/wofi/config
    ln -nsf ${DOTFILES_DIR}/ubuntu/wofi/style.css ~/.config/wofi/style.css
  fi

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
    echo "Updating package database..."
    $PACKAGE_UPDATE_CMD
  elif [[ "$(uname)" = 'Darwin' ]]; then
    echo "Updating homebrew..."
    brew update
  fi
}

function install_ansible () {
  echo "Installing Ansible..."
  
  if [[ "$(uname)" = 'Linux' ]]; then
    if [[ "$DISTRO" = "arch" ]]; then
      $PACKAGE_INSTALL_CMD ansible
    elif [[ "$DISTRO" = "ubuntu" ]]; then
      $PACKAGE_INSTALL_CMD ansible
      # Fallback to pip if apt version is too old
      if ! command -v ansible &> /dev/null; then
        echo "Ansible not found, installing via pip..."
        command -v uv &> /dev/null && uv pip install ansible || pip install ansible
      fi
    fi
  elif [[ "$(uname)" = 'Darwin' ]]; then
    brew install ansible
  fi

  ansible-galaxy collection install community.general
}

function install_ninja () {
  echo "Installing Ninja build system..."
  
  if [[ "$(uname)" = 'Linux' ]]; then
    if [[ "$DISTRO" = "arch" ]]; then
      $PACKAGE_INSTALL_CMD ninja
    elif [[ "$DISTRO" = "ubuntu" ]]; then
      $PACKAGE_INSTALL_CMD ninja-build
    fi
  elif [[ "$(uname)" = 'Darwin' ]]; then
    brew install ninja
  fi
}

function install_lua_language_server () {
  if [[ ! -f ~/.lua-language-server/bin/lua-language-server ]]; then
    echo "Installing lua-language-server"
    
    # Install build dependencies if needed
    if [[ "$(uname)" = 'Linux' ]]; then
      if [[ "$DISTRO" = "arch" ]]; then
        $PACKAGE_INSTALL_CMD gcc make
      elif [[ "$DISTRO" = "ubuntu" ]]; then
        $PACKAGE_INSTALL_CMD build-essential
      fi
    fi
    
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
    
    cd "$DOTFILES_DIR"
  else
    echo "lua-language-server is already installed"
  fi
}


function install_rust_analyzer () {
  if [[ ! -f ~/.local/bin/rust-analyzer ]]; then
    echo "Installing rust-analyzer"
    local file=''

    case "$(uname)" in
      Linux)
        # Detect architecture for Linux
        case "$(uname -m)" in
          x86_64)
            file='rust-analyzer-x86_64-unknown-linux-gnu.gz'
            ;;
          aarch64)
            file='rust-analyzer-aarch64-unknown-linux-gnu.gz'
            ;;
          *)
            echo "Warning: Unknown architecture $(uname -m). Defaulting to x86_64."
            file='rust-analyzer-x86_64-unknown-linux-gnu.gz'
            ;;
        esac
        ;;
      Darwin)
        # Detect architecture for macOS
        case "$(uname -m)" in
          arm64)
            file='rust-analyzer-aarch64-apple-darwin.gz'
            ;;
          x86_64)
            file='rust-analyzer-x86_64-apple-darwin.gz'
            ;;
          *)
            echo "Warning: Unknown architecture $(uname -m). Defaulting to arm64."
            file='rust-analyzer-aarch64-apple-darwin.gz'
            ;;
        esac
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
  elif [[ "$(uname)" = 'Linux' ]]; then
    # Install Linux system packages
    echo "Installing Linux system packages via Ansible..."
    ansible-playbook ./playbooks/install-linux-packages.yaml --ask-become-pass || {
      echo "Warning: Some system packages may have failed to install"
    }
  fi

  ansible-playbook ./playbooks/setup-mise.yaml
  ansible-playbook ./playbooks/install-cargo-packages.yaml
  ansible-playbook ./playbooks/install-golang-packages.yaml
  ansible-playbook ./playbooks/install-npm-packages.yaml
  ansible-playbook ./playbooks/install-pypi-packages.yaml
}

function prepare_neovim () {
  echo "Installing Neovim..."
  
  if [[ "$(uname)" = 'Linux' ]]; then
    if [[ "$DISTRO" = "arch" ]]; then
      $PACKAGE_INSTALL_CMD neovim
    elif [[ "$DISTRO" = "ubuntu" ]]; then
      # Ubuntu often has outdated neovim, so we might need to add PPA
      sudo add-apt-repository -y ppa:neovim-ppa/unstable 2>/dev/null || true
      sudo apt update
      $PACKAGE_INSTALL_CMD neovim
    fi
  elif [[ "$(uname)" = 'Darwin' ]]; then
    brew install neovim
  fi
}

function install_tpm () {
  if [[ ! -d ~/.tmux/plugins/tpm ]]; then
    echo "Installing tmux plugin manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  else
    echo "TPM is already installed. Skipping."
  fi
}

function install_sway_components () {
  # Only install Sway for Ubuntu (Arch/Omarchy uses Hyprland)
  if [[ "$(uname)" = 'Linux' && "$DISTRO" = "ubuntu" ]]; then
    echo "Installing Sway and Wayland components for Ubuntu..."
    
    $PACKAGE_INSTALL_CMD sway swaylock swayidle swaybg waybar wofi \
      wl-clipboard grim slurp mako-notifier foot xwayland \
      fonts-font-awesome fonts-jetbrains-mono pavucontrol network-manager-gnome
    
    echo "Sway components installed successfully!"
  fi
}

# Check for required tools before starting
function check_requirements () {
  local missing_tools=()
  
  # Check for git
  if ! command -v git &> /dev/null; then
    missing_tools+=("git")
  fi
  
  # Check for curl
  if ! command -v curl &> /dev/null; then
    missing_tools+=("curl")
  fi
  
  if [[ ${#missing_tools[@]} -gt 0 ]]; then
    echo "Error: The following required tools are missing:"
    printf '%s\n' "${missing_tools[@]}"
    echo ""
    echo "Please install them first:"
    
    if [[ "$(uname)" = 'Linux' ]]; then
      detect_distro
      echo "Run: $PACKAGE_INSTALL_CMD ${missing_tools[*]}"
    elif [[ "$(uname)" = 'Darwin' ]]; then
      echo "Run: brew install ${missing_tools[*]}"
    fi
    
    exit 1
  fi
}

# Run requirements check
check_requirements

# Run main installation
main

