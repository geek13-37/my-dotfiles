import QtQuick
import Quickshell
import qs.services

// Brightness popup (laptops): opens when the backlight level changes.
Scope {
    Osd {
        id: osd
        icon: value < 0.34 ? "brightness_low" : value < 0.67 ? "brightness_medium" : "brightness_high"
        value: Brightness.value
        onRequested: v => Brightness.set(v)
    }

    Connections {
        target: Brightness
        function onValueChanged() { osd.show() }
    }
}
