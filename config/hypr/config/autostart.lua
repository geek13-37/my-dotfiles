-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("noctalia")
    -- keep the clipboard after the app it was copied from closes
    hl.exec_cmd("wl-clip-persist --clipboard regular")
    -- password prompts for GUI apps that need root (Disks, Nautilus admin, ...)
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    -- LocalSend's port may be left open if the session died while it ran (bin/localsend)
    hl.exec_cmd("sudo -n /usr/local/bin/localsend-port close")
end)
