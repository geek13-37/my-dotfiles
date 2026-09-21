--!nonstrict
-- Happ Control - background status monitor.
--
-- Publishes { running, connected, server } to noctalia.state under "happ_status" so
-- the bar widget and the control-center shortcut can both render it without polling
-- twice. See plugin.toml for why this only observes state instead of driving the
-- tunnel: Happ has no public control API on Linux.

local function cfg(key)
  return noctalia.getConfig(key)
end

local function readServerName()
  local content = noctalia.readFile("~/.config/Happ.conf")
  if type(content) ~= "string" then
    return nil
  end
  for line in content:gmatch("[^\r\n]+") do
    local name = line:match("^lastServerName=(.*)$")
    if name and name ~= "" then
      return name
    end
  end
  return nil
end

local checking = false

local function check()
  if checking then
    return
  end
  checking = true

  local processMatch = cfg("process_match")
  if type(processMatch) ~= "string" or processMatch == "" then
    -- Not the binary's real path/casing: launched via the "happ" PATH symlink
    -- (/usr/bin/happ -> /opt/happ/bin/Happ), so the kernel keeps argv[0] as
    -- invoked and /proc/<pid>/cmdline reads "happ", never "/opt/happ/bin/Happ".
    processMatch = "happ"
  end

  noctalia.processMatches(function(running)
    if not running then
      noctalia.state.set("happ_status", { running = false, connected = false, server = nil })
      checking = false
      return
    end

    local port = cfg("socks_port")
    if type(port) ~= "number" or port <= 0 then
      port = 10808
    end

    -- No netcat dependency: bash's own /dev/tcp does the connect test.
    local probe = "timeout 1 bash -c 'exec 3<>/dev/tcp/127.0.0.1/" .. tostring(math.floor(port)) .. "' 2>/dev/null"
    noctalia.runAsync(probe, function(result)
      local connected = type(result) == "table" and result.exitCode == 0
      noctalia.state.set("happ_status", {
        running = true,
        connected = connected,
        server = connected and readServerName() or nil,
      })
      checking = false
    end)
  end, processMatch)
end

function update()
  check()
end

function onConfigChanged()
  noctalia.setUpdateInterval(tonumber(cfg("poll_interval_ms")) or 4000)
  check()
end

noctalia.setUpdateInterval(tonumber(cfg("poll_interval_ms")) or 4000)
check()
