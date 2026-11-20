pragma Singleton
import QtQuick

QtObject {
    // Material 3 / Athena Dark Palette
    readonly property color bg: "#131316"
    readonly property color bgSurface: "#1b1b1f"
    readonly property color bgElevated: "#25242a"
    readonly property color bgPill: "#2d2c34"
    
    readonly property color primary: "#d0bcff"
    readonly property color primaryFg: "#381e72"
    readonly property color primaryContainer: "#4f378b"
    readonly property color primaryContainerFg: "#eaddff"
    
    readonly property color text: "#e6e0e9"
    readonly property color textMuted: "#938f99"
    readonly property color outline: "#49454f"
    readonly property color outlineMuted: "#36343b"
    
    readonly property color active: "#a8c7fa"
    readonly property color urgent: "#f2b8b5"
    readonly property color success: "#a8dab5"

    // Geometry & Fonts
    readonly property int radiusSm: 8
    readonly property int radiusMd: 14
    readonly property int radiusLg: 20
    readonly property int radiusFull: 9999

    readonly property string font: "Lexend"
    readonly property string monoFont: "JetBrainsMono Nerd Font"
}

