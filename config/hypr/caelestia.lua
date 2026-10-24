-- Window border / group colours from the Caelestia scheme.
-- caelestia-cli writes scheme/current.lua (hex without '#') on every
-- wallpaper or scheme change (cli.json: theme.enableHypr).

local ok, c = pcall(require, "scheme.current")

local function apply_theme()
    if not ok then return end  -- no scheme yet: keep look.lua colours

    local function rgb(name) return "rgb(" .. c[name] .. ")" end

    hl.config({
        general = {
            col = {
                active_border = rgb("primary"),
                inactive_border = rgb("surfaceContainer"),
            },
        },
        group = {
            col = {
                border_active = rgb("secondary"),
                border_inactive = rgb("surfaceContainer"),
                border_locked_active = rgb("error"),
                border_locked_inactive = rgb("surfaceContainer"),
            },

            groupbar = {
                col = {
                    active = rgb("secondary"),
                    inactive = rgb("surfaceContainer"),
                    locked_active = rgb("error"),
                    locked_inactive = rgb("surfaceContainer"),
                },
                text_color = rgb("onSecondary"),
                text_color_inactive = rgb("onSurface"),
                text_color_locked_active = rgb("onError"),
                text_color_locked_inactive = rgb("onSurface"),
            },
        },
    })
end

return { apply_theme = apply_theme }
