#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Use rofi to pick a wallpaper by filename
SELECTED=$(ls "$WALLPAPER_DIR" | while read -r f; do
    echo -en "$f\x00icon\x1f$WALLPAPER_DIR/$f\n"
done | rofi -dmenu -p "Wallpaper" -show-icons \
    -theme-str 'window {width: 800px;} element {size: 100px;}')

# Exit if nothing was selected
[ -z "$SELECTED" ] && exit 0

WALLPAPER_PATH="$WALLPAPER_DIR/$SELECTED"

# Set the wallpaper with swww
swww img "$WALLPAPER_PATH" \
    --transition-type wipe \
    --transition-duration 1

# Generate colors with matugen (reads your config.toml automatically)
matugen image "$WALLPAPER_PATH"

# Reload all running kitty instances live
kill -SIGUSR1 $(pidof kitty) 2>/dev/null
