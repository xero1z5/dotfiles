import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../theme"

PanelWindow {
    id: dockWindow

    anchors {
        bottom: true
    }

    margins {
        bottom: 10
    }

    implicitHeight: 52
    implicitWidth: dockLayout.implicitWidth + 24
    exclusiveZone: 58
    color: "transparent"

    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.namespace: "quickshell:dock"

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Theme.bgSurface.r, Theme.bgSurface.g, Theme.bgSurface.b, 0.85)
        radius: Theme.radiusFull
        border.color: Theme.outlineMuted
        border.width: 1

        RowLayout {
            id: dockLayout
            anchors.centerIn: parent
            spacing: 10

            // Pinned apps array
            readonly property var apps: [
                { name: "Terminal", icon: "󰞷", cmd: "kitty", wmClass: "kitty" },
                { name: "Browser",  icon: "󰈹", cmd: "zen-browser", wmClass: "zen" },
                { name: "Files",    icon: "󰉋", cmd: "dolphin", wmClass: "dolphin" },
                { name: "Editor",   icon: "󰅩", cmd: "kitty -e nvim", wmClass: "nvim" },
                { name: "Music",    icon: "󰓇", cmd: "spotify", wmClass: "spotify" },
                { name: "Theme",    icon: "󰸉", cmd: "waypaper", wmClass: "waypaper" }
            ]

            Repeater {
                model: dockLayout.apps

                delegate: Item {
                    id: dockItem
                    required property var modelData
                    
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40

                    // Check if an instance of this app is open in Hyprland
                    readonly property bool isRunning: {
                        let query = modelData.wmClass.toLowerCase();
                        for (let win of Hyprland.toplevels.values) {
                            let cls = (win.class || "").toLowerCase();
                            let title = (win.initialTitle || "").toLowerCase();
                            if (cls.includes(query) || title.includes(query)) return true;
                        }
                        return false;
                    }

                    Rectangle {
                        id: iconContainer
                        anchors.centerIn: parent
                        width: 36
                        height: 36
                        radius: Theme.radiusSm
                        color: itemMouse.containsMouse ? Theme.bgPill : "transparent"

                        // Fluid scale bounce on hover
                        scale: itemMouse.containsMouse ? 1.15 : 1.0
                        Behavior on scale {
                            NumberAnimation { duration: 180; easing.type: Easing.OutBack }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.family: Theme.monoFont
                            font.pixelSize: 18
                            color: itemMouse.containsMouse ? Theme.primary : Theme.text
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                appLauncher.running = true
                            }
                        }

                        Process {
                            id: appLauncher
                            command: ["sh", "-c", modelData.cmd]
                        }
                    }

                    // Dot indicator for running apps
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 4
                        height: 4
                        radius: 2
                        color: isRunning ? Theme.primary : "transparent"
                        visible: isRunning
                    }
                }
            }
        }
    }
}

