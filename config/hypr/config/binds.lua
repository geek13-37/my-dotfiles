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
bind("Return",               exec("alacritty"))
bind("B",                    exec("firefox"))
bind("CTRL + Y",             exec("firefox https://youtube.com"))
bind("CTRL + SHIFT + C",     exec("firefox https://claude.ai"))
bind("CTRL + G",             exec("firefox https://github.com"))
bind("CTRL + M",             exec("firefox https://mail.proton.me"))
bind("E",                    exec("nautilus"))
bind("CTRL + T",             exec("Telegram"))
bind("CTRL + S",             exec(os.getenv("HOME") .. "/.local/bin/spotify"))  -- keeps the Spicetify theme (bin/spotify)
bind("CTRL + D",             exec("discord"))
bind("CTRL + SHIFT + H",     exec("happ"))
-- Task manager on the Windows combo (no Mod)
hl.bind("CTRL + SHIFT + Escape", exec("gnome-system-monitor"))

-- ─── Noctalia ───
bind("SHIFT + Return",       exec("qs -c boxshell ipc call wallpapers toggle"))
bind("S",                    exec(noct .. "panel-toggle control-center"))
bind("CTRL + Return",        exec("rofi -show drun"))
bind("ALT + L",              exec(noct .. "session lock"))
bind("SHIFT + Q",            exec("qs -c boxshell ipc call session toggle"))
-- clipboard history: pick an entry, it goes back into the clipboard
bind("V",                    exec("cliphist list | rofi -dmenu -p clipboard -display-columns 2 | cliphist decode | wl-copy"))
bind("semicolon",            exec(noct .. "panel-toggle launcher /emo"))
-- calculator (rofi-calc): Enter copies the result
bind("Z",                    exec("rofi -show calc -modi calc -no-show-match -no-sort -calc-command \"echo -n '{result}' | wl-copy\""))
-- Window overview: Noctalia's window switcher
bind("O",                    exec(noct .. "window-switcher"))

-- ─── Media / brightness (work on the lock screen too) ───
-- volume goes straight to PipeWire; boxshell shows the OSD on any change
hl.bind("XF86AudioRaiseVolume",  exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),         { locked = true, repeating = true })
hl.bind("XF86AudioMute",         exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),        { locked = true })
hl.bind("XF86AudioMicMute",      exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),      { locked = true })
hl.bind("XF86AudioNext",         exec("playerctl next"),                                    { locked = true })
hl.bind("XF86AudioPrev",         exec("playerctl previous"),                                { locked = true })
hl.bind("XF86AudioPlay",         exec("playerctl play-pause"),                              { locked = true })
hl.bind("XF86AudioPause",        exec("playerctl pause"),                                   { locked = true })
hl.bind("XF86MonBrightnessUp",   exec("brightnessctl -q -c backlight set 5%+"),            { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", exec("brightnessctl -q -c backlight -n 1 set 5%-"),       { locked = true, repeating = true })

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

-- ─── Screenshots (clipboard + ~/Pictures/Screenshots, bin/screenshot) ───
bind("SHIFT + S",            exec("screenshot region"))
hl.bind("CTRL + SHIFT + 2",  exec("screenshot full"))
hl.bind("CTRL + SHIFT + 3",  exec("screenshot window"))

-- Color picker: click anywhere, the hex goes to the clipboard
bind("C",                    exec("hyprpicker -a"))

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
