#!/bin/bash

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
    lsb-release

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
    zsh

# 5. Quality of Life Tweaks
echo "--- Applying QoL Tweaks ---"


# 6. github repos
# --- Install Fastfetch via PPA ---
echo "--- Adding Fastfetch PPA ---"
sudo add-apt-repository -y ppa:zhanghua/fastfetch
sudo apt update
sudo apt install -y fastfetch

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
