-- Environment
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("XDG_SESSION_TYPE", "wayland")

-- Cursor
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "20")

-- NVIDIA (GTX 1650): only when the nvidia driver is loaded, so the same
-- config also works on Intel/AMD machines
local nvidia = io.open("/proc/driver/nvidia/version", "r")
if nvidia then
    nvidia:close()
    -- nvidia-vaapi-driver is not installed; a dangling LIBVA driver breaks video apps
    -- hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    hl.env("GBM_BACKEND", "nvidia-drm")
    -- shader cache: the driver's default 1 GB cap is too small for Dota 2,
    -- so it evicted shaders and Steam recompiled them on every launch
    hl.env("__GL_SHADER_DISK_CACHE_SIZE", "12000000000")
    hl.env("__GL_SHADER_DISK_CACHE_SKIP_CLEANUP", "1")
end
