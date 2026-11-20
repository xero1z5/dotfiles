import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"

PanelWindow {
    id: ccWindow

    anchors {
        top: true
        right: true
    }

    margins {
        top: 52
        right: 14
    }

    implicitWidth: 340
    implicitHeight: 390
    exclusiveZone: 0
    visible: GlobalState.controlCenterOpen
    color: "transparent"

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "quickshell:controlcenter"

    // Card background with Athena / Material 3 styling
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Theme.bgSurface.r, Theme.bgSurface.g, Theme.bgSurface.b, 0.94)
        radius: Theme.radiusLg
        border.color: Theme.outlineMuted
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            // -------------------------------------------------------------
            // 1. HEADER: User info + Close button
            // -------------------------------------------------------------
            RowLayout {
                Layout.fillWidth: true

                Rectangle {
                    width: 32
                    height: 32
                    radius: Theme.radiusFull
                    color: Theme.primaryContainer

                    Text {
                        anchors.centerIn: parent
                        text: "󰄛"
                        font.family: Theme.monoFont
                        font.pixelSize: 16
                        color: Theme.primaryContainerFg
                    }
                }

                ColumnLayout {
                    spacing: 1
                    Text {
                        text: "Control Center"
                        font.family: Theme.font
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: Theme.text
                    }
                    Text {
                        text: "Athena • Quickshell"
                        font.family: Theme.font
                        font.pixelSize: 10
                        color: Theme.textMuted
                    }
                }

                Item { Layout.fillWidth: true }

                // Close button
                Rectangle {
                    width: 26
                    height: 26
                    radius: Theme.radiusSm
                    color: closeMouse.containsMouse ? Theme.bgPill : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        font.family: Theme.monoFont
                        font.pixelSize: 14
                        color: Theme.textMuted
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: GlobalState.controlCenterOpen = false
                    }
                }
            }

            // -------------------------------------------------------------
            // 2. QUICK TOGGLES (Wi-Fi, Bluetooth, DND, Night Light)
            // -------------------------------------------------------------
            GridLayout {
                columns: 2
                Layout.fillWidth: true
                rowSpacing: 8
                columnSpacing: 8

                // Wi-Fi Button
                Rectangle {
                    id: wifiTile
                    property bool enabled: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    radius: Theme.radiusMd
                    color: enabled ? Theme.primaryContainer : Theme.bgElevated

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        Text {
                            text: wifiTile.enabled ? "󰤨" : "󰤭"
                            font.family: Theme.monoFont
                            font.pixelSize: 16
                            color: wifiTile.enabled ? Theme.primaryContainerFg : Theme.textMuted
                        }
                        ColumnLayout {
                            spacing: 0
                            Text {
                                text: "Wi-Fi"
                                font.family: Theme.font
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: wifiTile.enabled ? Theme.primaryContainerFg : Theme.text
                            }
                            Text {
                                text: wifiTile.enabled ? "Connected" : "Off"
                                font.family: Theme.font
                                font.pixelSize: 9
                                color: wifiTile.enabled ? Theme.primaryContainerFg : Theme.textMuted
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            wifiTile.enabled = !wifiTile.enabled
                            wifiProc.running = true
                        }
                    }

                    Process {
                        id: wifiProc
                        command: ["nmcli", "radio", "wifi", wifiTile.enabled ? "on" : "off"]
                    }
                }

                // Bluetooth Button
                Rectangle {
                    id: btTile
                    property bool enabled: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    radius: Theme.radiusMd
                    color: enabled ? Theme.primaryContainer : Theme.bgElevated

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        Text {
                            text: btTile.enabled ? "󰂯" : "󰂲"
                            font.family: Theme.monoFont
                            font.pixelSize: 16
                            color: btTile.enabled ? Theme.primaryContainerFg : Theme.textMuted
                        }
                        ColumnLayout {
                            spacing: 0
                            Text {
                                text: "Bluetooth"
                                font.family: Theme.font
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: btTile.enabled ? Theme.primaryContainerFg : Theme.text
                            }
                            Text {
                                text: btTile.enabled ? "Active" : "Off"
                                font.family: Theme.font
                                font.pixelSize: 9
                                color: btTile.enabled ? Theme.primaryContainerFg : Theme.textMuted
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            btTile.enabled = !btTile.enabled
                            btProc.running = true
                        }
                    }

                    Process {
                        id: btProc
                        command: ["bluetoothctl", "power", btTile.enabled ? "on" : "off"]
                    }
                }
            }

            // -------------------------------------------------------------
            // 3. SLIDERS: Volume & Brightness
            // -------------------------------------------------------------
            // Volume Slider
            Rectangle {
                id: volContainer
                property real value: 0.65 // 0.0 - 1.0
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: Theme.radiusFull
                color: Theme.bgElevated
                clip: true

                // Filled portion
                Rectangle {
                    width: parent.width * volContainer.value
                    height: parent.height
                    color: Theme.primary
                    radius: Theme.radiusFull
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14

                    Text {
                        text: "󰕾"
                        font.family: Theme.monoFont
                        font.pixelSize: 14
                        color: volContainer.value > 0.15 ? Theme.primaryFg : Theme.text
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: Math.round(volContainer.value * 100) + "%"
                        font.family: Theme.font
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: volContainer.value > 0.85 ? Theme.primaryFg : Theme.text
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: mouse => updateVolume(mouse.x)
                    onClicked: mouse => updateVolume(mouse.x)

                    function updateVolume(mouseX) {
                        let pct = Math.max(0.0, Math.min(1.0, mouseX / volContainer.width));
                        volContainer.value = pct;
                        volProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", Math.round(pct * 100) + "%"];
                        volProc.running = true;
                    }
                }

                Process { id: volProc }
            }

            // Brightness Slider
            Rectangle {
                id: brightContainer
                property real value: 0.75 // 0.0 - 1.0
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: Theme.radiusFull
                color: Theme.bgElevated
                clip: true

                Rectangle {
                    width: parent.width * brightContainer.value
                    height: parent.height
                    color: Theme.primary
                    radius: Theme.radiusFull
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14

                    Text {
                        text: "󰃠"
                        font.family: Theme.monoFont
                        font.pixelSize: 14
                        color: brightContainer.value > 0.15 ? Theme.primaryFg : Theme.text
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: Math.round(brightContainer.value * 100) + "%"
                        font.family: Theme.font
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: brightContainer.value > 0.85 ? Theme.primaryFg : Theme.text
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: mouse => updateBrightness(mouse.x)
                    onClicked: mouse => updateBrightness(mouse.x)

                    function updateBrightness(mouseX) {
                        let pct = Math.max(0.05, Math.min(1.0, mouseX / brightContainer.width));
                        brightContainer.value = pct;
                        brightProc.command = ["brightnessctl", "set", Math.round(pct * 100) + "%"];
                        brightProc.running = true;
                    }
                }

                Process { id: brightProc }
            }

            Item { Layout.fillHeight: true }

            // -------------------------------------------------------------
            // 4. FOOTER: Session & Power Actions (Replaces wlogout)
            // -------------------------------------------------------------
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Lock
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: Theme.radiusSm
                    color: lockMouse.containsMouse ? Theme.bgPill : Theme.bgElevated

                    Text {
                        anchors.centerIn: parent
                        text: "󰌾"
                        font.family: Theme.monoFont
                        font.pixelSize: 14
                        color: Theme.text
                    }

                    MouseArea {
                        id: lockMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            GlobalState.controlCenterOpen = false
                            lockProc.running = true
                        }
                    }
                    Process { id: lockProc; command: ["hyprlock"] }
                }

                // Suspend
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: Theme.radiusSm
                    color: suspMouse.containsMouse ? Theme.bgPill : Theme.bgElevated

                    Text {
                        anchors.centerIn: parent
                        text: "󰤄"
                        font.family: Theme.monoFont
                        font.pixelSize: 14
                        color: Theme.text
                    }

                    MouseArea {
                        id: suspMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            GlobalState.controlCenterOpen = false
                            suspProc.running = true
                        }
                    }
                    Process { id: suspProc; command: ["systemctl", "suspend"] }
                }

                // Logout
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: Theme.radiusSm
                    color: logoutMouse.containsMouse ? Theme.bgPill : Theme.bgElevated

                    Text {
                        anchors.centerIn: parent
                        text: "󰍃"
                        font.family: Theme.monoFont
                        font.pixelSize: 14
                        color: Theme.text
                    }

                    MouseArea {
                        id: logoutMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            GlobalState.controlCenterOpen = false
                            logoutProc.running = true
                        }
                    }
                    Process { id: logoutProc; command: ["hyprctl", "dispatch", "exit"] }
                }

                // Shutdown
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: Theme.radiusSm
                    color: powerMouse.containsMouse ? Theme.urgent : Theme.bgElevated

                    Text {
                        anchors.centerIn: parent
                        text: "󰐥"
                        font.family: Theme.monoFont
                        font.pixelSize: 14
                        color: powerMouse.containsMouse ? Theme.bg : Theme.urgent
                    }

                    MouseArea {
                        id: powerMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            GlobalState.controlCenterOpen = false
                            powerProc.running = true
                        }
                    }
                    Process { id: powerProc; command: ["systemctl", "poweroff"] }
                }
            }
        }
    }
}

