-- ~/dotfiles/hypr/hyprland/keybinds.lua

local home = os.getenv("HOME")

-- -----------------------------------------------------
-- MODIFIER KEY
-- -----------------------------------------------------

local mainMod = "SUPER"

-- -----------------------------------------------------
-- PROGRAMS
-- -----------------------------------------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local browser     = "zen-browser"
local wallpaper   = "waypaper"
local menu        = home .. "/.config/rofi/launcher/launcher.sh"
local clipboard   = home .. "/.config/rofi/clipboard/clipboard.sh"
local logout      = home .. "/.config/wlogout/wlogout.sh"

-- -----------------------------------------------------
-- 1. APPLICATIONS
-- -----------------------------------------------------

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Space",  hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + W",      hl.dsp.exec_cmd(wallpaper))
hl.bind(mainMod .. " + V",      hl.dsp.exec_cmd(clipboard))

hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("hyprlock"))
hl.bind("ALT + SHIFT + L",      hl.dsp.exec_cmd(logout))

hl.bind(mainMod .. " + S",      hl.dsp.exec_cmd("spotify"))

-- -----------------------------------------------------
-- 2. WINDOW MANAGEMENT
-- -----------------------------------------------------

hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + T",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())

-- Move focus — arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move focus — vim keys
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Move windows — vim keys
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

-- Resize windows — arrow keys (hold mainMod + CTRL)
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.resize({ x = -40, y = 0,   relative = true }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0,   y = -40, relative = true }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }))

-- Move/resize with mouse drag
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- -----------------------------------------------------
-- 3. WORKSPACES
-- -----------------------------------------------------

-- Switch workspace (1-10)
-- Move window to workspace (1-10)
for i = 1, 10 do
    local key = i % 10 -- 10 maps to 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + Tab",        hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + Tab",hl.dsp.focus({ workspace = "e-1" }))

-- Special workspace (scratchpad)
-- hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- -----------------------------------------------------
-- 4. SESSION
-- -----------------------------------------------------

hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- Screenshot (requires grimblast or grim+slurp)
hl.bind("Print",                   hl.dsp.exec_cmd("grimblast copy area"))
hl.bind("SHIFT + Print",           hl.dsp.exec_cmd("grimblast copy screen"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("grimblast copy active"))

-- hyprshot
-- Captures region, saves to specified output folder, and copies to clipboard
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots"))

-- Color picker (requires hyprpicker)
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

-- -----------------------------------------------------
-- 5. MEDIA & HARDWARE KEYS
-- -----------------------------------------------------

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { repeating = true, locked = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { repeating = true, locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { repeating = true, locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { repeating = true, locked = true })

-- Media controls (requires playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

