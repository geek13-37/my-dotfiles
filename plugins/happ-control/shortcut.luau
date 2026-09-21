--!nonstrict
-- Happ Control - control-center tile. Mirrors the bar widget's state and action.

local status = { running = false, connected = false, server = nil }

local function render()
  shortcut.setIcon("shield-check", "shield-off")
  shortcut.setActive(status.connected)
  if status.connected then
    shortcut.setLabel(status.server or noctalia.tr("connected"))
  elseif status.running then
    shortcut.setLabel(noctalia.tr("disconnected"))
  else
    shortcut.setLabel(noctalia.tr("stopped"))
  end
end

noctalia.state.watch("happ_status", function(value)
  if type(value) == "table" then
    status = value
    render()
  end
end)

function onClick()
  local cmd = noctalia.getConfig("launch_command")
  if type(cmd) ~= "string" or cmd == "" then
    cmd = "happ"
  end
  noctalia.runAsync(cmd)
end

render()
