#!/bin/bash

# Function to print step summary
print_step() {
  echo -e "\n========== $1 ==========" | tee -a install.log
}

# Function to display usage
print_usage() {
  echo -e "Usage: $0 [OPTIONS]"
  echo -e "\nOptions:"
  echo -e "  --proxy <proxy_url>    Set a proxy URL for all network requests"
  echo -e "  --help                 Display this help message"
  exit 0
}

# Parse arguments
USE_PROXY=false
PROXY_ADDRESS=""
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --proxy)
      USE_PROXY=true
      PROXY_ADDRESS="$2"
      shift 2
      ;;
    --help)
      print_usage
      ;;
    *)
      echo "Unknown option: $1" | tee -a install.log
      exit 1
      ;;
  esac
done

# Set proxy settings if --proxy option is provided
if [ "$USE_PROXY" = true ]; then
  export http_proxy="$PROXY_ADDRESS"
  export https_proxy="$PROXY_ADDRESS"
  export ftp_proxy="$PROXY_ADDRESS"
  export no_proxy="localhost,127.0.0.1,::1"
  print_step "Proxy settings applied: $PROXY_ADDRESS"
else
  print_step "No proxy settings provided"
fi

# Redirect all output to install.log for silent execution and logging
exec > >(tee -a install.log) 2>&1

# Update and upgrade system using apt-get to avoid CLI warnings
print_step "Updating and upgrading system"
sudo apt-get update -qq && sudo apt-get upgrade -y -qq

# Install required packages using apt-get to avoid CLI warnings
print_step "Installing required packages"
sudo apt-get install -y -qq zsh git stow kubectx fzf bat vim

# Set up configuration directory
print_step "Setting up configuration directory"
CONFIG_DIR=${HOME}/.config

# Install oh-my-zsh in configuration directory
print_step "Installing oh-my-zsh in configuration directory"
ZSH_CONFIG_DIR=${CONFIG_DIR}/oh-my-zsh
ZSH="$ZSH_CONFIG_DIR" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Update ZSH_CUSTOM path to point to configuration directory
ZSH_CUSTOM=${ZSH_CONFIG_DIR}/custom

# Install zsh plugins and theme
print_step "Installing zsh plugins and theme"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# Install fastfetch
print_step "Installing fastfetch"
curl -L -o fastfetch-linux-amd64.deb https://github.com/fastfetch-cli/fastfetch/releases/download/2.29.0/fastfetch-linux-amd64.deb
sudo dpkg -i fastfetch-linux-amd64.deb && rm fastfetch-linux-amd64.deb

# Clone dotfiles repository and apply configuration using stow
print_step "Cloning dotfiles repository and applying configuration"
DOTFILES_DIR=${HOME}/.dotfiles

# Clone or update dotfiles repository
if [ ! -d "$DOTFILES_DIR" ]; then
  print_step "Cloning dotfiles repository"
  git clone https://github.com/icedmac/dotfiles.git $DOTFILES_DIR
else
  print_step "Dotfiles directory exists"
fi

# Apply dotfiles configuration using stow
cd $DOTFILES_DIR
print_step "Applying dotfiles configuration"
rm ${HOME}/.zshrc
stow zsh ohmyzsh

# exec zsh to apply changes
print_step "Applying changes and starting zsh"
cd ${HOME}
/usr/bin/zsh
