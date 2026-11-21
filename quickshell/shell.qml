import QtQuick
import Quickshell

import "theme"
import "bar"
import "controlcenter"
import "notifications"

ShellRoot {
    id: root

    // Top Status Bar (Athena / end-4 inspired)
    Bar {}

    // Athena Control Center (Wi-Fi, Bluetooth, Sliders, Quick Toggles, Session)
    ControlCenter {}

    // Notification Daemon & Toast Popups
    Notifications {}
}
