#!/usr/bin/env bash
# ~/dotfiles/hypr/scripts/wifi.sh
# WiFi manager — action-menu approach (no fragile right-click exit codes)

THEME_LIST="$HOME/.config/rofi/launcher/config.rasi"
THEME_PASS="$HOME/.config/rofi/wifi/password.rasi"
THEME_OPTS="$HOME/.config/rofi/wifi/options.rasi"

ROFI_LIST=(rofi -dmenu -theme "$THEME_LIST"
    -theme-str 'window { width: 620px; }'
    -me-select-entry '' -me-accept-entry MousePrimary)

ROFI_PASS=(rofi -dmenu -theme "$THEME_PASS"
    -me-select-entry '' -me-accept-entry MousePrimary)

ROFI_OPTS=(rofi -dmenu -theme "$THEME_OPTS" -no-custom
    -me-select-entry '' -me-accept-entry MousePrimary)

notify() { notify-send -a "WiFi" "$1" "$2" -t 3000; }

# ── signal icon ───────────────────────────────────────────────────────────────
signal_icon() {
    local s=$1
    if   (( s >= 80 )); then echo "󰤨"
    elif (( s >= 60 )); then echo "󰤥"
    elif (( s >= 40 )); then echo "󰤢"
    elif (( s >= 20 )); then echo "󰤟"
    else                     echo "󰤯"
    fi
}

# ── build network list ────────────────────────────────────────────────────────
# Stores display lines in DISPLAY_LINES[] and maps index → ssid in SSID_BY_IDX[]
# Also stores per-index metadata: IS_ACTIVE[], IS_SAVED[], HAS_SECURITY[]
declare -a DISPLAY_LINES SSID_BY_IDX IS_ACTIVE IS_SAVED HAS_SECURITY

build_list() {
    DISPLAY_LINES=()
    SSID_BY_IDX=()
    IS_ACTIVE=()
    IS_SAVED=()
    HAS_SECURITY=()
    declare -A seen

    # Gather known/saved connection profiles
    declare -A known_conns
    while read -r name; do
        [[ -n "$name" ]] && known_conns["$name"]=1
    done < <(nmcli -t -f NAME con show 2>/dev/null)

    local idx=0
    while IFS=: read -r inuse ssid signal sec_rest; do
        [[ -z "$ssid" ]] && continue
        [[ -n "${seen[$ssid]}" ]] && continue
        seen["$ssid"]=1

        local icon active_marker saved_marker lock_marker
        icon=$(signal_icon "$signal")

        # Currently connected?
        local is_active="no"
        if [[ "$inuse" == "*" ]]; then
            is_active="yes"
            active_marker="  "
        else
            active_marker="    "
        fi

        # Saved profile?
        local is_saved="no"
        if [[ -n "${known_conns[$ssid]}" ]]; then
            is_saved="yes"
            saved_marker="󰆼 "
        else
            saved_marker="   "
        fi

        # Secured?
        local has_sec="no"
        if [[ -n "$sec_rest" && "$sec_rest" != "--" ]]; then
            has_sec="yes"
            lock_marker="󰌋"
        else
            lock_marker=" "
        fi

        local line
        line=$(printf "%s%s  %-30s %3s%%  %s %s" \
               "$active_marker" "$icon" "$ssid" "$signal" "$lock_marker" "$saved_marker")

        DISPLAY_LINES+=("$line")
        SSID_BY_IDX[$idx]="$ssid"
        IS_ACTIVE[$idx]="$is_active"
        IS_SAVED[$idx]="$is_saved"
        HAS_SECURITY[$idx]="$has_sec"
        (( idx++ ))
    done < <(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list --rescan no 2>/dev/null \
             | sort -t: -k3 -rn)
}

# ── password dialog ───────────────────────────────────────────────────────────
PASSWORD_RESULT=""

password_dialog() {
    local ssid="$1"
    local hide=true

    while true; do
        local toggle_label
        $hide && toggle_label="󰈉" || toggle_label="󰈈"

        local pass_flags=()
        $hide && pass_flags=(-password)

        local chosen
        chosen=$(printf '%s' "$toggle_label" | \
                 "${ROFI_PASS[@]}" \
                     "${pass_flags[@]}" \
                     -p "󱛅 $ssid" \
                     -mesg "󰤨  Connect to Wi-Fi network" \
                     -lines 1)

        local exit_code=$?
        [[ $exit_code -ne 0 ]] && PASSWORD_RESULT="" && return 1

        # Toggle visibility
        if [[ "$chosen" == "$toggle_label" ]]; then
            $hide && hide=false || hide=true
            continue
        fi

        PASSWORD_RESULT="$chosen"
        return 0
    done
}

