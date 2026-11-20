import QtQuick
import Quickshell

import "theme"
import "bar"
import "dock"
import "controlcenter"
import "notifications"

ShellRoot {
    id: root

    // Top Status Bar (Athena island style)
    Bar {}

    // Home Dock (Bottom floating island with pinned & running apps)
    Dock {}

    // Control Center (Athena quick settings, audio/brightness sliders, power)
    ControlCenter {}

    // Notification Daemon & Toast Popups (Replaces Dunst)
    Notifications {}
}

