#!/bin/bash
# ~/dotfiles/hypr/scripts/wallpaper.sh
# Sets wallpaper, generates Material You palette with matugen,
# then reloads colors for Hyprland, kitty, GTK, and hyprlock.

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/matugen"
CURRENT_WALL="$CACHE_DIR/current_wallpaper"

mkdir -p "$CACHE_DIR"

# -------------------------------------------------------
# 1. PICK WALLPAPER
#    If an argument is passed, use it directly.
#    Otherwise launch the rofi image picker.
# -------------------------------------------------------

if [[ -n "$1" ]]; then
    WALLPAPER="$1"
else
    # Build rofi entries: "display_name\0icon\x1fpath" format
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" \
        -o -iname "*.png" -o -iname "*.webp" \
    \) | while read -r img; do
        echo -en "$(basename "$img")\0icon\x1f${img}\n"
    done | rofi \
        -dmenu \
        -show-icons \
        -theme-str '
            window { width: 900px; height: 600px; }
            listview { columns: 4; lines: 3; }
            element { orientation: vertical; }
            element-icon { size: 180px; }
            element-text { horizontal-align: 0.5; }
        ' \
        -p "Wallpaper" \
        -format p)      # -format p returns the full path from the icon field
fi

# Exit if nothing selected
[[ -z "$WALLPAPER" ]] && exit 0
[[ ! -f "$WALLPAPER" ]] && { echo "File not found: $WALLPAPER"; exit 1; }

echo "Selected: $WALLPAPER"

# -------------------------------------------------------
# 2. SET WALLPAPER via hyprpaper
# -------------------------------------------------------

# Preload and set via hyprctl
hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$WALLPAPER"

# Set on all monitors
hyprctl monitors -j | \
    jq -r '.[].name' | \
    while read -r monitor; do
        hyprctl hyprpaper wallpaper "$monitor,$WALLPAPER"
    done

# Save current wallpaper path for restoration on login
echo "$WALLPAPER" > "$CURRENT_WALL"

# -------------------------------------------------------
# 3. GENERATE MATERIAL YOU PALETTE via matugen
# -------------------------------------------------------

matugen image "$WALLPAPER" \
    --config "$HOME/.config/matugen/config.toml" \
    --json hex > "$CACHE_DIR/colors.json"

# -------------------------------------------------------
# 4. GENERATE PER-APP THEME FILES
#    matugen templates handle this — see config.toml
#    But we manually trigger any extras below.
# -------------------------------------------------------

# Reload GTK theme (xsettingsd or gsettings)
if command -v gsettings &>/dev/null; then
    # matugen writes gtk.css — point GTK to it
    GTK_THEME_DIR="$HOME/.config/gtk-4.0"
    mkdir -p "$GTK_THEME_DIR"
    # matugen template handles the actual file write
    # Just signal gtk apps to reload
    pkill -SIGUSR1 gsd-xsettings 2>/dev/null || true
fi

# Reload kitty (sends SIGUSR1 to all kitty instances)
pkill -SIGUSR1 kitty 2>/dev/null || true

# Reload Hyprland colors (source colors.conf which matugen wrote)
hyprctl reload

# Optional: reload waybar / quickshell if running
pkill -SIGUSR2 waybar 2>/dev/null || true

echo "✓ Wallpaper and theme applied: $(basename "$WALLPAPER")"