# ── action menu (for saved / connected networks) ─────────────────────────────
# Shows Connect/Disconnect/Forget/Cancel based on network state
# Returns: 0 if an action was taken, 1 if cancelled
action_menu() {
    local ssid="$1"
    local is_active="$2"
    local is_saved="$3"

    local opts=()

    # Connected → offer disconnect; otherwise offer connect
    if [[ "$is_active" == "yes" ]]; then
        opts+=("󰤮  Disconnect")
    else
        opts+=("󰤨  Connect")
    fi

    # Saved → offer forget
    if [[ "$is_saved" == "yes" ]]; then
        opts+=("󰩅  Forget")
    fi

    opts+=("󰅙  Cancel")

    local chosen
    chosen=$(printf '%s\n' "${opts[@]}" | \
             "${ROFI_OPTS[@]}" \
                 -mesg "  $ssid" \
                 -lines "${#opts[@]}")

    case "$chosen" in
        *"Disconnect"*)
            nmcli con down "$ssid" 2>/dev/null \
                && notify "Disconnected" "$ssid" \
                || notify "Error" "Could not disconnect from $ssid"
            ;;
        *"Connect"*)
            notify "Connecting…" "$ssid"
            nmcli con up "$ssid" 2>/dev/null \
                && notify "Connected" "$ssid" \
                || notify "Failed" "Could not connect to $ssid"
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

# ── connect to a new (unsaved) network ────────────────────────────────────────
connect_new() {
    local ssid="$1"
    local has_sec="$2"

    if [[ "$has_sec" == "yes" ]]; then
        if password_dialog "$ssid"; then
            [[ -z "$PASSWORD_RESULT" ]] && return
            notify "Connecting…" "$ssid"
            nmcli dev wifi connect "$ssid" password "$PASSWORD_RESULT" \
                && notify "Connected" "$ssid" \
                || notify "Wrong password" "Could not connect to $ssid"
        fi
    else
        notify "Connecting…" "$ssid (open network)"
        nmcli dev wifi connect "$ssid" \
            && notify "Connected" "$ssid" \
            || notify "Failed" "Could not connect to $ssid"
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

# ── rescan ────────────────────────────────────────────────────────────────────
rescan_wifi() {
    notify "WiFi" "Scanning for networks…"
    nmcli dev wifi rescan 2>/dev/null
    sleep 1
    # Re-launch self after scan completes
    exec "$0"
}

# ── main ──────────────────────────────────────────────────────────────────────
wifi_on=$(nmcli radio wifi)

TOGGLE_ITEM="󰤭  Turn WiFi Off"
SCAN_ITEM="󰑐  Scan for Networks"
SEP="────────────────────────────────────────────────────────"

if [[ "$wifi_on" == "enabled" ]]; then
    build_list
    menu_items=("$TOGGLE_ITEM" "$SCAN_ITEM" "$SEP" "${DISPLAY_LINES[@]}")
else
    TOGGLE_ITEM="󰤨  Turn WiFi On"
    menu_items=("$TOGGLE_ITEM")
fi

chosen=$(printf '%s\n' "${menu_items[@]}" | \
         "${ROFI_LIST[@]}" -p "󱛅  Wi-Fi" -i)

[[ -z "$chosen" ]] && exit 0

case "$chosen" in
    "$TOGGLE_ITEM") toggle_wifi ;;
    "$SCAN_ITEM")   rescan_wifi ;;
    "$SEP")         exit 0 ;;
    *)
        # Find which index this display line corresponds to
        selected_idx=-1
        for i in "${!DISPLAY_LINES[@]}"; do
            if [[ "${DISPLAY_LINES[$i]}" == "$chosen" ]]; then
                selected_idx=$i
                break
            fi
        done

        [[ $selected_idx -lt 0 ]] && exit 0

        ssid="${SSID_BY_IDX[$selected_idx]}"
        is_active="${IS_ACTIVE[$selected_idx]}"
        is_saved="${IS_SAVED[$selected_idx]}"
        has_sec="${HAS_SECURITY[$selected_idx]}"

        # Saved or connected → show action menu
        # New network → go straight to connect
        if [[ "$is_saved" == "yes" || "$is_active" == "yes" ]]; then
            action_menu "$ssid" "$is_active" "$is_saved"
        else
            connect_new "$ssid" "$has_sec"
        fi
        ;;
esac
