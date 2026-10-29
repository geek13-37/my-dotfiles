pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Laptop battery from UPower; `present` is false on a desktop and the bar
// leaves it out. Sends a notification at 15% and a critical one at 5%.
Singleton {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property bool present: device?.isLaptopBattery ?? false
    // UPower reports 0-100, newer Quickshell 0-1
    readonly property real level: !device ? 0 : device.percentage > 1 ? device.percentage / 100 : device.percentage
    readonly property bool charging: device?.state === UPowerDeviceState.Charging
                                     || device?.state === UPowerDeviceState.PendingCharge
    readonly property bool full: device?.state === UPowerDeviceState.FullyCharged
    readonly property bool low: present && !charging && !full && level <= 0.15

    readonly property string icon: charging || full ? "battery_charging_full"
                                 : level >= 0.95 ? "battery_full"
                                 : `battery_${Math.min(6, Math.floor(level * 7))}_bar`

    // "2h 15m left", "full in 40m", "" when UPower doesn't know yet
    readonly property string timeText: {
        const seconds = charging ? device?.timeToFull : device?.timeToEmpty
        if (!seconds || full) return ""
        const h = Math.floor(seconds / 3600)
        const m = Math.round((seconds % 3600) / 60)
        const t = h > 0 ? `${h}h ${m}m` : `${m}m`
        return charging ? `full in ${t}` : `${t} left`
    }

    // lowest threshold already warned about, reset when plugged in
    property real warned: 1

    onLevelChanged: {
        if (!present || charging || full) return
        if (level <= 0.05 && warned > 0.05) {
            warned = 0.05
            Quickshell.execDetached(["notify-send", "-a", "Battery", "-u", "critical", "-i", "battery-caution",
                                     "Battery critical", `${Math.round(level * 100)}% left, plug in now`])
        } else if (level <= 0.15 && warned > 0.15) {
            warned = 0.15
            Quickshell.execDetached(["notify-send", "-a", "Battery", "-i", "battery-low",
                                     "Battery low", `${Math.round(level * 100)}% left`])
        }
    }
    onChargingChanged: if (charging) warned = 1
}
