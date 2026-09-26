-- Input (layout taken from localectl: us,ru + Alt+Shift)
hl.config({
    input = {
        kb_layout  = "us,ru",
        kb_options = "grp:alt_shift_toggle",
        numlock_by_default = true,

        -- focus follows mouse: hovering a window focuses it
        follow_mouse = 1,

        accel_profile = "adaptive",
        sensitivity   = -1.0,

        touchpad = {
            tap_to_click   = true,
            natural_scroll = true,
        },
    },
    binds = {
        -- pressing the current workspace key again goes back to the previous one
        workspace_back_and_forth = true,
    },
})
