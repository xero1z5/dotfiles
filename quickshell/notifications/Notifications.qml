import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "../theme"

Scope {
    id: notifScope

    // Native notification server (replaces Dunst)
    NotificationServer {
        id: server
        imageSupported: true
        bodyMarkupSupported: true
        actionsSupported: true
    }

    PanelWindow {
        id: notifWindow

        anchors {
            top: true
            right: true
        }

        margins {
            top: 52
            right: 14
        }

        exclusiveZone: 0
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.namespace: "quickshell:notifications"

        color: "transparent"
        implicitWidth: 320
        implicitHeight: notifColumn.implicitHeight

        ColumnLayout {
            id: notifColumn
            width: parent.width
            spacing: 10

            Repeater {
                model: server.trackedNotifications

                delegate: Rectangle {
                    id: toastCard
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: cardLayout.implicitHeight + 20
                    color: Qt.rgba(Theme.bgSurface.r, Theme.bgSurface.g, Theme.bgSurface.b, 0.95)
                    radius: Theme.radiusMd
                    border.color: Theme.outlineMuted
                    border.width: 1

                    // Auto dismiss after 6 seconds
                    Timer {
                        interval: 6000
                        running: true
                        repeat: false
                        onTriggered: modelData.dismiss()
                    }

                    ColumnLayout {
                        id: cardLayout
                        anchors {
                            fill: parent
                            margins: 12
                        }
                        spacing: 6

                        // Header: App name + Dismiss icon
                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: modelData.appName || "Notification"
                                font.family: Theme.font
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: Theme.primary
                                Layout.fillWidth: true
                            }

                            MouseArea {
                                implicitWidth: 20
                                implicitHeight: 20
                                cursorShape: Qt.PointingHandCursor
                                onClicked: modelData.dismiss()

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰅖"
                                    font.family: Theme.monoFont
                                    font.pixelSize: 12
                                    color: Theme.textMuted
                                }
                            }
                        }

                        // Summary
                        Text {
                            Layout.fillWidth: true
                            text: modelData.summary
                            font.family: Theme.font
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: Theme.text
                            wrapMode: Text.WordWrap
                            visible: text !== ""
                        }

                        // Body
                        Text {
                            Layout.fillWidth: true
                            text: modelData.body
                            font.family: Theme.font
                            font.pixelSize: 11
                            color: Theme.textMuted
                            wrapMode: Text.WordWrap
                            visible: text !== ""
                        }
                    }
                }
            }
        }
    }
}

