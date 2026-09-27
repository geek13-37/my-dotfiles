-- Window and layer rules

-- Floating Noctalia settings window
hl.window_rule({
    match = { class = "^(dev\\.)?noctalia\\.Noctalia(\\.Settings)?$" },
    float = true,
    size  = { 1080, 920 },
    center = true,
})

-- Browser Picture-in-Picture: float in the bottom-right corner
hl.window_rule({
    match = { title = "^Picture-in-Picture$" },
    float = true,
    pin   = true,
    keep_aspect_ratio = true,
    move  = { "monitor_w-window_w-16", "monitor_h-window_h-16" },
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

-- Noctalia bar/panels/OSD blur
hl.layer_rule({
    name  = "noctalia",
    match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
    blur         = true,
    blur_popups  = true,
    ignore_alpha = 0.5,
})

-- Scratchpad (Mod+`): opening it empty spawns a terminal; wide outer gaps
-- keep it smaller than the screen so it reads as a drop-down
hl.workspace_rule({
    workspace        = "special:term",
    on_created_empty = "ghostty",
    gaps_out         = 80,
})

-- Claude Desktop scratchpad (Mod+Shift+C): opening it empty launches the
-- app, and its window always lands there instead of a regular workspace
hl.workspace_rule({
    workspace        = "special:claude",
    on_created_empty = "claude-desktop",
    gaps_out         = 80,
})
hl.window_rule({
    match     = { class = "^com\\.anthropic\\.Claude$" },
    workspace = "special:claude silent",
})

-- Sober (Roblox): no blur and fully opaque
hl.window_rule({
    match   = { class = "^org\\.vinegarhq\\.Sober$" },
    no_blur = true,
    opaque  = true,
})
