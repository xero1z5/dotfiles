# Arch Linux Hyprland Dotfiles Dependencies

This is a comprehensive list of dependencies required for a new Arch Linux install based on the configuration files in this repository.

## 🪟 Core Desktop & Window Manager
* `hyprland` - The Wayland compositor
* `xdg-desktop-portal-hyprland` - XDG Desktop Portal for Hyprland
* `xdg-desktop-portal-gtk` - Required fallback portal
* `polkit-kde-agent` - Authentication agent (`/usr/lib/polkit-kde-authentication-agent-1`)

## 🎨 UI & Theming Components
* `waybar` - Highly customizable Wayland bar
* `rofi-wayland` - Application launcher, menus, and scripts UI
* `wlogout` - Wayland-based logout menu
* `dunst` - Notification daemon
* `hyprlock` - Screen locker for Hyprland
* `hypridle` - Idle management daemon
* `matugen` - Material color extraction and theme generation
* `kanshi` - Dynamic display configuration

## 🖼️ Wallpapers & Screenshots
* `swww` - Efficient animated wallpaper daemon
* `hyprpaper` - Alternative wallpaper utility (referenced in configs)
* `waypaper` - GUI wallpaper setter for Wayland
* `grimblast-git` (AUR) - Screenshot utility wrapper (or `grim` + `slurp`)
* `hyprpicker` - Wayland color picker

## 🛠️ System Utilities & CLI Tools
* `kitty` - GPU-accelerated terminal emulator
* `dolphin` - KDE File Manager
* `fastfetch` - System information tool
* `wl-clipboard` - Command-line copy/paste utilities (`wl-paste`, `wl-copy`)
* `cliphist` - Wayland clipboard manager
* `brightnessctl` - Backlight control
* `playerctl` - Command-line utility and library for controlling media players
* `neovim` - Terminal-based text editor
* `zsh` - Z shell
* `starship` - Cross-shell prompt
* `oh-my-posh` - Custom prompt engine (referenced in dotfiles)

## 🛜 Network & Bluetooth
* `networkmanager` - Required for `nmcli` (used in `wifi.sh`)
* `bluez` & `bluez-utils` - Required for `bluetoothctl` (used in `bluetooth.sh`)
* `blueman` - GTK+ Bluetooth manager (used in `bluetooth.sh`)

## 🔉 Audio
* `pipewire` & `wireplumber` - Required for `wpctl` volume control
* `pipewire-pulse` - PulseAudio drop-in replacement
* `pavucontrol` - PulseAudio Volume Control GUI

## 🅰️ Fonts
* `ttf-jetbrains-mono-nerd` - Used in kitty, rofi, waybar, and hyprlock
* `ttf-lexend` - Used in waybar and rofi

## 🚀 Applications
* `zen-browser-bin` (AUR) - Web Browser
* `spotify` (AUR) - Music Player

---

### Installation Example (using `paru` or `yay`):

```bash
# Official Repositories
sudo pacman -S hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk polkit-kde-agent \
waybar wlogout dunst hyprlock hypridle kitty dolphin fastfetch wl-clipboard cliphist \
brightnessctl playerctl neovim zsh starship networkmanager bluez bluez-utils blueman \
pipewire wireplumber pipewire-pulse pavucontrol ttf-jetbrains-mono-nerd \
ttf-lexend

# AUR Packages
paru -S rofi-wayland swww waypaper matugen-bin grimblast-git hyprpicker \
zen-browser-bin spotify oh-my-posh-bin kanshi
```
