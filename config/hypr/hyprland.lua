-- Hyprland config.
-- Layout is "dwindle" (windows split in half, spiral-style).

require("config.environment")
require("config.monitors")
require("config.input")
require("config.look")
require("config.animations")
require("config.rules")
require("config.binds")
require("config.autostart")

-- HyprMod managed settings. The file is generated on this machine by HyprMod
-- (not in the repo); a fresh install just runs without it.
pcall(require, "hyprland-gui")

-- For Noctalia Color templates
require("noctalia").apply_theme()
