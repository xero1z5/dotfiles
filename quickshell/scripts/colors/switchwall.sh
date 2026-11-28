#!/usr/bin/env bash
set -e

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
SHELL_CONFIG_FILE="$XDG_CONFIG_HOME/illogical-impulse/config.json"
STATE_GEN_DIR="$XDG_STATE_HOME/quickshell/user/generated"
CACHE_WALL_FILE="$XDG_CACHE_HOME/current_wallpaper"

mkdir -p "$STATE_GEN_DIR/wallpaper" "$(dirname "$SHELL_CONFIG_FILE")" "$XDG_CACHE_HOME"

imgpath=""
mode_flag=""
type_flag="auto"
color_flag=""
color=""
noswitch_flag=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode)
            mode_flag="$2"
            shift 2
            ;;
        --type)
            type_flag="$2"
            shift 2
            ;;
        --color)
            if [[ "$2" =~ ^#?[A-Fa-f0-9]{6}$ ]]; then
                color_flag="1"
                color="$2"
                shift 2
            elif [[ "$2" == "clear" ]]; then
                shift 2
            else
                shift
            fi
            ;;
        --image)
            imgpath="$2"
            shift 2
            ;;
        --noswitch)
            noswitch_flag="1"
            shift
            ;;
        *)
            if [[ -z "$imgpath" ]]; then
                imgpath="$1"
            fi
            shift
            ;;
    esac
done

# Strip file:// prefix if QML passed a URI
imgpath="${imgpath#file://}"

# If invoked with no target (e.g. "Choose file"), open interactive selector
if [[ -z "$imgpath" && -z "$noswitch_flag" && -z "$color_flag" ]]; then
    qs ipc call wallpaperSelector toggle 2>/dev/null || true
    exit 0
fi

# Resolve current wallpaper for --noswitch
if [[ -z "$imgpath" && -n "$noswitch_flag" ]]; then
    if [[ -f "$SHELL_CONFIG_FILE" ]]; then
        imgpath="$(jq -r '.background.wallpaperPath // empty' "$SHELL_CONFIG_FILE" 2>/dev/null || true)"
    fi
    if [[ -z "$imgpath" && -s "$CACHE_WALL_FILE" ]]; then
        imgpath="$(cat "$CACHE_WALL_FILE")"
    fi
    if [[ -z "$imgpath" ]]; then
        imgpath="$(find "$HOME/dotfiles/wallpapers" -maxdepth 1 -type f 2>/dev/null | head -n1)"
    fi
fi

# Resolve palette type from config if auto
if [[ "$type_flag" == "auto" || -z "$type_flag" ]]; then
    cfg_type="$(jq -r '.appearance.palette.type // "scheme-tonal-spot"' "$SHELL_CONFIG_FILE" 2>/dev/null || echo "scheme-tonal-spot")"
    if [[ "$cfg_type" == "auto" || -z "$cfg_type" || "$cfg_type" == "null" ]]; then
        type_flag="scheme-tonal-spot"
    else
        type_flag="$cfg_type"
    fi
fi

# Resolve dark/light mode
if [[ -z "$mode_flag" ]]; then
    current_scheme="$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | tr -d "'" || true)"
    if [[ "$current_scheme" == "prefer-light" ]]; then
        mode_flag="light"
    else
        mode_flag="dark"
    fi
fi

if [[ "$mode_flag" == "dark" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
fi

# Update wallpaper path in config + swww when switching
if [[ -n "$imgpath" && -f "$imgpath" && -z "$noswitch_flag" ]]; then
    printf '%s\n' "$imgpath" > "$CACHE_WALL_FILE"
    printf '%s\n' "$imgpath" > "$STATE_GEN_DIR/wallpaper/path.txt"
    if [[ -f "$SHELL_CONFIG_FILE" ]]; then
        jq --arg p "$imgpath" '.background.wallpaperPath = $p' "$SHELL_CONFIG_FILE" > "${SHELL_CONFIG_FILE}.tmp" \
            && mv "${SHELL_CONFIG_FILE}.tmp" "$SHELL_CONFIG_FILE"
    fi
    if pgrep -x swww-daemon >/dev/null 2>&1; then
        swww img "$imgpath" --transition-type grow --transition-pos center --transition-fps 60 &
    fi
fi

# Generate Material 3 colors via Matugen
if [[ "$color_flag" == "1" && -n "$color" ]]; then
    matugen color hex "$color" --mode "$mode_flag" --type "$type_flag"
elif [[ -n "$imgpath" && -f "$imgpath" ]]; then
    matugen image "$imgpath" --mode "$mode_flag" --type "$type_flag" --source-color-index 0
fi
