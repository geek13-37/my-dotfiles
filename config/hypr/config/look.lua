-- Layout is dwindle: every new window splits the focused one in half (spiral).
hl.config({
    general = {
        layout = "dwindle",

        -- tight tiling: 3px between windows; outer gaps line windows up with the
        -- Noctalia bar (14px from the sides), 6px below it
        gaps_in  = 3,
        gaps_out = { top = 6, right = 14, bottom = 14, left = 14 },

        -- no window borders (resize by grabbing the edge still works)
        border_size = 0,
        resize_on_border = true,
    },

    dwindle = {
        -- keep a split's orientation when windows are closed/moved
        preserve_split = true,
        -- split along the longer side of the focused window (spiral)
        force_split    = 2,
        default_split_ratio = 1.0,
    },

    decoration = {
        -- window corner radius
        rounding = 0,

        -- fully opaque windows (no blur, no transparency)
        active_opacity     = 1.0,
        inactive_opacity   = 1.0,
        fullscreen_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 30,
            render_power = 3,
            offset       = { 0, 5 },
            color        = "rgba(03050d99)",
        },

        blur = {
            enabled = true,
            size    = 8,
            passes  = 3,
            noise   = 0.02,
            vibrancy = 0.2,
        },
    },

    group = {
        -- tabbed groups (Mod+W): new windows get their own tile
        -- instead of joining the group
        auto_group = false,
    },

    misc = {
        disable_hyprland_logo   = true,
        force_default_wallpaper = 0,
        -- let apps (e.g. clicked notifications) focus their windows
        focus_on_activate = true,
    },

    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },
})
