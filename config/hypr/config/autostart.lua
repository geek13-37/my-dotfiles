-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("noctalia")
    -- password prompts for GUI apps that need root (Disks, Nautilus admin, ...)
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)
