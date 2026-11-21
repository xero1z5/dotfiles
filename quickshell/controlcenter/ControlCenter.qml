import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
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
        top: 72
        right: 24
    }

    implicitWidth: 480
    implicitHeight: 750
    exclusiveZone: 0
    visible: GlobalState.controlCenterOpen
    color: "transparent"

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "quickshell:controlcenter"

    property string currentView: "main" // "main" | "wifi" | "bluetooth" | "wallpapers" | "settings"
    property string selectedWifiSsid: ""
    property var wifiNetworks: []
    property var btDevices: []
    property string statusNotice: ""

    // Background card (Dynamic Material 3 theme from wallpaper)
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Theme.bgSurface.r, Theme.bgSurface.g, Theme.bgSurface.b, 0.96)
        radius: Theme.radiusXl
        border.color: Theme.outlineMuted
        border.width: 1
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 16

            // =============================================================
            // 1. TOP HEADER: Navigation & Actions
            // =============================================================
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Back button when inside sub-views
                Rectangle {
                    visible: ccWindow.currentView !== "main"
                    width: 38
                    height: 38
                    radius: Theme.radiusSm
                    color: backMouse.containsMouse ? Theme.bgPill : Theme.bgElevated

                    Behavior on color {
                        ColorAnimation { duration: Theme.animFast; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.expressiveFastCurve }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰁍"
                        font.family: Theme.monoFont
                        font.pixelSize: 20
                        color: Theme.primary
                    }

                    MouseArea {
                        id: backMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ccWindow.currentView = "main"
                    }
                }

                // Header Profile Icon (Main view)
                Rectangle {
                    visible: ccWindow.currentView === "main"
                    width: 42
                    height: 42
                    radius: Theme.radiusFull
                    color: Theme.primaryContainer

                    Text {
                        anchors.centerIn: parent
                        text: "󰄛"
                        font.family: Theme.monoFont
                        font.pixelSize: 20
                        color: Theme.primaryContainerFg
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: ccWindow.currentView === "main" ? "Quick Settings" :
                              ccWindow.currentView === "wifi" ? "Wi-Fi Networks" :
                              ccWindow.currentView === "bluetooth" ? "Bluetooth Devices" :
                              ccWindow.currentView === "wallpapers" ? "Wallpaper Gallery" : "Shell Customization"
                        font.family: Theme.font
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.text
                    }
                    Text {
                        text: ccWindow.currentView === "main" ? "System Control Panel" :
                              ccWindow.currentView === "wallpapers" ? "Click thumbnail to apply & sync palette" :
                              ccWindow.statusNotice.length > 0 ? ccWindow.statusNotice : "Select a device or network to connect"
                        font.family: Theme.font
                        font.pixelSize: 12
                        color: Theme.textMuted
                        elide: Text.ElideRight
                        Layout.maximumWidth: 280
                    }
                }

                Item { Layout.fillWidth: true }

                // Settings Gear Button
                Rectangle {
                    visible: ccWindow.currentView === "main"
                    width: 36
                    height: 36
                    radius: Theme.radiusSm
                    color: (ccWindow.currentView === "settings" || settingsMouse.containsMouse) ? Theme.primaryContainer : Theme.bgElevated

                    Text {
                        anchors.centerIn: parent
                        text: "󰒓"
                        font.family: Theme.monoFont
                        font.pixelSize: 18
                        color: (ccWindow.currentView === "settings" || settingsMouse.containsMouse) ? Theme.primaryContainerFg : Theme.text
                    }

                    MouseArea {
                        id: settingsMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ccWindow.currentView = "settings"
                    }
                }

                // Close Button
                Rectangle {
                    width: 36
                    height: 36
                    radius: Theme.radiusSm
                    color: closeMouse.containsMouse ? Theme.bgPill : Theme.bgElevated

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        font.family: Theme.monoFont
                        font.pixelSize: 17
                        color: Theme.textMuted
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            GlobalState.controlCenterOpen = false
                            ccWindow.currentView = "main"
                        }
                    }
                }
            }

            // =============================================================
            // 2. VIEW: MAIN CONTROL CENTER
            // =============================================================
            ColumnLayout {
                visible: ccWindow.currentView === "main"
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                // --- SLIDERS: Volume, Mic & Brightness (end-4 QuickSliders) ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    // Volume
                    Rectangle {
                        id: volSlider
                        property real value: 0.65
                        Layout.fillWidth: true
                        Layout.preferredHeight: 46
                        radius: Theme.radiusFull
                        color: Theme.bgElevated
                        clip: true

                        Rectangle {
                            width: parent.width * volSlider.value
                            height: parent.height
                            color: Theme.primary
                            radius: Theme.radiusFull

                            Behavior on width {
                                NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16

                            Text {
                                text: "󰕾"
                                font.family: Theme.monoFont
                                font.pixelSize: 18
                                color: volSlider.value > 0.15 ? Theme.primaryFg : Theme.text
                            }
                            Text {
                                text: "Volume"
                                font.family: Theme.font
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: volSlider.value > 0.35 ? Theme.primaryFg : Theme.text
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: Math.round(volSlider.value * 100) + "%"
                                font.family: Theme.font
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: volSlider.value > 0.85 ? Theme.primaryFg : Theme.text
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPositionChanged: mouse => updateVol(mouse.x)
                            onClicked: mouse => updateVol(mouse.x)

                            function updateVol(mouseX) {
                                let pct = Math.max(0.0, Math.min(1.0, mouseX / volSlider.width));
                                volSlider.value = pct;
                                volProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", Math.round(pct * 100) + "%"];
                                volProc.running = true;
                            }
                        }
                        Process { id: volProc }
                    }

                    // Microphone
                    Rectangle {
                        id: micSlider
                        property real value: 0.80
                        Layout.fillWidth: true
                        Layout.preferredHeight: 46
                        radius: Theme.radiusFull
                        color: Theme.bgElevated
                        clip: true

                        Rectangle {
                            width: parent.width * micSlider.value
                            height: parent.height
                            color: Theme.primary
                            radius: Theme.radiusFull

                            Behavior on width {
                                NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16

                            Text {
                                text: "󰍬"
                                font.family: Theme.monoFont
                                font.pixelSize: 18
                                color: micSlider.value > 0.15 ? Theme.primaryFg : Theme.text
                            }
                            Text {
                                text: "Mic"
                                font.family: Theme.font
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: micSlider.value > 0.35 ? Theme.primaryFg : Theme.text
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: Math.round(micSlider.value * 100) + "%"
                                font.family: Theme.font
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: micSlider.value > 0.85 ? Theme.primaryFg : Theme.text
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPositionChanged: mouse => updateMic(mouse.x)
                            onClicked: mouse => updateMic(mouse.x)

                            function updateMic(mouseX) {
                                let pct = Math.max(0.0, Math.min(1.0, mouseX / micSlider.width));
                                micSlider.value = pct;
                                micProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", Math.round(pct * 100) + "%"];
                                micProc.running = true;
                            }
                        }
                        Process { id: micProc }
                    }

                    // Brightness
                    Rectangle {
                        id: brightSlider
                        property real value: 0.65
                        Layout.fillWidth: true
                        Layout.preferredHeight: 46
                        radius: Theme.radiusFull
                        color: Theme.bgElevated
                        clip: true

                        Rectangle {
                            width: parent.width * brightSlider.value
                            height: parent.height
                            color: Theme.primary
                            radius: Theme.radiusFull

                            Behavior on width {
                                NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16

                            Text {
                                text: "󰃠"
                                font.family: Theme.monoFont
                                font.pixelSize: 18
                                color: brightSlider.value > 0.15 ? Theme.primaryFg : Theme.text
                            }
                            Text {
                                text: "Brightness"
                                font.family: Theme.font
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: brightSlider.value > 0.35 ? Theme.primaryFg : Theme.text
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: Math.round(brightSlider.value * 100) + "%"
                                font.family: Theme.font
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: brightSlider.value > 0.85 ? Theme.primaryFg : Theme.text
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPositionChanged: mouse => updateBright(mouse.x)
                            onClicked: mouse => updateBright(mouse.x)

                            function updateBright(mouseX) {
                                let pct = Math.max(0.05, Math.min(1.0, mouseX / brightSlider.width));
                                brightSlider.value = pct;
                                brightProc.command = ["brightnessctl", "set", Math.round(pct * 100) + "%"];
                                brightProc.running = true;
                            }
                        }
                        Process { id: brightProc }
                    }
                }

                // --- 8 QUICK TOGGLES (end-4 / Android style with dedicated toggle + menu) ---
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    rowSpacing: 10
                    columnSpacing: 10

                    // 1. WI-FI TILE
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 64
                        radius: Theme.radiusMd
                        color: GlobalState.wifiEnabled ? Theme.primaryContainer : Theme.bgElevated

                        Behavior on color {
                            ColorAnimation { duration: Theme.animFast; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.expressiveFastCurve }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            // Dedicated Toggle Icon Button (left)
                            Rectangle {
                                width: 44
                                height: 44
                                radius: Theme.radiusFull
                                color: wifiIconMouse.containsMouse ? Theme.bgPill : (GlobalState.wifiEnabled ? Theme.primary : Theme.bgCard)

                                Text {
                                    anchors.centerIn: parent
                                    text: GlobalState.wifiEnabled ? "󰤨" : "󰤮"
                                    font.family: Theme.monoFont
                                    font.pixelSize: 22
                                    color: GlobalState.wifiEnabled ? Theme.primaryFg : Theme.textMuted
                                }

                                MouseArea {
                                    id: wifiIconMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        GlobalState.wifiEnabled = !GlobalState.wifiEnabled
                                        wifiToggleProc.command = ["nmcli", "radio", "wifi", GlobalState.wifiEnabled ? "on" : "off"]
                                        wifiToggleProc.running = true
                                    }
                                }
                            }

                            // Body: Clicking opens Network Connection Sheet
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: "Wi-Fi"
                                    font.family: Theme.font
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    color: GlobalState.wifiEnabled ? Theme.primaryContainerFg : Theme.text
                                }
                                Text {
                                    text: GlobalState.wifiEnabled ? (GlobalState.activeSsid.length > 0 ? GlobalState.activeSsid : "Connected") : "Disabled"
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    color: GlobalState.wifiEnabled ? Theme.primaryContainerFg : Theme.textMuted
                                    elide: Text.ElideRight
                                    Layout.maximumWidth: 100
                                }
                            }

                            Text {
                                text: "󰅂"
                                font.family: Theme.monoFont
                                font.pixelSize: 16
                                color: GlobalState.wifiEnabled ? Theme.primaryContainerFg : Theme.textMuted
                            }
                        }

                        // Clicking anywhere outside the left toggle icon opens the connection sheet
                        MouseArea {
                            anchors.fill: parent
                            anchors.leftMargin: 56
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                ccWindow.currentView = "wifi"
                                wifiScanProc.running = true
                            }
                        }

                        Process { id: wifiToggleProc }
                    }

                    // 2. BLUETOOTH TILE
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 64
                        radius: Theme.radiusMd
                        color: GlobalState.btEnabled ? Theme.primaryContainer : Theme.bgElevated

                        Behavior on color {
                            ColorAnimation { duration: Theme.animFast; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.expressiveFastCurve }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            // Dedicated Toggle Icon Button (left)
                            Rectangle {
                                width: 44
                                height: 44
                                radius: Theme.radiusFull
                                color: btIconMouse.containsMouse ? Theme.bgPill : (GlobalState.btEnabled ? Theme.primary : Theme.bgCard)

                                Text {
                                    anchors.centerIn: parent
                                    text: GlobalState.btEnabled ? "󰂯" : "󰂲"
                                    font.family: Theme.monoFont
                                    font.pixelSize: 22
                                    color: GlobalState.btEnabled ? Theme.primaryFg : Theme.textMuted
                                }

                                MouseArea {
                                    id: btIconMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        GlobalState.btEnabled = !GlobalState.btEnabled
                                        btToggleProc.command = ["bluetoothctl", "power", GlobalState.btEnabled ? "on" : "off"]
                                        btToggleProc.running = true
                                    }
                                }
                            }

                            // Body: Clicking opens Bluetooth Devices Sheet
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: "Bluetooth"
                                    font.family: Theme.font
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    color: GlobalState.btEnabled ? Theme.primaryContainerFg : Theme.text
                                }
                                Text {
                                    text: GlobalState.btEnabled ? (GlobalState.activeBtDevice.length > 0 ? GlobalState.activeBtDevice : "Enabled") : "Disabled"
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    color: GlobalState.btEnabled ? Theme.primaryContainerFg : Theme.textMuted
                                    elide: Text.ElideRight
                                    Layout.maximumWidth: 100
                                }
                            }

                            Text {
                                text: "󰅂"
                                font.family: Theme.monoFont
                                font.pixelSize: 16
                                color: GlobalState.btEnabled ? Theme.primaryContainerFg : Theme.textMuted
                            }
                        }

                        // Clicking anywhere outside the left toggle icon opens the bluetooth sheet
                        MouseArea {
                            anchors.fill: parent
                            anchors.leftMargin: 56
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                ccWindow.currentView = "bluetooth"
                                btScanProc.running = true
                            }
                        }

                        Process { id: btToggleProc }
                    }

                    // 3. WALLPAPERS (Visual Gallery)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 64
                        radius: Theme.radiusMd
                        color: wallCardMouse.containsMouse ? Theme.bgPill : Theme.bgElevated

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                width: 40
                                height: 40
                                radius: Theme.radiusFull
                                color: Theme.bgCard
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰸉"
                                    font.family: Theme.monoFont
                                    font.pixelSize: 22
                                    color: Theme.primary
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: "Wallpapers"
                                    font.family: Theme.font
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    color: Theme.text
                                }
                                Text {
                                    text: "Visual Selector"
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    color: Theme.textMuted
                                }
                            }

                            Text {
                                text: "󰅂"
                                font.family: Theme.monoFont
                                font.pixelSize: 16
                                color: Theme.textMuted
                            }
                        }

                        MouseArea {
                            id: wallCardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ccWindow.currentView = "wallpapers"
                        }
                    }

                    // 4. NIGHT LIGHT
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 64
                        radius: Theme.radiusMd
                        color: GlobalState.nightLightActive ? Theme.primaryContainer : Theme.bgElevated

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                width: 40
                                height: 40
                                radius: Theme.radiusFull
                                color: GlobalState.nightLightActive ? Theme.primary : Theme.bgCard
                                Text {
                                    anchors.centerIn: parent
                                    text: GlobalState.nightLightActive ? "󰖔" : "󰖨"
                                    font.family: Theme.monoFont
                                    font.pixelSize: 22
                                    color: GlobalState.nightLightActive ? Theme.primaryFg : Theme.textMuted
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: "Night Light"
                                    font.family: Theme.font
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    color: GlobalState.nightLightActive ? Theme.primaryContainerFg : Theme.text
                                }
                                Text {
                                    text: GlobalState.nightLightActive ? "Warm" : "Off"
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    color: GlobalState.nightLightActive ? Theme.primaryContainerFg : Theme.textMuted
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                GlobalState.nightLightActive = !GlobalState.nightLightActive
                                nightProc.command = ["sh", "-c", GlobalState.nightLightActive ? "hyprsunset -t 4500 &" : "killall hyprsunset &"]
                                nightProc.running = true
                            }
                        }
                        Process { id: nightProc }
                    }

                    // 5. DO NOT DISTURB
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 64
                        radius: Theme.radiusMd
                        color: GlobalState.dndActive ? Theme.primaryContainer : Theme.bgElevated

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                width: 40
                                height: 40
                                radius: Theme.radiusFull
                                color: GlobalState.dndActive ? Theme.urgent : Theme.bgCard
                                Text {
                                    anchors.centerIn: parent
                                    text: GlobalState.dndActive ? "󰂛" : "󰂚"
                                    font.family: Theme.monoFont
                                    font.pixelSize: 22
                                    color: GlobalState.dndActive ? Theme.bg : Theme.textMuted
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: "Do Not Disturb"
                                    font.family: Theme.font
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    color: GlobalState.dndActive ? Theme.primaryContainerFg : Theme.text
                                }
                                Text {
                                    text: GlobalState.dndActive ? "Notifications Muted" : "Off"
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    color: GlobalState.dndActive ? Theme.primaryContainerFg : Theme.textMuted
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: GlobalState.dndActive = !GlobalState.dndActive
                        }
                    }

                    // 6. CAFFEINE (Idle Inhibit)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 64
                        radius: Theme.radiusMd
                        color: GlobalState.idleInhibit ? Theme.primaryContainer : Theme.bgElevated

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                width: 40
                                height: 40
                                radius: Theme.radiusFull
                                color: GlobalState.idleInhibit ? Theme.primary : Theme.bgCard
                                Text {
                                    anchors.centerIn: parent
                                    text: GlobalState.idleInhibit ? "󰅶" : "󰾪"
                                    font.family: Theme.monoFont
                                    font.pixelSize: 22
                                    color: GlobalState.idleInhibit ? Theme.primaryFg : Theme.textMuted
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: "Caffeine"
                                    font.family: Theme.font
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    color: GlobalState.idleInhibit ? Theme.primaryContainerFg : Theme.text
                                }
                                Text {
                                    text: GlobalState.idleInhibit ? "Awake" : "Normal"
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    color: GlobalState.idleInhibit ? Theme.primaryContainerFg : Theme.textMuted
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                GlobalState.idleInhibit = !GlobalState.idleInhibit
                                caffeineProc.command = ["sh", "-c", GlobalState.idleInhibit ? "killall hypridle &" : "hypridle &"]
                                caffeineProc.running = true
                            }
                        }
                        Process { id: caffeineProc }
                    }

                    // 7. SCREENSHOT
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 64
                        radius: Theme.radiusMd
                        color: shotMouse.containsMouse ? Theme.bgPill : Theme.bgElevated

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                width: 40
                                height: 40
                                radius: Theme.radiusFull
                                color: Theme.bgCard
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰄀"
                                    font.family: Theme.monoFont
                                    font.pixelSize: 22
                                    color: Theme.primary
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: "Screen Snip"
                                    font.family: Theme.font
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    color: Theme.text
                                }
                                Text {
                                    text: "Area Selection"
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    color: Theme.textMuted
                                }
                            }
                        }

                        MouseArea {
                            id: shotMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                GlobalState.controlCenterOpen = false
                                shotProc.running = true
                            }
                        }
                        Process { id: shotProc; command: ["sh", "-c", "grim -g \"$(slurp)\" - | wl-copy"] }
                    }

                    // 8. COLOR PICKER
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 64
                        radius: Theme.radiusMd
                        color: pickerMouse.containsMouse ? Theme.bgPill : Theme.bgElevated

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                width: 40
                                height: 40
                                radius: Theme.radiusFull
                                color: Theme.bgCard
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰈊"
                                    font.family: Theme.monoFont
                                    font.pixelSize: 22
                                    color: Theme.primary
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: "Color Picker"
                                    font.family: Theme.font
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    color: Theme.text
                                }
                                Text {
                                    text: "Hyprpicker"
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    color: Theme.textMuted
                                }
                            }
                        }

                        MouseArea {
                            id: pickerMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                GlobalState.controlCenterOpen = false
                                pickerProc.running = true
                            }
                        }
                        Process { id: pickerProc; command: ["hyprpicker", "-a"] }
                    }
                }

                // --- MEDIA PLAYER CARD (end-4 Style) ---
                Rectangle {
                    id: mediaCard
                    property string title: "No media active"
                    property string artist: "Desktop Shell"
                    property bool isPlaying: false

                    Layout.fillWidth: true
                    Layout.preferredHeight: 74
                    radius: Theme.radiusMd
                    color: Theme.bgElevated

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 14

                        Rectangle {
                            width: 46
                            height: 46
                            radius: Theme.radiusSm
                            color: Theme.primaryContainer

                            Text {
                                anchors.centerIn: parent
                                text: "󰓇"
                                font.family: Theme.monoFont
                                font.pixelSize: 24
                                color: Theme.primaryContainerFg
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: mediaCard.title
                                font.family: Theme.font
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: Theme.text
                                elide: Text.ElideRight
                                Layout.maximumWidth: 220
                            }
                            Text {
                                text: mediaCard.artist
                                font.family: Theme.font
                                font.pixelSize: 11
                                color: Theme.textMuted
                                elide: Text.ElideRight
                                Layout.maximumWidth: 220
                            }
                        }

                        RowLayout {
                            spacing: 10

                            Text {
                                text: "󰒮"
                                font.family: Theme.monoFont
                                font.pixelSize: 20
                                color: prevMouse.containsMouse ? Theme.primary : Theme.text
                                MouseArea {
                                    id: prevMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: prevProc.running = true
                                }
                                Process { id: prevProc; command: ["playerctl", "previous"] }
                            }

                            Rectangle {
                                width: 38
                                height: 38
                                radius: Theme.radiusFull
                                color: Theme.primary

                                Text {
                                    anchors.centerIn: parent
                                    text: mediaCard.isPlaying ? "󰏤" : "󰐊"
                                    font.family: Theme.monoFont
                                    font.pixelSize: 18
                                    color: Theme.primaryFg
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        mediaCard.isPlaying = !mediaCard.isPlaying
                                        playProc.running = true
                                    }
                                }
                                Process { id: playProc; command: ["playerctl", "play-pause"] }
                            }

                            Text {
                                text: "󰒭"
                                font.family: Theme.monoFont
                                font.pixelSize: 20
                                color: nextMouse.containsMouse ? Theme.primary : Theme.text
                                MouseArea {
                                    id: nextMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: nextProc.running = true
                                }
                                Process { id: nextProc; command: ["playerctl", "next"] }
                            }
                        }
                    }

                    Timer {
                        interval: 2000
                        running: GlobalState.controlCenterOpen
                        repeat: true
                        onTriggered: metaProc.running = true
                    }

                    Process {
                        id: metaProc
                        command: ["playerctl", "metadata", "--format", "{{title}}///{{artist}}///{{status}}"]
                        stdout: StdioCollector {
                            onStreamFinished: {
                                let t = this.text.trim();
                                if (t.length > 0 && t.includes("///")) {
                                    let p = t.split("///");
                                    mediaCard.title = p[0] || "No Track";
                                    mediaCard.artist = p[1] || "Unknown Artist";
                                    mediaCard.isPlaying = (p[2] || "").toLowerCase() === "playing";
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // --- SESSION & POWER FOOTER ---
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    // Lock
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        radius: Theme.radiusSm
                        color: lockMouse.containsMouse ? Theme.bgPill : Theme.bgElevated

                        Text {
                            anchors.centerIn: parent
                            text: "󰌾"
                            font.family: Theme.monoFont
                            font.pixelSize: 18
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
                        Layout.preferredHeight: 44
                        radius: Theme.radiusSm
                        color: suspMouse.containsMouse ? Theme.bgPill : Theme.bgElevated

                        Text {
                            anchors.centerIn: parent
                            text: "󰤄"
                            font.family: Theme.monoFont
                            font.pixelSize: 18
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
                        Layout.preferredHeight: 44
                        radius: Theme.radiusSm
                        color: logoutMouse.containsMouse ? Theme.bgPill : Theme.bgElevated

                        Text {
                            anchors.centerIn: parent
                            text: "󰍃"
                            font.family: Theme.monoFont
                            font.pixelSize: 18
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

                    // Reboot
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        radius: Theme.radiusSm
                        color: rebootMouse.containsMouse ? Theme.bgPill : Theme.bgElevated

                        Text {
                            anchors.centerIn: parent
                            text: "󰑐"
                            font.family: Theme.monoFont
                            font.pixelSize: 18
                            color: Theme.text
                        }

                        MouseArea {
                            id: rebootMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                GlobalState.controlCenterOpen = false
                                rebootProc.running = true
                            }
                        }
                        Process { id: rebootProc; command: ["systemctl", "reboot"] }
                    }

                    // Shutdown
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        radius: Theme.radiusSm
                        color: powerMouse.containsMouse ? Theme.urgent : Theme.bgElevated

                        Text {
                            anchors.centerIn: parent
                            text: "󰐥"
                            font.family: Theme.monoFont
                            font.pixelSize: 18
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

            // =============================================================
            // 3. VIEW: WI-FI NETWORKS (Scan, Password Prompt & Connect)
            // =============================================================
            ColumnLayout {
                visible: ccWindow.currentView === "wifi"
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Available Wireless Networks"
                        font.family: Theme.font
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: Theme.textMuted
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 32
                        height: 32
                        radius: Theme.radiusSm
                        color: Theme.bgElevated
                        Text {
                            anchors.centerIn: parent
                            text: "󰑐"
                            font.family: Theme.monoFont
                            font.pixelSize: 16
                            color: Theme.primary
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                ccWindow.statusNotice = "Scanning for networks..."
                                wifiScanProc.running = true
                            }
                        }
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    model: ccWindow.wifiNetworks

                    delegate: Rectangle {
                        id: netItem
                        required property var modelData
                        readonly property bool isSelected: ccWindow.selectedWifiSsid === modelData.ssid
                        width: ListView.view.width
                        height: isSelected && !modelData.active ? 96 : 52
                        radius: Theme.radiusMd
                        color: netMouse.containsMouse || isSelected ? Theme.bgPill : Theme.bgElevated
                        clip: true

                        Behavior on height {
                            NumberAnimation { duration: Theme.animFast; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.expressiveFastCurve }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                Text {
                                    text: modelData.signal > 70 ? "󰤨" : modelData.signal > 40 ? "󰤥" : "󰤟"
                                    font.family: Theme.monoFont
                                    font.pixelSize: 20
                                    color: modelData.active ? Theme.primary : Theme.text
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text {
                                        text: modelData.ssid
                                        font.family: Theme.font
                                        font.pixelSize: 13
                                        font.weight: modelData.active ? Font.Bold : Font.Medium
                                        color: modelData.active ? Theme.primary : Theme.text
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: modelData.active ? "Connected" : (modelData.signal + "% signal • " + (modelData.secure ? "Secured (WPA)" : "Open"))
                                        font.family: Theme.font
                                        font.pixelSize: 11
                                        color: Theme.textMuted
                                    }
                                }

                                Text {
                                    visible: modelData.active
                                    text: "󰄬"
                                    font.family: Theme.monoFont
                                    font.pixelSize: 18
                                    color: Theme.primary
                                }

                                Text {
                                    visible: !modelData.active && modelData.secure
                                    text: "󰌾"
                                    font.family: Theme.monoFont
                                    font.pixelSize: 14
                                    color: Theme.textMuted
                                }
                            }

                            // Password entry when expanded for connection
                            RowLayout {
                                visible: netItem.isSelected && !netItem.modelData.active
                                Layout.fillWidth: true
                                spacing: 8

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 32
                                    radius: Theme.radiusSm
                                    color: Theme.bgElevated
                                    border.color: pwdInput.activeFocus ? Theme.primary : Theme.outlineMuted
                                    border.width: 1

                                    TextInput {
                                        id: pwdInput
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        verticalAlignment: TextInput.AlignVCenter
                                        font.family: Theme.font
                                        font.pixelSize: 12
                                        color: Theme.text
                                        echoMode: TextInput.Password
                                        clip: true

                                        Text {
                                            anchors.left: parent.left
                                            anchors.verticalCenter: parent.verticalCenter
                                            visible: !pwdInput.text && !pwdInput.activeFocus
                                            text: netItem.modelData.secure ? "Enter Wi-Fi Password..." : "No password needed"
                                            font.family: Theme.font
                                            font.pixelSize: 12
                                            color: Theme.textMuted
                                        }

                                        onAccepted: netItem.doConnect()
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 80
                                    Layout.preferredHeight: 32
                                    radius: Theme.radiusSm
                                    color: Theme.primary

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Connect"
                                        font.family: Theme.font
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        color: Theme.primaryFg
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: netItem.doConnect()
                                    }
                                }
                            }
                        }

                        function doConnect() {
                            ccWindow.statusNotice = "Connecting to " + modelData.ssid + "...";
                            if (modelData.secure && pwdInput.text.length > 0) {
                                wifiConnectProc.command = ["nmcli", "dev", "wifi", "connect", modelData.ssid, "password", pwdInput.text];
                            } else {
                                wifiConnectProc.command = ["nmcli", "dev", "wifi", "connect", modelData.ssid];
                            }
                            wifiConnectProc.running = true;
                            ccWindow.selectedWifiSsid = "";
                        }

                        MouseArea {
                            id: netMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            height: 52
                            onClicked: {
                                if (modelData.active) return;
                                if (!modelData.secure) {
                                    netItem.doConnect();
                                } else {
                                    ccWindow.selectedWifiSsid = (ccWindow.selectedWifiSsid === modelData.ssid) ? "" : modelData.ssid;
                                }
                            }
                        }
                    }
                }

                Process {
                    id: wifiScanProc
                    command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,ACTIVE", "dev", "wifi"]
                    stdout: StdioCollector {
                        onStreamFinished: {
                            let lines = this.text.split("\n");
                            let list = [];
                            let seen = {};
                            for (let line of lines) {
                                if (!line || line.trim().length === 0) continue;
                                let parts = line.split(":");
                                let ssid = parts[0];
                                if (!ssid || ssid === "--" || seen[ssid]) continue;
                                seen[ssid] = true;
                                list.push({
                                    ssid: ssid,
                                    signal: parseInt(parts[1]) || 50,
                                    secure: (parts[2] || "").length > 0,
                                    active: (parts[3] || "").toLowerCase() === "yes"
                                });
                            }
                            ccWindow.wifiNetworks = list;
                            ccWindow.statusNotice = list.length + " networks found";
                        }
                    }
                }
                Process {
                    id: wifiConnectProc
                    onExited: {
                        wifiScanProc.running = true;
                    }
                }
            }

            // =============================================================
            // 4. VIEW: BLUETOOTH DEVICES (List, Connect & Pair)
            // =============================================================
            ColumnLayout {
                visible: ccWindow.currentView === "bluetooth"
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Paired & Discovered Devices"
                        font.family: Theme.font
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: Theme.textMuted
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 32
                        height: 32
                        radius: Theme.radiusSm
                        color: Theme.bgElevated
                        Text {
                            anchors.centerIn: parent
                            text: "󰑐"
                            font.family: Theme.monoFont
                            font.pixelSize: 16
                            color: Theme.primary
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                ccWindow.statusNotice = "Scanning Bluetooth devices...";
                                btScanProc.running = true;
                            }
                        }
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    model: ccWindow.btDevices

                    delegate: Rectangle {
                        id: btItem
                        required property var modelData
                        width: ListView.view.width
                        height: 54
                        radius: Theme.radiusMd
                        color: btMouse.containsMouse ? Theme.bgPill : Theme.bgElevated

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 14

                            Text {
                                text: "󰂯"
                                font.family: Theme.monoFont
                                font.pixelSize: 22
                                color: Theme.primary
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: modelData.name
                                    font.family: Theme.font
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    color: Theme.text
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: modelData.mac
                                    font.family: Theme.monoFont
                                    font.pixelSize: 11
                                    color: Theme.textMuted
                                }
                            }

                            Rectangle {
                                width: 78
                                height: 32
                                radius: Theme.radiusSm
                                color: Theme.primaryContainer

                                Text {
                                    anchors.centerIn: parent
                                    text: "Connect"
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    color: Theme.primaryContainerFg
                                }
                            }
                        }

                        MouseArea {
                            id: btMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                ccWindow.statusNotice = "Connecting to " + modelData.name + "...";
                                btConnectProc.command = ["sh", "-c", "bluetoothctl connect " + modelData.mac + " || (bluetoothctl pair " + modelData.mac + " && bluetoothctl connect " + modelData.mac + ")"];
                                btConnectProc.running = true;
                            }
                        }
                    }
                }

                Process {
                    id: btScanProc
                    command: ["bluetoothctl", "devices"]
                    stdout: StdioCollector {
                        onStreamFinished: {
                            let lines = this.text.split("\n");
                            let list = [];
                            for (let line of lines) {
                                if (!line || line.trim().length === 0) continue;
                                let parts = line.split(" ");
                                if (parts.length >= 3 && parts[0] === "Device") {
                                    list.push({
                                        mac: parts[1],
                                        name: parts.slice(2).join(" ")
                                    });
                                }
                            }
                            ccWindow.btDevices = list;
                            ccWindow.statusNotice = list.length + " Bluetooth devices found";
                        }
                    }
                }
                Process { id: btConnectProc }
            }

            // =============================================================
            // 5. VIEW: WALLPAPER GALLERY (Live Apply & Color Sync)
            // =============================================================
            ColumnLayout {
                visible: ccWindow.currentView === "wallpapers"
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                FolderListModel {
                    id: wallModel
                    folder: GlobalConfig.wallpapersDir
                    nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
                    showDirs: false
                }

                GridView {
                    id: wallGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    cellWidth: 144
                    cellHeight: 98
                    clip: true
                    model: wallModel

                    delegate: Item {
                        id: wallDelegate
                        required property url fileUrl
                        required property string filePath
                        required property string fileName
                        width: 136
                        height: 90

                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.radiusMd
                            color: Theme.bgElevated
                            border.color: wallImgMouse.containsMouse ? Theme.primary : Theme.outlineMuted
                            border.width: wallImgMouse.containsMouse ? 2 : 1
                            clip: true

                            Behavior on border.color {
                                ColorAnimation { duration: Theme.animFast; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.expressiveFastCurve }
                            }

                            Image {
                                anchors.fill: parent
                                source: wallDelegate.fileUrl ? wallDelegate.fileUrl : ("file://" + wallDelegate.filePath)
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 22
                                color: Qt.rgba(0, 0, 0, 0.70)
                                visible: wallImgMouse.containsMouse

                                Text {
                                    anchors.centerIn: parent
                                    text: wallDelegate.fileName
                                    font.family: Theme.font
                                    font.pixelSize: 10
                                    color: "#ffffff"
                                    elide: Text.ElideMiddle
                                    width: parent.width - 8
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            MouseArea {
                                id: wallImgMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    applyWallProc.apply(wallDelegate.filePath)
                                }
                            }
                        }
                    }
                }

                Process {
                    id: applyWallProc
                    function apply(path) {
                        let clean = path.replace("file://", "");
                        ccWindow.statusNotice = "Applying wallpaper & regenerating colors...";
                        // Run matugen first so colors.json is updated, then swww with smooth transition
                        applyWallProc.command = [
                            "sh", "-c",
                            "matugen image '" + clean + "' --source-color-index 0 && swww img '" + clean + "' --transition-type any --transition-fps 60"
                        ];
                        applyWallProc.running = true;
                    }
                    onExited: {
                        ccWindow.statusNotice = "Theme colors updated!";
                        Theme.forceReload();
                    }
                }
            }

            // =============================================================
            // 6. VIEW: SETTINGS & CUSTOMIZATION (end-4 GUI Settings Panel)
            // =============================================================
            ColumnLayout {
                visible: ccWindow.currentView === "settings"
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                // Option 1: Bar Width
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        text: "Bar Width: " + Math.round(GlobalConfig.barWidthRatio * 100) + "%"
                        font.family: Theme.font
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }
                    RowLayout {
                        spacing: 8
                        Repeater {
                            model: [
                                { label: "75%", val: 0.75 },
                                { label: "85%", val: 0.85 },
                                { label: "92%", val: 0.92 },
                                { label: "100%", val: 1.0 }
                            ]
                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                height: 36
                                radius: Theme.radiusSm
                                color: GlobalConfig.barWidthRatio === modelData.val ? Theme.primary : Theme.bgElevated

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.family: Theme.font
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    color: GlobalConfig.barWidthRatio === modelData.val ? Theme.primaryFg : Theme.text
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: GlobalConfig.barWidthRatio = modelData.val
                                }
                            }
                        }
                    }
                }

                // Option 2: Bar Height
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        text: "Bar Height: " + GlobalConfig.barHeight + "px"
                        font.family: Theme.font
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }
                    RowLayout {
                        spacing: 8
                        Repeater {
                            model: [
                                { label: "Standard (46px)", val: 46 },
                                { label: "Large (50px)", val: 50 },
                                { label: "Extra (56px)", val: 56 }
                            ]
                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                height: 36
                                radius: Theme.radiusSm
                                color: GlobalConfig.barHeight === modelData.val ? Theme.primary : Theme.bgElevated

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.family: Theme.font
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    color: GlobalConfig.barHeight === modelData.val ? Theme.primaryFg : Theme.text
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: GlobalConfig.barHeight = modelData.val
                                }
                            }
                        }
                    }
                }

                // Option 3: Corner Rounding
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        text: "Bar Corner Radius: " + GlobalConfig.cornerRadius + "px"
                        font.family: Theme.font
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }
                    RowLayout {
                        spacing: 8
                        Repeater {
                            model: [
                                { label: "Subtle (12px)", val: 12 },
                                { label: "Smooth (18px)", val: 18 },
                                { label: "Round (26px)", val: 26 }
                            ]
                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                height: 36
                                radius: Theme.radiusSm
                                color: GlobalConfig.cornerRadius === modelData.val ? Theme.primary : Theme.bgElevated

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.family: Theme.font
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    color: GlobalConfig.cornerRadius === modelData.val ? Theme.primaryFg : Theme.text
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: GlobalConfig.cornerRadius = modelData.val
                                }
                            }
                        }
                    }
                }

                // Option 4: Toggles
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Show Focused Window Title in Bar"
                        font.family: Theme.font
                        font.pixelSize: 13
                        color: Theme.text
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 48
                        height: 26
                        radius: Theme.radiusFull
                        color: GlobalConfig.showWindowTitles ? Theme.primary : Theme.bgElevated

                        Rectangle {
                            x: GlobalConfig.showWindowTitles ? 24 : 2
                            y: 2
                            width: 22
                            height: 22
                            radius: Theme.radiusFull
                            color: GlobalConfig.showWindowTitles ? Theme.primaryFg : Theme.textMuted
                            Behavior on x { NumberAnimation { duration: Theme.animFast; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.expressiveFastCurve } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: GlobalConfig.showWindowTitles = !GlobalConfig.showWindowTitles
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Show Date alongside Clock"
                        font.family: Theme.font
                        font.pixelSize: 13
                        color: Theme.text
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 48
                        height: 26
                        radius: Theme.radiusFull
                        color: GlobalConfig.showClockDate ? Theme.primary : Theme.bgElevated

                        Rectangle {
                            x: GlobalConfig.showClockDate ? 24 : 2
                            y: 2
                            width: 22
                            height: 22
                            radius: Theme.radiusFull
                            color: GlobalConfig.showClockDate ? Theme.primaryFg : Theme.textMuted
                            Behavior on x { NumberAnimation { duration: Theme.animFast; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.expressiveFastCurve } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: GlobalConfig.showClockDate = !GlobalConfig.showClockDate
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Save Layout Button
                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    radius: Theme.radiusMd
                    color: Theme.primary

                    Text {
                        anchors.centerIn: parent
                        text: "󰆓  Save Layout & Settings"
                        font.family: Theme.font
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: Theme.primaryFg
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            GlobalConfig.save()
                            ccWindow.currentView = "main"
                        }
                    }
                }
            }
        }
    }
}
