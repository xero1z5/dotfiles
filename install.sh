#!/usr/bin/env bash

set -e # Exit on error

# Terminal colors
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${BLUE}Starting Dotfiles Installation...${RESET}"

# ==============================================================================
# 1. Packages Lists
# ==============================================================================
# Official Arch repo packages
PKGS=(
    hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk polkit-kde-agent
    waybar wlogout dunst hyprlock hypridle kitty dolphin fastfetch wl-clipboard cliphist
    brightnessctl playerctl neovim zsh starship networkmanager bluez bluez-utils blueman
    pipewire wireplumber pipewire-pulse pavucontrol ttf-jetbrains-mono-nerd ttf-lexend
)

# AUR packages
AUR_PKGS=(
    rofi-wayland swww waypaper matugen-bin grimblast-git hyprpicker zen-browser-bin
    spotify oh-my-posh-bin kanshi
)

# ==============================================================================
# 2. AUR Helper Setup
# ==============================================================================
if ! command -v yay &> /dev/null && ! command -v paru &> /dev/null; then
    echo -e "${GREEN}Installing yay (AUR helper)...${RESET}"
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay-bin
fi

AUR_HELPER="yay"
if command -v paru &> /dev/null; then
    AUR_HELPER="paru"
fi

# ==============================================================================
# 3. Package Installation
# ==============================================================================
echo -e "${GREEN}Installing official repository packages...${RESET}"
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

echo -e "${GREEN}Installing AUR packages using ${AUR_HELPER}...${RESET}"
$AUR_HELPER -S --needed --noconfirm "${AUR_PKGS[@]}"

# ==============================================================================
# 4. System Services
# ==============================================================================
echo -e "${GREEN}Enabling essential system services...${RESET}"
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth

# ==============================================================================
# 5. Symlinking Dotfiles
# ==============================================================================
echo -e "${GREEN}Symlinking configuration files...${RESET}"

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

# Ensure ~/.config exists
mkdir -p "$CONFIG_DIR"

# List of folders in dotfiles/ that go into ~/.config/
CONFIGS=(
    fastfetch hypr kanshi kitty matugen nvim ohmyposh rofi 
    starship waybar waypaper wireplumber wlogout
)

for config in "${CONFIGS[@]}"; do
    if [ -d "$DOTFILES_DIR/$config" ]; then
        # -s for symlink, -f to overwrite, -n to not resolve symlinks as directories
        ln -sfn "$DOTFILES_DIR/$config" "$CONFIG_DIR/$config"
        echo -e "  -> Symlinked $config to $CONFIG_DIR/$config"
    fi
done

# Wallpapers
echo -e "  -> Setting up wallpapers directory..."
mkdir -p "$HOME/Pictures"
ln -sfn "$DOTFILES_DIR/wallpapers" "$HOME/Pictures/wallpapers"

# Zsh
echo -e "  -> Setting up ZSH..."
ln -sfn "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# ==============================================================================
# 6. Finalizing
# ==============================================================================
# Change default shell to Zsh
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo -e "${GREEN}Changing default shell to zsh...${RESET}"
    chsh -s /usr/bin/zsh
fi

echo -e "${BLUE}====================================================${RESET}"
echo -e "${GREEN}Installation Complete!${RESET}"
echo -e "Please reboot your system or log out and start Hyprland."
echo -e "${BLUE}====================================================${RESET}"
