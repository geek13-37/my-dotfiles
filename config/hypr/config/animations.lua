-- Animations (spring-like curves, converted from damping-ratio/stiffness)
-- (dampening = 2 * damping_ratio * sqrt(stiffness * mass), mass = 1)

hl.config({ animations = { enabled = true } })

hl.curve("ws",     { type = "spring", mass = 1, stiffness = 900,  dampening = 54 })   -- workspace-switch
hl.curve("open",   { type = "spring", mass = 1, stiffness = 500,  dampening = 42.5 }) -- window-open/close
hl.curve("move",   { type = "spring", mass = 1, stiffness = 1300, dampening = 72.1 }) -- window-movement/resize
hl.curve("easeOutCubic", { type = "bezier", points = { {0.33, 1}, {0.68, 1} } })

hl.animation({ leaf = "global",     enabled = true, speed = 4, bezier = "easeOutCubic" })
hl.animation({ leaf = "windows",    enabled = true, speed = 4, spring = "move" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4, spring = "open", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, spring = "open", style = "popin 90%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, spring = "ws",   style = "fade" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, spring = "ws", style = "slidevert" })
hl.animation({ leaf = "layers",     enabled = true, speed = 3, bezier = "easeOutCubic", style = "fade" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3, bezier = "easeOutCubic" })
