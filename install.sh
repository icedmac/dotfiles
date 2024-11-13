#!/bin/bash

# Function to print step summary
print_step() {
  echo -e "\n========== $1 ==========" | tee -a install.log
}

# Redirect all output to install.log for silent execution and logging
exec > >(tee -a install.log) 2>&1

# Update and upgrade system
print_step "Updating and upgrading system"
sudo apt update -qq && sudo apt upgrade -y -qq

# Install required packages
print_step "Installing required packages"
sudo apt install -y -qq zsh git stow kubectx fzf bat vim neovim

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
if [ ! -d "$DOTFILES_DIR" ]; then
  git clone https://github.com/icedmac/dotfiles.git $DOTFILES_DIR
fi
cd $DOTFILES_DIR
rm ${HOME}/.zshrc
stow zsh ohmyzsh
cd

# exec zsh to apply changes
print_step "Applying changes and starting zsh"
zsh

# Installation complete
print_step "Installation complete"

