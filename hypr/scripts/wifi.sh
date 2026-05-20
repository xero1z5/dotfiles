#!/usr/bin/env bash
# ~/dotfiles/hypr/scripts/wifi.sh
# WiFi manager with proper password overlay, show/hide toggle, and network management

THEME_LIST="$HOME/.config/rofi/launcher/config.rasi"
THEME_PASS="$HOME/.config/rofi/wifi/password.rasi"
THEME_OPTS="$HOME/.config/rofi/wifi/options.rasi"

ROFI_LIST=(rofi -dmenu -theme "$THEME_LIST" -theme-str 'window { width: 620px; }' -me-select-entry '' -me-accept-entry MousePrimary -me-accept-custom MouseSecondary)
ROFI_PASS=(rofi -dmenu -theme "$THEME_PASS" -me-select-entry '' -me-accept-entry MousePrimary)
ROFI_OPTS=(rofi -dmenu -theme "$THEME_OPTS" -no-custom -me-select-entry '' -me-accept-entry MousePrimary)

notify() { notify-send -a "WiFi" "$1" "$2" -t 3000; }

# ── signal icon ───────────────────────────────────────────────────────────────
signal_icon() {
    if   (( $1 >= 80 )); then echo "󰤨"
    elif (( $1 >= 60 )); then echo "󰤥"
    elif (( $1 >= 40 )); then echo "󰤢"
    elif (( $1 >= 20 )); then echo "󰤟"
    else                      echo "󰤯"
    fi
}

# ── build network list ────────────────────────────────────────────────────────
declare -a DISPLAY_LINES
declare -A SSID_MAP

build_list() {
    DISPLAY_LINES=()
    SSID_MAP=()
    declare -A seen

    declare -A known_conns
    while read -r name; do
        [[ -n "$name" ]] && known_conns["$name"]=1
    done < <(nmcli -t -f NAME con show 2>/dev/null)

    while IFS=: read -r inuse ssid signal _rest; do
        [[ -z "$ssid" ]] && continue
        [[ -n "${seen[$ssid]}" ]] && continue
        seen["$ssid"]=1

        local icon active saved lock
        icon=$(signal_icon "$signal")
        [[ "$inuse" == "*" ]] && active="  " || active="    "

        # Is there a saved connection profile?
        [[ -n "${known_conns[$ssid]}" ]] && saved="󰆼 " || saved="   "

        # Security check
        local sec="$_rest"
        [[ -n "$sec" && "$sec" != "--" ]] && lock="󰌋" || lock=" "

        local line
        line=$(printf "%s%s  %-30s %3s%%  %s %s" \
               "$active" "$icon" "$ssid" "$signal" "$lock" "$saved")

        DISPLAY_LINES+=("$line")
        SSID_MAP["$line"]="$ssid"
    done < <(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list --rescan no 2>/dev/null \
             | sort -t: -k3 -rn)
}

# ── password dialog ───────────────────────────────────────────────────────────
# Returns the entered password in $PASSWORD_RESULT, or empty if cancelled
PASSWORD_RESULT=""

password_dialog() {
    local ssid="$1"
    local hide=true   # start hidden

    while true; do
        local toggle_label
        if $hide; then
            toggle_label="󰈉"
        else
            toggle_label="󰈈"
        fi

        local pass_flags=()
        $hide && pass_flags=(-password)

        # The message shows the network name as a header
        # We feed the toggle option as a list item
        local chosen
        chosen=$(printf '%s' "$toggle_label" | \
                 "${ROFI_PASS[@]}" \
                     "${pass_flags[@]}" \
                     -p "󱛅 $ssid" \
                     -mesg "󰤨  Connect to Wi-Fi network" \
                     -lines 1)

        # If user pressed Escape / closed → cancel
        local exit_code=$?
        [[ $exit_code -ne 0 ]] && PASSWORD_RESULT="" && return 1

        # If they selected the toggle item → flip visibility
        if [[ "$chosen" == "$toggle_label" ]]; then
            $hide && hide=false || hide=true
            continue
        fi

        # Otherwise chosen is the typed password
        PASSWORD_RESULT="$chosen"
        return 0
    done
}

