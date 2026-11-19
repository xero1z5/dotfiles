#!/usr/bin/env bash
# ~/dotfiles/hypr/scripts/audio.sh
# Selects default audio output sink using rofi

ROFI_CMD="rofi -dmenu -theme ~/.config/rofi/launcher/config.rasi"

default_sink=$(pactl get-default-sink)

# Build list of sinks: display name -> sink name
declare -A sinks
menu_items=""

while IFS='|' read -r id desc name; do
    [[ -z "$name" ]] && continue
    if [[ "$name" == "$default_sink" ]]; then
        label="󰓃 $desc  (Active)"
    else
        label="󰕿 $desc"
    fi
    sinks["$label"]="$name"
    menu_items+="${label}\n"
done < <(pactl list sinks | awk '
    /^Sink #[0-9]+/ { id = $2 }
    /Description:/ { sub(/^[ \t]*Description: /, ""); desc = $0 }
    /Name:/ { sub(/^[ \t]*Name: /, ""); name = $0 }
    /Active Port:/ { print id "|" desc "|" name }
')

# Also add Pavucontrol option
menu_items+="󰍰 Open Audio Mixer (pavucontrol)"

chosen=$(printf "%b" "$menu_items" | $ROFI_CMD -p "󰕾 Audio Output")
[[ -z "$chosen" ]] && exit 0

if [[ "$chosen" == "󰍰 Open Audio Mixer (pavucontrol)" ]]; then
    pavucontrol &
elif [[ -n "${sinks["$chosen"]}" ]]; then
    target_sink="${sinks["$chosen"]}"
    pactl set-default-sink "$target_sink"
    # Move active playback streams to new default
    pactl list short sink-inputs | while read -r stream_id _; do
        pactl move-sink-input "$stream_id" "$target_sink" 2>/dev/null
    done
    clean_desc=$(echo "$chosen" | sed -E 's/^󰓃 |^󰕿 //; s/  \(Active\)//')
    notify-send -a "Audio" "Output Switched" "$clean_desc"
fi

