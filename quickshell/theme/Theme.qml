pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Dynamic Material 3 colors (auto-synced with wallpaper via Matugen)
    property color primary: "#ffb598"
    property color primaryFg: "#552008"
    property color primaryContainer: "#71361c"
    property color primaryContainerFg: "#ffdbce"

    property color bg: "#1a110e"
    property color bgSurface: "#1a110e"
    property color bgElevated: "#271e1a"
    property color bgCard: "#231a16"
    property color bgPill: "#3d322f"

    property color text: "#f1dfd9"
    property color textMuted: "#d8c2ba"
    property color outline: "#a08d86"
    property color outlineMuted: "#53433e"

    property color active: "#a8c7fa"
    property color activeContainer: "#004a77"
    property color activeContainerFg: "#c2e7ff"
    property color urgent: "#ffb4ab"
    property color success: "#a8dab5"

    // Geometry & Radiuses (end-4 / Material Design 3)
    readonly property int radiusSm: 8
    readonly property int radiusMd: 14
    readonly property int radiusLg: 20
    readonly property int radiusXl: 26
    readonly property int radiusFull: 9999

    // Typography
    readonly property string font: "Lexend"
    readonly property string monoFont: "JetBrainsMono Nerd Font"

    // Material 3 Expressive Curves & Durations (end-4 style)
    readonly property var expressiveFastCurve: [0.42, 1.67, 0.21, 0.90, 1, 1]
    readonly property var expressiveDefaultCurve: [0.38, 1.21, 0.22, 1.00, 1, 1]
    readonly property var emphasizedDecelCurve: [0.05, 0.7, 0.1, 1, 1, 1]
    readonly property int animFast: 200
    readonly property int animNormal: 350
    readonly property int animSlow: 500

    function loadColors(raw) {
        try {
            if (!raw || raw.length === 0) return;
            const data = JSON.parse(raw);
            if (data.primary) root.primary = data.primary;
            if (data.primaryFg) root.primaryFg = data.primaryFg;
            if (data.primaryContainer) root.primaryContainer = data.primaryContainer;
            if (data.primaryContainerFg) root.primaryContainerFg = data.primaryContainerFg;
            if (data.surface) root.bgSurface = data.surface;
            if (data.surfaceContainer) root.bgElevated = data.surfaceContainer;
            if (data.surfaceContainerHighest) root.bgPill = data.surfaceContainerHighest;
            if (data.background) root.bg = data.background;
            if (data.onSurface) root.text = data.onSurface;
            if (data.onSurfaceVariant) root.textMuted = data.onSurfaceVariant;
            if (data.outline) root.outline = data.outline;
            if (data.outlineVariant) root.outlineMuted = data.outlineVariant;
            if (data.error) root.urgent = data.error;
        } catch (e) {
            console.log("Error loading colors: " + e);
        }
    }

    function forceReload() {
        colorView.reload();
        delayedColorRead.restart();
    }

    Timer {
        id: delayedColorRead
        interval: 150
        repeat: false
        running: false
        onTriggered: {
            root.loadColors(colorView.text());
        }
    }

    FileView {
        id: colorView
        path: Qt.resolvedUrl("colors.json")
        watchChanges: true
        onFileChanged: {
            this.reload();
            delayedColorRead.restart();
        }
        onLoadedChanged: {
            delayedColorRead.restart();
        }
    }
}
