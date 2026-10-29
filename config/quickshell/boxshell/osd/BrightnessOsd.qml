import QtQuick
import Quickshell
import qs.services

// Brightness popup (laptops): opens when the backlight level changes.
Scope {
    Osd {
        id: osd
        label: "brightness"
        value: Brightness.value
        onRequested: v => Brightness.set(v)
    }

    Connections {
        target: Brightness
        function onValueChanged() { osd.show() }
    }
}
