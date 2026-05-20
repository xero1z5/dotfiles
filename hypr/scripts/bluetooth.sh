#!/usr/bin/env bash
# ~/dotfiles/hypr/scripts/bluetooth.sh
# Opens blueman-manager (already installed) or falls back to a rofi BT menu

notify() {
    notify-send -a "Bluetooth" "$1" "$2"
}

toggle_bluetooth() {
    state=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')
    if [[ "$state" == "yes" ]]; then
        bluetoothctl power off
        notify "Bluetooth" "Turned off"
    else
        bluetoothctl power on
        notify "Bluetooth" "Turned on"
    fi
}

# If blueman-manager is available, open it directly
if command -v blueman-manager &>/dev/null; then
    blueman-manager
else
    # Fallback: simple rofi menu
    ROFI_CMD="rofi -dmenu -theme ~/.config/rofi/launcher/config.rasi"

    bt_state=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')
    [[ "$bt_state" == "yes" ]] \
        && toggle_label="󰂲  Turn Bluetooth Off" \
        || toggle_label="󰂯  Turn Bluetooth On"

    chosen=$(printf "%s\n󰂳  Open Blueman Manager" "$toggle_label" | $ROFI_CMD -p "󰂯  Bluetooth")
    [[ -z "$chosen" ]] && exit 0

    case "$chosen" in
        "$toggle_label")        toggle_bluetooth ;;
        "󰂳  Open Blueman Manager") blueman-manager ;;
    esac
fi
