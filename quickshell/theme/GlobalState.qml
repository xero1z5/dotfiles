pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property bool controlCenterOpen: false
    property bool dndActive: false
    property bool nightLightActive: false
    property bool idleInhibit: false
    property bool wifiEnabled: true
    property bool btEnabled: true
    property string activeSsid: "Wi-Fi"
    property string activeBtDevice: "Bluetooth"
}
