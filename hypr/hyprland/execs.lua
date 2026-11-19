-- ~/dotfiles/hypr/hyprland/execs.lua

local home = os.getenv("HOME")

hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    hl.exec_cmd("swww-daemon")

    hl.exec_cmd("kanshi")

    hl.exec_cmd(home .. "/.config/waybar/launch.sh")

    hl.exec_cmd("hypridle")

    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("bash " .. home .. "/dotfiles/hypr/scripts/restore-wallpaper.sh")

    hl.exec_cmd("blueman-applet")
end)
