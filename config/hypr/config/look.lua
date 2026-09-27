-- Layout is dwindle: every new window splits the focused one in half (spiral).
hl.config({
    general = {
        layout = "dwindle",

        -- 16px between windows and around the edges
        gaps_in  = 8,
        gaps_out = 16,

        border_size = 1,
        col = {
            -- kanagawa (noctalia primary / surface variant)
            active_border   = "rgb(76946A)",
            inactive_border = "rgb(2A2A37)",
        },

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
        rounding = 3,

        -- slight transparency so the blur behind windows shows through
        active_opacity     = 0.95,
        inactive_opacity   = 0.90,
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
            size    = 4,
            passes  = 2,
            noise   = 0.02,
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
        -- let apps (e.g. Noctalia notifications) focus their windows
        focus_on_activate = true,
    },

    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },
})
