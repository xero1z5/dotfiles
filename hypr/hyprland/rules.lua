-- ~/dotfiles/hypr/hyprland/rules.lua

-- =====================================================
-- 1. GENERAL WINDOW BEHAVIOR
-- =====================================================

-- Ignore maximize requests from all apps (prevents apps from taking full screen instead of tiling)
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Disable blur for xwayland context menus (empty class+title)
hl.window_rule({
    match = { class = "^()$", title = "^()$" },
    no_blur = true,
})

-- No shadow for tiled windows
hl.window_rule({
    match = { float = false },
    no_shadow = true,
})

-- =====================================================
-- 2. FLOATING WINDOWS (Dialogs & Popups)
-- =====================================================

-- Standard file dialogs
hl.window_rule({
    match = { title = "^(Open File)(.*)$" },
    float = true,
    center = true,
})

hl.window_rule({
    match = { title = "^(Select a File)(.*)$" },
    float = true,
    center = true,
})

hl.window_rule({
    match = { title = "^(Choose wallpaper)(.*)$" },
    float = true,
    center = true,
    size = "(monitor_w*.60) (monitor_h*.65)",
})

hl.window_rule({
    match = { title = "^(Open Folder)(.*)$" },
    float = true,
    center = true,
})

hl.window_rule({
    match = { title = "^(Save As)(.*)$" },
    float = true,
    center = true,
})

hl.window_rule({
    match = { title = "^(Library)(.*)$" },
    float = true,
    center = true,
})

hl.window_rule({
    match = { title = "^(File Upload)(.*)$" },
    float = true,
    center = true,
})

-- Browser download/open prompts
hl.window_rule({
    match = { title = "^(.*)(wants to save)$" },
    float = true,
    center = true,
})

hl.window_rule({
    match = { title = "^(.*)(wants to open)$" },
    float = true,
    center = true,
})

-- System apps
hl.window_rule({
    match = { class = "^(pavucontrol)$" },
    float = true,
    center = true,
    size = "(monitor_w*.45) (monitor_h*.45)",
})

hl.window_rule({
    match = { class = "^(org.pulseaudio.pavucontrol)$" },
    float = true,
    center = true,
    size = "(monitor_w*.45) (monitor_h*.45)",
})

hl.window_rule({
    match = { class = "^(blueman-manager)$" },
    float = true,
})

hl.window_rule({
    match = { class = "^(nm-connection-editor)$" },
    float = true,
    center = true,
    size = "(monitor_w*.45) (monitor_h*.45)",
})

-- Picture-in-Picture (case-insensitive, all variants)
hl.window_rule({
    match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float = true,
    pin = true,
    keep_aspect_ratio = true,
    move = "(monitor_w*.73) (monitor_h*.72)",
    size = "(monitor_w*.25) (monitor_h*.25)",
})

-- For waypaper
hl.window_rule({
    match = { class = "^(waypaper)" },
    float = true,
})

-- =====================================================
-- 3. RICE AESTHETICS (Transparency)
-- =====================================================

hl.window_rule({
    match = { class = "^(kitty)$" },
    opacity = "0.90 0.90",
})

hl.window_rule({
    match = { class = "^(neovide)$" },
    opacity = "0.90 0.90",
    no_shadow = true,
})

-- =====================================================
-- 4. GAMING & PERFORMANCE (Tearing)
-- =====================================================

hl.config({
    general = {
        allow_tearing = true,
    },
})

hl.window_rule({
    match = { title = ".*\\.exe" },
    immediate = true,
})

hl.window_rule({
    match = { title = ".*minecraft.*" },
    immediate = true,
})

hl.window_rule({
    match = { class = "^(steam_app).*" },
    immediate = true,
})

hl.window_rule({
    match = { class = "^(cs2)$" },
    immediate = true,
})

-- Fix JetBrains IDEs — suppress blank floating windows stealing focus
hl.window_rule({
    match = {
        class = "^jetbrains-.*$",
        float = true,
        title = "^$|^\\s$|^win\\d+$",
    },
    no_initial_focus = true,
})

-- =====================================================
-- 5. WORKSPACE RULES
-- =====================================================

hl.workspace_rule({
    workspace = "special:special",
    gaps_out = 30,
})

-- =====================================================
-- 6. LAYER RULES (Quickshell / AGS / Bars)
-- =====================================================

-- Waybar blur
hl.layer_rule({
    match = { namespace = "waybar" },
    blur = true,
})

-- Global xray (see through layers)
hl.layer_rule({
    match = { namespace = ".*" },
    xray = true,
})

-- Bars & notifications (blur)
hl.layer_rule({
    match = { namespace = "gtk-layer-shell" },
    blur = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    match = { namespace = "notifications" },
    blur = true,
    ignore_alpha = 0.69,
})

hl.layer_rule({
    match = { namespace = "logout_dialog" },
    blur = true,
})

-- Launchers — no animation for speed
hl.layer_rule({ match = { namespace = "walker" },           no_anim = true })
hl.layer_rule({ match = { namespace = "anyrun" },           no_anim = true })
hl.layer_rule({ match = { namespace = "gtk4-layer-shell" }, no_anim = true })
hl.layer_rule({ match = { namespace = "rofi" },             no_anim = true })

-- Quickshell global blur
hl.layer_rule({
    match = { namespace = "quickshell:.*" },
    blur = true,
    blur_popups = true,
    ignore_alpha = 0.79,
})

-- Quickshell animations
hl.layer_rule({ match = { namespace = "quickshell:bar" },               animation = "slide" })
hl.layer_rule({ match = { namespace = "quickshell:sidebarLeft" },       animation = "slide left" })
hl.layer_rule({ match = { namespace = "quickshell:sidebarRight" },      animation = "slide right" })
hl.layer_rule({ match = { namespace = "quickshell:cheatsheet" },        animation = "slide bottom" })
hl.layer_rule({ match = { namespace = "quickshell:dock" },              animation = "slide bottom" })
hl.layer_rule({ match = { namespace = "quickshell:osk" },               animation = "slide bottom", order = -1 })
hl.layer_rule({ match = { namespace = "quickshell:notificationPopup" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "quickshell:reloadPopup" },       animation = "slide" })

-- Quickshell no-anim layers
hl.layer_rule({ match = { namespace = "quickshell:actionCenter" },     no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:lockWindowPusher" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:overlay" },          no_anim = true, ignore_alpha = 1 })
hl.layer_rule({ match = { namespace = "quickshell:overview" },         no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:polkit" },           no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:regionSelector" },   no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:screenshot" },       no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:session" },          no_anim = true, ignore_alpha = 0 })

-- Quickshell special opacity
hl.layer_rule({
    match = { namespace = "quickshell:popup" },
    xray = false,
    ignore_alpha = 1,
})

hl.layer_rule({
    match = { namespace = "quickshell:mediaControls" },
    ignore_alpha = 1,
})