# ── network options (for saved/connected networks) ────────────────────────────
network_options() {
    local ssid="$1"
    local is_connected="$2"  # "yes" or "no"

    local opts=()
    [[ "$is_connected" == "yes" ]] && opts+=("󰤮  Disconnect from $ssid")
    nmcli con show "$ssid" &>/dev/null && opts+=("󰩅  Forget  $ssid")
    opts+=("󰅙  Cancel")

    local chosen
    chosen=$(printf '%s\n' "${opts[@]}" | \
             "${ROFI_OPTS[@]}" \
                 -mesg "  $ssid" \
                 -lines "${#opts[@]}")

    case "$chosen" in
        *"Disconnect"*)
            nmcli con down "$ssid" && notify "Disconnected" "$ssid" \
                || notify "Error" "Could not disconnect from $ssid"
            ;;
        *"Forget"*)
            if nmcli con delete "$ssid" 2>/dev/null; then
                notify "Forgotten" "Removed saved profile for $ssid"
            else
                notify "Error" "Could not remove $ssid"
            fi
            ;;
        *) ;;  # Cancel or empty
    esac
}

# ── connect logic ─────────────────────────────────────────────────────────────
connect() {
    local ssid="$1"
    local is_active="$2"  # "yes" if currently connected

    local force_manage="$3"

    # If user right-clicked, immediately show management options
    if [[ "$force_manage" == "yes" ]]; then
        network_options "$ssid" "$is_active"
        return
    fi

    # Left-click: directly connect if it's not active, or just do nothing if active
    if nmcli con show "$ssid" &>/dev/null; then
        if [[ "$is_active" != "yes" ]]; then
            notify "Connecting…" "$ssid"
            nmcli con up "$ssid" \
                && notify "Connected" "$ssid" \
                || notify "Failed" "Could not connect to $ssid"
        else
            notify "WiFi" "Already connected to $ssid"
        fi
        return
    fi

    # New network — check security (we need nmcli here because it's a direct connect call)
    local sec
    sec=$(nmcli -t -f SSID,SECURITY dev wifi list --rescan no 2>/dev/null \
          | grep "^${ssid}:" | head -1 | cut -d: -f2-)

    if [[ -z "$sec" || "$sec" == "--" ]]; then
        notify "Connecting…" "$ssid (open network)"
        nmcli dev wifi connect "$ssid" \
            && notify "Connected" "$ssid" \
            || notify "Failed" "Could not connect to $ssid"
    else
        # Show password overlay
        if password_dialog "$ssid"; then
            [[ -z "$PASSWORD_RESULT" ]] && return
            notify "Connecting…" "$ssid"
            nmcli dev wifi connect "$ssid" password "$PASSWORD_RESULT" \
                && notify "Connected" "$ssid" \
                || notify "Wrong password" "Could not connect to $ssid"
        fi
    fi
}

# ── toggle wifi ───────────────────────────────────────────────────────────────
toggle_wifi() {
    if [[ "$(nmcli radio wifi)" == "enabled" ]]; then
        nmcli radio wifi off && notify "WiFi" "Turned off"
    else
        nmcli radio wifi on  && notify "WiFi" "Turned on — scanning…"
    fi
}

# ── main ──────────────────────────────────────────────────────────────────────
wifi_on=$(nmcli radio wifi)

TOGGLE_ITEM="󰤭  Turn WiFi Off"
SEP="────────────────────────────────────────────────────────"

if [[ "$wifi_on" == "enabled" ]]; then
    build_list
    menu_items=("$TOGGLE_ITEM" "$SEP" "${DISPLAY_LINES[@]}")
else
    TOGGLE_ITEM="󰤨  Turn WiFi On"
    menu_items=("$TOGGLE_ITEM")
fi

chosen=$(printf '%s\n' "${menu_items[@]}" | \
         "${ROFI_LIST[@]}" -p "󱛅  Wi-Fi" -i)
exit_code=$?

[[ -z "$chosen" ]] && exit 0

case "$chosen" in
    "$TOGGLE_ITEM") toggle_wifi ;;
    "$SEP")         exit 0 ;;
    *)
        raw_ssid="${SSID_MAP[$chosen]}"
        [[ -z "$raw_ssid" ]] && exit 0

        # Check if this network is currently active
        is_active="no"
        nmcli -t -f IN-USE,SSID dev wifi list --rescan no 2>/dev/null \
            | grep "^\*:${raw_ssid}:" &>/dev/null && is_active="yes"

        # Check if user right-clicked (custom accept)
        # rofi's me-accept-custom exits with 1 (same as cancel) but outputs the text.
        # Since we already check [[ -z "$chosen" ]] above, any non-zero exit here is a right-click.
        force_manage="no"
        [[ $exit_code -ne 0 ]] && force_manage="yes"

        connect "$raw_ssid" "$is_active" "$force_manage"
        ;;
esac
