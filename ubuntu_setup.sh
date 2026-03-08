#!/bin/bash

# libvirt-clients

# 1. Update and Upgrade System
echo "--- Updating System ---"
sudo apt update && sudo apt upgrade -y

# 2. Install Core Essentials & Build Tools
echo "--- Installing Core Tools ---"
sudo apt install -y \
    ubuntu-restricted-extras \
    build-essential \
    curl \
    git \
    wget \
    ca-certificates \
    gnupg \
    lsb-release \
    python3-pip \ 
    meson \ 
    ninja-build

# 2.3 Install pyenv developement libraries 
echo "--- Installing pyenv developement libraries ---"
sudo apt install -y \ 
     make \
     libssl-dev \
     zlib1g-dev \
     libbz2-dev \
     libreadline-dev \
     libsqlite3-dev \
     libncursesw5-dev \ 
     xz-utils \
     tk-dev \
     libxml2-dev \
     libxmlsec1-dev \ 
     libffi-dev \
     liblzma-dev \
     libzstd-dev

# 3. Install i3 Ecosystem & Utilities
echo "--- Installing i3wm Desktop Utilities ---"
sudo apt install -y \
    i3 \
    rofi \
    picom \
    nitrogen \
    feh \
    pavucontrol \
    thunar \
    arandr \
    network-manager-gnome \
    lxappearance # For changing GTK themes/icons in i3

# 4. Install Modern CLI Tools
echo "--- Installing Modern CLI Alternatives ---"
sudo apt install -y \
    htop \
    neofetch \
    bat \
    fzf \
    ripgrep \
    pipx \
    zsh \
    btop \
    bash-argsparse \  
    bash-builtins \   
    bash-completion

echo "--- Installing Power User Utilities ---"
sudo apt install -y \
    kitty \
    ranger \
    tmux \
    tmuxp \
    dunst \
    neovim \
    bottom \
    ncdu \
    tldr 

# 5. Quality of Life Tweaks
echo "--- Applying QoL Tweaks ---"

# 1. Get the latest release download URL for the amd64 .deb file
FF_DEB_URL=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest \
    | grep "browser_download_url.*linux-amd64.deb" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | xargs)

# 2. Download and install
wget -qO /tmp/fastfetch.deb "$FF_DEB_URL"
sudo apt install -y /tmp/fastfetch.deb

# 3. Clean up
rm /tmp/fastfetch.deb

echo "Fastfetch installed successfully!"

# 4. pipx install
pipx install bandit buku doc2dash fpm mackup papis pipenv pre-commit ruff trash-cli uv

# Fix 'bat' command name (Ubuntu calls it batcat)
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

# Create standard config directories
mkdir -p ~/.config/i3
mkdir -p ~/.config/picom
mkdir -p ~/.config/rofi

# Optional: Set Zsh as default shell (uncomment if desired)
# chsh -s $(which zsh)

echo "------------------------------------------------"
echo "Setup Complete! Please restart your VM or i3."
echo "------------------------------------------------"
