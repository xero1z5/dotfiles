#!/usr/bin/env bash
# ~/dotfiles/hypr/scripts/brightness.sh
# Interactive brightness scroller via rofi
# Scroll up/down through the menu to adjust brightness live

ROFI_THEME="$HOME/.config/rofi/launcher/config.rasi"
ROFI=(rofi -dmenu -theme "$ROFI_THEME" -theme-str 'window { width: 520px; }' -no-custom -me-select-entry '' -me-accept-entry MousePrimary)

# ── helpers ───────────────────────────────────────────────────────────────────
get_brightness() {
    local cur max
    cur=$(brightnessctl get)
    max=$(brightnessctl max)
    echo $(( cur * 100 / max ))
}

set_brightness() {
    brightnessctl set "${1}%" -q
}

make_bar() {
    local pct=$1
    local filled=$(( pct / 5 ))     # out of 20 blocks
    local empty=$(( 20 - filled ))
    local bar=""
    for (( i=0; i<filled; i++ )); do bar+="█"; done
    for (( i=0; i<empty;  i++ )); do bar+="░"; done
    echo "$bar"
}

show_menu() {
    local pct=$1
    local bar
    bar=$(make_bar "$pct")

    printf "   %s  %d%%\n" "$bar" "$pct"
    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    printf "  󰃠   +10%%  (→ %d%%)\n"  "$(( pct + 10 < 101 ? pct + 10 : 100 ))"
    printf "  󰃟    +5%%  (→ %d%%)\n"  "$(( pct +  5 < 101 ? pct +  5 : 100 ))"
    printf "  󰃞    -5%%  (→ %d%%)\n"  "$(( pct -  5 >   0 ? pct -  5 : 1 ))"
    printf "  󰃝   -10%%  (→ %d%%)\n"  "$(( pct - 10 >   0 ? pct - 10 : 1 ))"
    printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    printf "  󰃠  Max   (100%%)\n"
    printf "  󰃟  High   (75%%)\n"
    printf "  󰃞  Medium (50%%)\n"
    printf "  󰃝  Dim    (25%%)\n"
    printf "  󰃛  Low    (10%%)\n"
    printf "  ✎  Custom…\n"
}

# ── main loop ─────────────────────────────────────────────────────────────────
while true; do
    PCT=$(get_brightness)
    chosen=$(show_menu "$PCT" | "${ROFI[@]}" -p "󰃟  Brightness")
    [[ -z "$chosen" ]] && exit 0

    case "$chosen" in
        *"+10%"*)  NEW=$(( PCT + 10 < 101 ? PCT + 10 : 100 )); set_brightness $NEW ;;
        *"+5%"*)   NEW=$(( PCT +  5 < 101 ? PCT +  5 : 100 )); set_brightness $NEW ;;
        *"-5%"*)   NEW=$(( PCT -  5 >   0 ? PCT -  5 : 1   )); set_brightness $NEW ;;
        *"-10%"*)  NEW=$(( PCT - 10 >   0 ? PCT - 10 : 1   )); set_brightness $NEW ;;
        *"Max"*)   set_brightness 100 ;;
        *"High"*)  set_brightness 75 ;;
        *"Medium"*)set_brightness 50 ;;
        *"Dim"*)   set_brightness 25 ;;
        *"Low"*)   set_brightness 10 ;;
        *"Custom"*)
            val=$(echo "" | "${ROFI[@]:0:4}" -p "󰃟  Set brightness (1–100)")
            [[ -z "$val" ]] && continue
            if [[ "$val" =~ ^[0-9]+$ ]] && (( val >= 1 && val <= 100 )); then
                set_brightness "$val"
            else
                notify-send -a "Brightness" "Invalid value" "Enter a number between 1 and 100"
            fi
            ;;
        *"━"*) continue ;;  # separator — loop again
        *"█"*) continue ;;  # status bar — loop again
        *) continue ;;
    esac
done
