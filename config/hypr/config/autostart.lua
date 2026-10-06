-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("noctalia")
    -- password prompts for GUI apps that need root (Disks, Nautilus admin, ...)
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    -- OpenSnitch prompts (which app may connect where); the daemon is a system service
    hl.exec_cmd("opensnitch-ui")
    -- LocalSend's port may be left open if the session died while it ran (bin/localsend)
    hl.exec_cmd("sudo -n /usr/local/bin/localsend-port close")
end)
