-- ~/dotfiles/hypr/hyprland/monitors.lua

--------------------
---- MONITORS ------
--------------------

-- Syntax: hl.monitor({ output, mode, position, scale })
-- Run `hyprctl monitors` to list connected monitors and their names

-- External monitor (primary — top-left origin)
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "2560x1440@144",
    position = "0x0",
    scale    = 1,
})

-- Laptop display (auto-positioned to the right of HDMI-A-1)
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@144",
    position = "auto",
    scale    = 1,
})

-- Fallback — any unrecognised monitor gets sane defaults
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

--------------------
---- WORKSPACES ----
--------------------

-- Pin workspaces to monitors
hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1", default = true })
hl.workspace_rule({ workspace = "2", monitor = "eDP-1",    default = true })

-- for neovide swallow
hl.config({
    misc = {
        enable_swallow = true,
        swallow_regex  = "^(kitty)$",
    },
})

--------------------
---- TIPS ----------
--------------------

-- To mirror monitors instead of extend:
--   hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1, mirror = "HDMI-A-1" })

-- To disable the laptop screen when external is connected (common lid-closed setup):
--   hl.monitor({ output = "eDP-1", mode = "disabled" })

-- To change which monitor is on the left vs right, swap the position values:
--   HDMI-A-1 at 1920x0 (right) and eDP-1 at 0x0 (left):
--   hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@144", position = "1920x0", scale = 1 })
--   hl.monitor({ output = "eDP-1",    mode = "1920x1080@144", position = "0x0",    scale = 1 })

-- To use fractional scaling (e.g. for HiDPI):
--   hl.monitor({ output = "eDP-1", mode = "1920x1080@144", position = "auto", scale = 1.5 })
--   (also set hl.env("GDK_SCALE", "2") and hl.env("QT_SCALE_FACTOR", "1.5") in env section)

