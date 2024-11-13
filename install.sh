#!/bin/bash

# Update and upgrade system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y zsh git stow kubectx fzf bat vim neovim

# Set up configuration directory
CONFIG_DIR=${HOME}/.config

# Install oh-my-zsh in configuration directory
ZSH_CONFIG_DIR=${CONFIG_DIR}/oh-my-zsh
ZSH="$ZSH_CONFIG_DIR" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Update ZSH_CUSTOM path to point to configuration directory
ZSH_CUSTOM=${ZSH_CONFIG_DIR}/custom

# Install zsh plugins and theme
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# Install fastfetch
curl -L -o fastfetch-linux-amd64.deb https://github.com/fastfetch-cli/fastfetch/releases/download/2.29.0/fastfetch-linux-amd64.deb
sudo dpkg -i fastfetch-linux-amd64.deb && rm fastfetch-linux-amd64.deb

# Clone dotfiles repository and apply configuration using stow
DOTFILES_DIR=${HOME}/.dotfiles
if [ ! -d "\$DOTFILES_DIR" ]; then
  git clone https://github.com/icedmac/dotfiles.git $DOTFILES_DIR
fi
cd $DOTFILES_DIR
stow *

# Update .zshrc to source from new oh-my-zsh location
# sed -i 's|export ZSH=.*|export ZSH="$ZSH_CONFIG_DIR"|' ~/.zshrc

# exec zsh to apply changes
zsh

# Installation complete
echo "Installation complete!"
