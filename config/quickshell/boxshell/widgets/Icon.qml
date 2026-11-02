import QtQuick
import qs

// An icon by its Material Symbols name (e.g. "volume_up"), drawn with
// Phosphor (assets/phosphor, MIT). The table maps the names the shell uses
// to Phosphor glyphs; an unknown name draws nothing and logs a warning.
Item {
    id: root

    property string text
    property color color: Theme.fg
    property alias font: glyph.font
    property bool bold: true

    implicitWidth: glyph.implicitWidth
    implicitHeight: glyph.implicitHeight

    readonly property var glyphs: ({
        "apps": "\ue464",
        "article": "\ue0a8",
        "balance": "\ue750",
        "balanced": "\ue750",
        "battery_0_bar": "\ue0be",
        "battery_1_bar": "\ue0c4",
        "battery_2_bar": "\ue0c4",
        "battery_3_bar": "\ue0c6",
        "battery_4_bar": "\ue0c6",
        "battery_5_bar": "\ue0c2",
        "battery_6_bar": "\ue0c2",
        "battery_charging_full": "\ue0ba",
        "battery_full": "\ue0c0",
        "bedtime": "\ue330",
        "brightness_6": "\ue472",
        "brightness_high": "\ue472",
        "brightness_low": "\ue474",
        "brightness_medium": "\ue5b6",
        "camera": "\ue10e",
        "check": "\ue182",
        "chevron_right": "\ue13a",
        "delete": "\ue4a6",
        "delete_sweep": "\uec54",
        "deployed_code": "\ue1da",
        "devices": "\ueba4",
        "energy_savings_leaf": "\ue2da",
        "error": "\ue4e2",
        "ethernet": "\uedde",
        "expand_more": "\ue136",
        "headphones": "\ue2a6",
        "headset_mic": "\ue584",
        "info": "\ue2ce",
        "keyboard": "\ue2d8",
        "keyboard_arrow_down": "\ue136",
        "keyboard_capslock": "\ue522",
        "lan": "\uedde",
        "logout": "\ue42a",
        "memory": "\ue9c4",
        "mic": "\ue326",
        "mic_off": "\ue328",
        "northwest": "\ue090",
        "open_in_new": "\ue5de",
        "performance": "\ue2de",
        "play_arrow": "\ue3d0",
        "power_settings_new": "\ue3da",
        "poweroff": "\ue3da",
        "reboot": "\ue036",
        "restart": "\ue036",
        "restart_alt": "\ue036",
        "saver": "\ue2da",
        "screen_share": "\ue404",
        "speaker": "\uea08",
        "speed": "\ue628",
        "stop": "\ue46c",
        "suspend": "\ue330",
        "terminal": "\ueae8",
        "tune": "\ue434",
        "tv": "\ue754",
        "videocam": "\ue4da",
        "volume_down": "\ue44c",
        "volume_off": "\ue45c",
        "volume_up": "\ue44a",
        "wifi": "\ue4ea",
        "wifi_off": "\ue4f2"
    })

    Text {
        id: glyph
        anchors.centerIn: parent
        text: root.glyphs[root.text] ?? ""
        color: root.color
        font.family: root.bold ? Theme.iconFontBold : Theme.iconFont
        font.pixelSize: Theme.iconSize
        renderType: Text.NativeRendering
    }

    onTextChanged: if (text !== "" && glyphs[text] === undefined) console.warn(`Icon: no glyph for "${text}"`)
}
