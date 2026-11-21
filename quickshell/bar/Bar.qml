import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../theme"

PanelWindow {
    id: barWindow

    // Floating centered island bar (end-4 floating style)
    anchors {
        top: true
    }

    margins {
        top: 10
    }

    width: Math.round((barWindow.screen ? barWindow.screen.width : 2560) * GlobalConfig.barWidthRatio)
    implicitHeight: GlobalConfig.barHeight
    exclusiveZone: GlobalConfig.barHeight + 10
    color: "transparent"

    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.namespace: "quickshell:bar"

    // Background panel with dynamic Material 3 colors from wallpaper
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Theme.bgSurface.r, Theme.bgSurface.g, Theme.bgSurface.b, 0.92)
        radius: GlobalConfig.cornerRadius
        border.color: Theme.outlineMuted
        border.width: 1

        Item {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14

            // =============================================================
            // 1. LEFT SECTION: Launcher + Active Window Title
            // =============================================================
            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: centerWorkspaces.left
                anchors.rightMargin: 20
                spacing: 10

                // App Launcher
                Rectangle {
                    id: launcherBtn
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 38
                    radius: Theme.radiusSm
                    color: launcherMouse.containsMouse ? Theme.bgPill : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animFast
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Theme.expressiveFastCurve
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰣇"
                        font.family: Theme.monoFont
                        font.pixelSize: 22
                        color: Theme.primary
                    }

                    MouseArea {
                        id: launcherMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: launcherProc.running = true
                    }

                    Process {
                        id: launcherProc
                        command: ["rofi", "-show", "drun"]
                    }
                }

                // Active Window Title Pill
                Rectangle {
                    Layout.preferredHeight: 38
                    Layout.maximumWidth: 380
                    visible: GlobalConfig.showWindowTitles && Boolean(Hyprland.focusedWindow && Hyprland.focusedWindow.title && Hyprland.focusedWindow.title.length > 0)
                    color: Theme.bgPill
                    radius: Theme.radiusFull
                    implicitWidth: Math.min(titleRow.implicitWidth + 24, 380)

                    RowLayout {
                        id: titleRow
                        anchors.centerIn: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 8

                        Text {
                            text: "󰖲"
                            font.family: Theme.monoFont
                            font.pixelSize: 15
                            color: Theme.primary
                        }

                        Text {
                            text: (Hyprland.focusedWindow && Hyprland.focusedWindow.title) ? Hyprland.focusedWindow.title : ""
                            font.family: Theme.font
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: Theme.text
                            elide: Text.ElideRight
                            Layout.maximumWidth: 320
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }

            // =============================================================
            // 2. DEAD CENTER: Workspaces (Always Centered on Screen)
            // =============================================================
            Rectangle {
                id: centerWorkspaces
                anchors.centerIn: parent
                height: 40
                color: Theme.bgPill
                radius: Theme.radiusFull
                implicitWidth: wsRow.implicitWidth + 26

                Row {
                    id: wsRow
                    anchors.centerIn: parent
                    spacing: 8

                    Repeater {
                        model: 5

                        delegate: Rectangle {
                            id: wsPill
                            required property int index
                            readonly property int wsId: index + 1
                            readonly property var wsObj: Hyprland.workspaces.values.find(w => w.id === wsId)
                            readonly property bool isFocused: Hyprland.focusedWorkspace ? (Hyprland.focusedWorkspace.id === wsId) : false
                            readonly property bool hasWindows: wsObj !== undefined

                            height: 12
                            radius: 6

                            // Fluid end-4 style morphing width animation with bezier curve
                            width: isFocused ? 38 : (hasWindows ? 18 : 10)
                            Behavior on width {
                                NumberAnimation {
                                    duration: Theme.animNormal
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: Theme.expressiveDefaultCurve
                                }
                            }

                            color: isFocused ? Theme.primary : (hasWindows ? Theme.textMuted : Theme.outline)
                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.animFast
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: Theme.expressiveFastCurve
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -8
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Hyprland.dispatch("workspace " + wsId)
                            }
                        }
                    }
                }
            }

            // =============================================================
            // 3. RIGHT SECTION: Status Indicators + Clock & Date on Extreme Right
            // =============================================================
            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: centerWorkspaces.right
                anchors.leftMargin: 20
                spacing: 10

                Item { Layout.fillWidth: true }

                // Quick Status Cluster Pill
                Rectangle {
                    Layout.preferredHeight: 38
                    implicitWidth: rightPillLayout.implicitWidth + 24
                    color: Theme.bgPill
                    radius: Theme.radiusFull

                    RowLayout {
                        id: rightPillLayout
                        anchors.centerIn: parent
                        spacing: 14

                        // Audio
                        Text {
                            text: "󰕾"
                            font.family: Theme.monoFont
                            font.pixelSize: 16
                            color: Theme.primary
                        }

                        // Network
                        Text {
                            text: GlobalState.wifiEnabled ? "󰤨" : "󰤮"
                            font.family: Theme.monoFont
                            font.pixelSize: 16
                            color: GlobalState.wifiEnabled ? Theme.text : Theme.textMuted
                        }

                        // Bluetooth
                        Text {
                            text: GlobalState.btEnabled ? "󰂯" : "󰂲"
                            font.family: Theme.monoFont
                            font.pixelSize: 16
                            color: GlobalState.btEnabled ? Theme.text : Theme.textMuted
                        }

                        // Separator
                        Text {
                            text: "│"
                            font.pixelSize: 14
                            color: Theme.outline
                        }

                        // Notification Bell
                        Text {
                            text: GlobalState.dndActive ? "󰂛" : "󰂚"
                            font.family: Theme.monoFont
                            font.pixelSize: 16
                            color: GlobalState.dndActive ? Theme.urgent : Theme.textMuted
                        }
                    }
                }

                // Extreme Right: Date & Time Pill
                Rectangle {
                    Layout.preferredHeight: 38
                    implicitWidth: clockLayout.implicitWidth + 26
                    color: Theme.bgPill
                    radius: Theme.radiusFull

                    RowLayout {
                        id: clockLayout
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            font.family: Theme.monoFont
                            font.pixelSize: 16
                            text: "󱑂"
                            color: Theme.primary
                        }

                        Text {
                            id: clockTime
                            text: Qt.formatDateTime(clockTimer.currentTime, "hh:mm AP")
                            font.family: Theme.font
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: Theme.text
                        }

                        Rectangle {
                            visible: GlobalConfig.showClockDate
                            width: 4
                            height: 4
                            radius: 2
                            color: Theme.textMuted
                        }

                        Text {
                            id: clockDate
                            visible: GlobalConfig.showClockDate
                            text: Qt.formatDateTime(clockTimer.currentTime, "ddd, MMM d")
                            font.family: Theme.font
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: Theme.textMuted
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

                // Quick Settings / Control Center Trigger Button
                Rectangle {
                    id: ccTrigger
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 38
                    radius: Theme.radiusSm
                    color: (GlobalState.controlCenterOpen || ccMouse.containsMouse) ? Theme.primaryContainer : Theme.bgPill

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animFast
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Theme.expressiveFastCurve
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰒓"
                        font.family: Theme.monoFont
                        font.pixelSize: 20
                        color: (GlobalState.controlCenterOpen || ccMouse.containsMouse) ? Theme.primaryContainerFg : Theme.primary
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
}
