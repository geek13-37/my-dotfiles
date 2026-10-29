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

-- HyprMod managed settings
require("hyprland-gui")

-- Border colours from the wallpaper, written by boxshell (it also applies
-- them live); missing until boxshell's first run, then look.lua's stay
pcall(dofile, os.getenv("HOME") .. "/.cache/boxshell/hyprland.lua")
