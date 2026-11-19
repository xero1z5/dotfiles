-- ============================================================================
-- Hyprland Main Configuration (Lua)
-- ============================================================================

-- 0. Colors (required by general.lua)
require("hyprland.colors")

-- 1. Monitors
require("hyprland.monitors")

-- 2. Environment Variables
require("hyprland.env")

-- 3. Appearance & General Settings
require("hyprland.general")

-- 4. Executables (Autostart)
require("hyprland.execs")

-- 5. Rules (Window & Layer)
require("hyprland.rules")

-- 6. Keybindings
require("hyprland.keybinds")

-- 7. Generated Monitor Rules (Loads last so nothing overrides the applied layout)
do
    local home = os.getenv("HOME")
    local configPath = home .. "/.config/hypr/hyprmoncfg-monitors.lua"
    local file = io.open(configPath, "r")
    if file then
        file:close()
        dofile(configPath)
    else
        local dotfilePath = home .. "/dotfiles/hypr/hyprmoncfg-monitors.lua"
        local dotfile = io.open(dotfilePath, "r")
        if dotfile then
            dotfile:close()
            dofile(dotfilePath)
        end
    end
end
