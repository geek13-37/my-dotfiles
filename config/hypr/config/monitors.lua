-- Monitors
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@75.002",
    position = "0x0",
    scale    = 1,
})

-- Any other monitor
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
