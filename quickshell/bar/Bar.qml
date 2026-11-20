import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../theme"

PanelWindow {
    id: barWindow

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 8
        left: 12
        right: 12
    }

    implicitHeight: 38
    exclusiveZone: 46
    color: "transparent"

    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.namespace: "quickshell:bar"

    // Background panel with rounded island corners (Athena / Caelestia aesthetic)
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Theme.bgSurface.r, Theme.bgSurface.g, Theme.bgSurface.b, 0.85)
        radius: Theme.radiusMd
        border.color: Theme.outlineMuted
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 8

            // -------------------------------------------------------------
            // 1. LEFT: Launcher + Workspaces
            // -------------------------------------------------------------
            Rectangle {
                id: launcherBtn
                Layout.preferredWidth: 30
                Layout.preferredHeight: 26
                radius: Theme.radiusSm
                color: launcherMouse.containsMouse ? Theme.bgPill : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰣇"
                    font.family: Theme.monoFont
                    font.pixelSize: 15
                    color: Theme.primary
                }

                MouseArea {
                    id: launcherMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        launcherProc.running = true
                    }
                }

                Process {
                    id: launcherProc
                    command: ["rofi", "-show", "drun"]
                }
            }

            // Workspaces (Fluid morphing pills inspired by Athena & Caelestia)
            Rectangle {
                Layout.preferredHeight: 26
                Layout.alignment: Qt.AlignVCenter
                color: Theme.bgPill
                radius: Theme.radiusFull
                implicitWidth: wsRow.implicitWidth + 14

                Row {
                    id: wsRow
                    anchors.centerIn: parent
                    spacing: 6

                    Repeater {
                        model: 5

                        delegate: Rectangle {
                            id: wsPill
                            required property int index
                            readonly property int wsId: index + 1
                            readonly property var wsObj: Hyprland.workspaces.values.find(w => w.id === wsId)
                            readonly property bool isFocused: Hyprland.focusedWorkspace ? (Hyprland.focusedWorkspace.id === wsId) : false
                            readonly property bool hasWindows: wsObj !== undefined

                            height: 8
                            radius: 4

                            // Dynamic morphing width: focused workspace expands
                            width: isFocused ? 24 : (hasWindows ? 12 : 8)
                            Behavior on width {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }

                            color: isFocused ? Theme.primary : (hasWindows ? Theme.textMuted : Theme.outline)
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -4 // Larger click area
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Hyprland.dispatch("workspace " + wsId)
                            }
                        }
                    }
                }
            }

            // -------------------------------------------------------------
            // 2. CENTER: Focused Window Title
            // -------------------------------------------------------------
            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredHeight: 24
                Layout.maximumWidth: 360
                visible: (Hyprland.focusedWindow && Hyprland.focusedWindow.title) ? Hyprland.focusedWindow.title.length > 0 : false
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    width: Math.min(implicitWidth, 340)
                    text: (Hyprland.focusedWindow && Hyprland.focusedWindow.title) ? Hyprland.focusedWindow.title : ""
                    font.family: Theme.font
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: Theme.textMuted
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Item { Layout.fillWidth: true }

            // -------------------------------------------------------------
            // 3. RIGHT: Clock + Quick Toggles + Control Center Button
            // -------------------------------------------------------------
            // Clock Pill
            Rectangle {
                Layout.preferredHeight: 26
                implicitWidth: clockText.implicitWidth + 16
                color: Theme.bgPill
                radius: Theme.radiusFull

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        font.family: Theme.monoFont
                        font.pixelSize: 12
                        text: "󱑂"
                        color: Theme.primary
                    }

                    Text {
                        id: clockText
                        text: Qt.formatDateTime(clockTimer.currentTime, "hh:mm • ddd, MMM d")
                        font.family: Theme.font
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: Theme.text
                    }
                }

                Timer {
                    id: clockTimer
                    interval: 1000
                    running: true
                    repeat: true
                    property var currentTime: new Date()
                    onTriggered: currentTime = new Date()
                }
            }

            // Control Center Trigger Pill
            Rectangle {
                id: ccTrigger
                Layout.preferredWidth: 32
                Layout.preferredHeight: 26
                radius: Theme.radiusSm
                color: (GlobalState.controlCenterOpen || ccMouse.containsMouse) ? Theme.primaryContainer : Theme.bgPill

                Text {
                    anchors.centerIn: parent
                    text: "󰍜"
                    font.family: Theme.monoFont
                    font.pixelSize: 14
                    color: (GlobalState.controlCenterOpen || ccMouse.containsMouse) ? Theme.primaryContainerFg : Theme.text
                }

                MouseArea {
                    id: ccMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        GlobalState.controlCenterOpen = !GlobalState.controlCenterOpen
                    }
                }
            }
        }
    }
}

