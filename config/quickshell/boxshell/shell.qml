//@ pragma UseQApplication
// boxshell: a square Quickshell desktop shell.
// Run: qs -c boxshell
import QtQuick
import Quickshell
import qs.bar
import qs.notifications
import qs.osd
import qs.services
import qs.wallpaper

ShellRoot {
    // one wallpaper and one bar per monitor
    Variants {
        model: Quickshell.screens
        Wallpaper {}
    }
    Variants {
        model: Quickshell.screens
        Bar {}
    }

    VolumeOsd {}
    BrightnessOsd {}
    Notifications {}

    // touch the singletons so they start (rofi and Hyprland colours, picker IPC)
    Component.onCompleted: {
        Rofi.text
        HyprColors.lua
        WallpaperPicker.open
    }
}
