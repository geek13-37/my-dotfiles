-- Window and layer rules

-- Browser Picture-in-Picture: float in the bottom-right corner
hl.window_rule({
    match = { title = "^Picture-in-Picture$" },
    float = true,
    pin   = true,
    keep_aspect_ratio = true,
    move  = { "monitor_w-window_w-16", "monitor_h-window_h-16" },
})

-- Noctalia settings window: floats in the middle like a dialog
hl.window_rule({
    match  = { class = "^(dev\\.)?noctalia\\.Noctalia(\\.Settings)?$" },
    float  = true,
    size   = { 1080, 920 },
    center = true,
})

-- Steam: everything except the main window floats
hl.window_rule({
    match = { class = "^steam$", title = "negative:^[Ss]team$" },
    float = true,
})
hl.window_rule({
    match = { class = "^steam$", title = "^notificationtoasts_\\d+_desktop$" },
    move  = { "monitor_w-window_w-10", "monitor_h-window_h-10" },
    no_initial_focus = true,
})

-- Ignore maximize requests from apps
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

-- Noctalia surfaces (bar, panels, OSD, notifications) are see-through, so let
-- Hyprland blur what is behind them; ignore_alpha skips fully transparent parts
-- of fullscreen layers (wallpaper, desktop widgets) so only real boxes blur.
hl.layer_rule({
    name  = "noctalia",
    match = { namespace = "^noctalia-(bar-.+|panel|attached-panel|notification|dock|osd|window-switcher|desktop-widget-.+)$" },
    blur         = true,
    blur_popups  = true,
    ignore_alpha = 0.3,
})

-- Scratchpad (Mod+`): opening it empty spawns a terminal; wide outer gaps
-- keep it smaller than the screen so it reads as a drop-down
hl.workspace_rule({
    workspace        = "special:term",
    on_created_empty = "alacritty",
    gaps_out         = 80,
})

-- Claude Desktop (Mod+Shift+C): always opens fullscreen
hl.window_rule({
    match      = { class = "^com\\.anthropic\\.Claude$" },
    fullscreen = true,
})

-- Sober (Roblox): no blur and fully opaque
hl.window_rule({
    match   = { class = "^org\\.vinegarhq\\.Sober$" },
    no_blur = true,
    opaque  = true,
})

-- VirtualBox (Manager and VM windows): no blur and fully opaque
hl.window_rule({
    match   = { class = "(?i)^virtualbox( manager| machine)?$" },
    no_blur = true,
    opaque  = true,
})

-- Firefox: no blur and fully opaque
hl.window_rule({
    match   = { class = "^firefox$" },
    no_blur = true,
    opaque  = true,
})

-- Loupe (GNOME image viewer): no blur and fully opaque
hl.window_rule({
    match   = { class = "^org\\.gnome\\.Loupe$" },
    no_blur = true,
    opaque  = true,
})

-- Dota 2 (native, XWayland): fullscreen, opaque, no blur — otherwise every
-- frame gets composited at 85% opacity over a blurred background (big FPS hit)
hl.window_rule({
    match      = { class = "^(dota2|steam_app_570)$" },
    no_blur    = true,
    opaque     = true,
    fullscreen = true,
})
