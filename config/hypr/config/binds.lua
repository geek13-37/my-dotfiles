-- Keybinds.
-- Keyboard is us,ru: binds resolve against the first layout (us),
-- so they work the same with the Russian layout active.

local mod  = "SUPER"
local noct = "noctalia msg "

local function bind(keys, action, flags)
    hl.bind(mod .. " + " .. keys, action, flags)
end

local function exec(cmd)
    return hl.dsp.exec_cmd(cmd)
end

local function layout(msg)
    return hl.dsp.layout(msg)
end

-- ─── Applications ───
bind("Return",               exec("ghostty"))
bind("B",                    exec("firefox"))
bind("CTRL + Y",             exec("firefox https://youtube.com"))
bind("CTRL + SHIFT + C",     exec("firefox https://claude.ai"))
bind("CTRL + G",             exec("firefox https://github.com"))
bind("CTRL + M",             exec("firefox https://mail.proton.me"))
bind("E",                    exec("thunar"))
bind("CTRL + T",             exec("Telegram"))
bind("CTRL + S",             exec("spotify-launcher"))
bind("CTRL + D",             exec("discord"))
bind("CTRL + SHIFT + H",     exec("happ"))

-- ─── Noctalia ───
bind("SHIFT + Return",       exec(noct .. "panel-toggle wallpaper"))
bind("S",                    exec(noct .. "panel-toggle control-center"))
bind("CTRL + Return",        exec(noct .. "panel-toggle launcher"))
bind("ALT + L",              exec(noct .. "session lock"))
bind("SHIFT + Q",            exec(noct .. "panel-toggle session"))
bind("V",                    exec(noct .. "panel-toggle clipboard"))
bind("semicolon",            exec(noct .. "panel-toggle launcher /emo"))
bind("Z",                    exec(noct .. "panel-toggle yuuto/calculator:panel"))
-- Window overview: Noctalia's window switcher
bind("O",                    exec(noct .. "window-switcher"))

