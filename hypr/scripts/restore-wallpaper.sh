#!/bin/bash
# ~/dotfiles/hypr/scripts/restore-wallpaper.sh
# Run this on login via execs.conf to restore the last wallpaper
# and regenerate the full color theme.

CURRENT_WALL="$HOME/.cache/matugen/current_wallpaper"

# Wait for hyprpaper to be ready
sleep 1

if [[ -f "$CURRENT_WALL" ]]; then
    WALLPAPER=$(cat "$CURRENT_WALL")
    if [[ -f "$WALLPAPER" ]]; then
        echo "Restoring wallpaper: $WALLPAPER"
        bash "$HOME/dotfiles/hypr/scripts/wallpaper.sh" "$WALLPAPER"
    else
        echo "Saved wallpaper not found, using fallback"
    fi
else
    echo "No saved wallpaper, using hyprpaper.conf default"
fi
