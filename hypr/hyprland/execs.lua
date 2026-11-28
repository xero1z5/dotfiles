-- ~/dotfiles/hypr/hyprland/execs.lua

local home = os.getenv("HOME")

hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    hl.exec_cmd("swww-daemon")

    hl.exec_cmd("kanshi")

    -- Desktop Shell: Toggle between Quickshell and Waybar
    local USE_QUICKSHELL = true
    if USE_QUICKSHELL then
        hl.exec_cmd("killall dunst waybar 2>/dev/null; quickshell")
        hl.exec_cmd("sh -c 'sleep 0.5 && [ -s ~/.cache/current_wallpaper ] && swww img \"$(cat ~/.cache/current_wallpaper)\"'")
    else
        hl.exec_cmd(home .. "/.config/waybar/launch.sh")
        hl.exec_cmd("hyprpaper")
        hl.exec_cmd("blueman-applet")
    end

    hl.exec_cmd("hypridle")

    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
