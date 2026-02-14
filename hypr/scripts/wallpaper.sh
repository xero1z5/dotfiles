#!/bin/bash
# ~/.config/hypr/scripts/wallpaper.sh

# Usage: ./wallpaper.sh [path/to/image]

img_path=$1

if [ "$1" == "init" ]; then
    # Load last wallpaper or default
    img_path=~/Pictures/Wallpapers/default.jpg
fi

# 1. Apply Wallpaper (with smooth transition)
swww img "$img_path" --transition-type grow --transition-pos 0.9,0.9 --transition-step 90 --transition-fps 60

# 2. Generate Colors using Matugen
# This generates ~/.config/hypr/hyprland/colors.conf
matugen image "$img_path" -t scheme-content 

# 3. Reload Hyprland to apply new border colors
hyprctl reload

# 4. (Optional) Reload Waybar/Quickshell if needed
killall -SIGUSR2 waybar