-- ─── Media / brightness (work on the lock screen too) ───
hl.bind("XF86AudioRaiseVolume",  exec(noct .. "volume-up"),       { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  exec(noct .. "volume-down"),     { locked = true, repeating = true })
hl.bind("XF86AudioMute",         exec(noct .. "volume-mute"),     { locked = true })
hl.bind("XF86AudioMicMute",      exec(noct .. "mic-mute"),        { locked = true })
hl.bind("XF86AudioNext",         exec(noct .. "media next"),      { locked = true })
hl.bind("XF86AudioPrev",         exec(noct .. "media previous"),  { locked = true })
hl.bind("XF86AudioPlay",         exec(noct .. "media play"),      { locked = true })
hl.bind("XF86AudioPause",        exec(noct .. "media stop"),      { locked = true })
hl.bind("XF86MonBrightnessUp",   exec(noct .. "brightness-up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", exec(noct .. "brightness-down"), { locked = true, repeating = true })

-- ─── Window focus / movement ───
bind("Q",                    hl.dsp.window.close())

bind("Left",                 hl.dsp.focus({ direction = "l" }))
bind("H",                    hl.dsp.focus({ direction = "l" }))
bind("Right",                hl.dsp.focus({ direction = "r" }))
bind("L",                    hl.dsp.focus({ direction = "r" }))
bind("Up",                   hl.dsp.focus({ direction = "u" }))
bind("K",                    hl.dsp.focus({ direction = "u" }))
bind("Down",                 hl.dsp.focus({ direction = "d" }))
bind("J",                    hl.dsp.focus({ direction = "d" }))

bind("CTRL + H",             hl.dsp.window.move({ direction = "l" }))
bind("CTRL + L",             hl.dsp.window.move({ direction = "r" }))
bind("CTRL + Up",            hl.dsp.window.move({ direction = "u" }))
bind("CTRL + K",             hl.dsp.window.move({ direction = "u" }))
bind("CTRL + Down",          hl.dsp.window.move({ direction = "d" }))
bind("CTRL + J",             hl.dsp.window.move({ direction = "d" }))

bind("SHIFT + Left",         hl.dsp.focus({ monitor = "l" }))
bind("SHIFT + Right",        hl.dsp.focus({ monitor = "r" }))
bind("SHIFT + Up",           hl.dsp.focus({ monitor = "u" }))
bind("SHIFT + Down",         hl.dsp.focus({ monitor = "d" }))

bind("SHIFT + CTRL + Left",  hl.dsp.window.move({ monitor = "l" }))
bind("SHIFT + CTRL + Right", hl.dsp.window.move({ monitor = "r" }))
bind("SHIFT + CTRL + Up",    hl.dsp.window.move({ monitor = "u" }))
bind("SHIFT + CTRL + Down",  hl.dsp.window.move({ monitor = "d" }))

-- Switch focus between floating and tiled windows
bind("SHIFT + V", function()
    local win = hl.get_active_window()
    hl.dispatch(hl.dsp.window.cycle_next({ floating = not (win and win.floating) }))
end)

-- ─── Dwindle splits / sizes ───
bind("R",                    layout("togglesplit"))   -- flip split: side-by-side <-> stacked
bind("SHIFT + R",            layout("swapsplit"))     -- swap the two halves
bind("P",                    hl.dsp.window.pseudo())
bind("minus",                hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { repeating = true })
bind("equal",                hl.dsp.window.resize({ x = 100,  y = 0, relative = true }), { repeating = true })
bind("SHIFT + minus",        hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { repeating = true })
bind("SHIFT + equal",        hl.dsp.window.resize({ x = 0, y = 100,  relative = true }), { repeating = true })
bind("CTRL + minus",         hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { repeating = true })
bind("CTRL + equal",         hl.dsp.window.resize({ x = 100,  y = 0, relative = true }), { repeating = true })

-- ─── Modes ───
bind("T",                    hl.dsp.window.float({ action = "toggle" }))
bind("F",                    hl.dsp.window.fullscreen({ mode = "maximized" }))
bind("SHIFT + F",            hl.dsp.window.fullscreen({ mode = "fullscreen" }))
bind("M",                    hl.dsp.window.fullscreen({ mode = "maximized", layout_aware = false }))
bind("W",                    hl.dsp.group.toggle())

-- ─── Workspaces ───
for i = 1, 9 do
    bind(tostring(i),            hl.dsp.focus({ workspace = i }))
    bind("CTRL + " .. i,         hl.dsp.window.move({ workspace = i }))
end
bind("Tab",                  hl.dsp.focus({ workspace = "previous" }))
-- workspaces slide horizontally, so Ctrl + Left/Right walks through them
bind("CTRL + Left",          hl.dsp.focus({ workspace = "r-1" }))
bind("CTRL + Right",         hl.dsp.focus({ workspace = "r+1" }))

-- Scratchpad: a hidden terminal that drops down over the current workspace
bind("grave",                hl.dsp.workspace.toggle_special("term"))
bind("SHIFT + grave",        hl.dsp.window.move({ workspace = "special:term" }))
-- Claude Desktop: focus its window (fullscreen, see rules.lua) or launch it
bind("SHIFT + C", function()
    for _, w in ipairs(hl.get_windows()) do
        if w.class == "com.anthropic.Claude" then
            hl.dispatch(hl.dsp.focus({ window = "address:" .. w.address }))
            return
        end
    end
    hl.dispatch(exec("claude-desktop"))
end)

-- ─── Mouse wheel ───
bind("mouse_down",                 hl.dsp.focus({ workspace = "r+1" }))
bind("mouse_up",                   hl.dsp.focus({ workspace = "r-1" }))
bind("CTRL + mouse_down",          hl.dsp.window.move({ workspace = "r+1" }))
bind("CTRL + mouse_up",            hl.dsp.window.move({ workspace = "r-1" }))
bind("mouse_right",                hl.dsp.focus({ direction = "r" }))
bind("mouse_left",                 hl.dsp.focus({ direction = "l" }))
bind("CTRL + mouse_right",         hl.dsp.window.move({ direction = "r" }))
bind("CTRL + mouse_left",          hl.dsp.window.move({ direction = "l" }))

-- Move / resize with Mod + LMB / RMB drag
bind("mouse:272",            hl.dsp.window.drag(),   { mouse = true })
bind("mouse:273",            hl.dsp.window.resize(), { mouse = true })

-- ─── Magnifier: zoom the screen around the cursor ───
local zoom = 1.0
local function set_zoom(factor)
    zoom = math.max(1.0, math.min(factor, 10.0))
    hl.config({ cursor = { zoom_factor = zoom } })
end
bind("ALT + equal",          function() set_zoom(zoom * 1.25) end, { repeating = true })
bind("ALT + minus",          function() set_zoom(zoom / 1.25) end, { repeating = true })
bind("ALT + mouse_up",       function() set_zoom(zoom * 1.25) end)
bind("ALT + mouse_down",     function() set_zoom(zoom / 1.25) end)
bind("ALT + 0",              function() set_zoom(1.0) end)

-- ─── Screenshots (to clipboard) ───
bind("SHIFT + S",            exec(noct .. "screenshot-region"))
hl.bind("CTRL + SHIFT + 2",  exec(noct .. "screenshot-fullscreen"))
hl.bind("CTRL + SHIFT + 3",  exec([[grim -g "$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | wl-copy -t image/png]]))

-- ─── Escape hatch ───
-- Keyboard shortcuts inhibit: Hyprland has no such toggle, so
-- Mod+Escape enters a "passthrough" submap (all keys go to the app) and
-- Mod+Escape again leaves it.
bind("Escape",               hl.dsp.submap("passthrough"), { dont_inhibit = true })
hl.define_submap("passthrough", function()
    bind("Escape",           hl.dsp.submap("reset"), { dont_inhibit = true })
end)

-- ─── Exit / power ───
hl.bind("CTRL + ALT + Delete", exec("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
bind("SHIFT + P",            exec(noct .. "dpms-off"))
