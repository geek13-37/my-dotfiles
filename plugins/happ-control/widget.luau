--!nonstrict
-- Happ Control - bar status widget.
--
-- Click launches the Happ GUI (or focuses it, if the GUI treats a second launch as a
-- focus request, which is the common Electron single-instance behavior). Connecting,
-- disconnecting and switching servers all happen inside the Happ window itself - see
-- plugin.toml for why this plugin can't drive that from outside.

local status = { running = false, connected = false, server = nil }

local function cfgString(key, fallback)
  local value = noctalia.getConfig(key)
  if type(value) == "string" and value ~= "" then
    return value
  end
  return fallback
end

local function render()
  if status.connected then
    barWidget.setGlyph(cfgString("connected_glyph", "shield-check"))
    local color = cfgString("connected_color", "primary")
    barWidget.setGlyphColor(color)
    barWidget.setColor(color)
    if noctalia.getConfig("show_server_name") and status.server then
      barWidget.setText(status.server)
    else
      barWidget.setText("")
    end
    barWidget.setTooltip(noctalia.tr("tooltip_connected", { server = status.server or "?" }))
  else
    barWidget.setGlyph(cfgString("disconnected_glyph", "shield-x"))
    local color = cfgString("disconnected_color", "on_surface")
    barWidget.setGlyphColor(color)
    barWidget.setColor(color)
    barWidget.setText("")
    barWidget.setTooltip(status.running and noctalia.tr("tooltip_disconnected") or noctalia.tr("tooltip_stopped"))
  end
end

noctalia.state.watch("happ_status", function(value)
  if type(value) == "table" then
    status = value
    render()
  end
end)

function update()
  render()
end

function onClick()
  local cmd = noctalia.getConfig("launch_command")
  if type(cmd) ~= "string" or cmd == "" then
    cmd = "happ"
  end
  noctalia.runAsync(cmd)
end

render()
