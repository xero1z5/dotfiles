pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Customizable UI Options (Saved in config.json)
    property real barWidthRatio: 0.85
    property int barHeight: 50
    property int cornerRadius: 18
    property bool showClockDate: true
    property bool showWindowTitles: true
    property string wallpapersDir: "file:///home/xero/dotfiles/wallpapers"

    function save() {
        let data = {
            barWidthRatio: root.barWidthRatio,
            barHeight: root.barHeight,
            cornerRadius: root.cornerRadius,
            showClockDate: root.showClockDate,
            showWindowTitles: root.showWindowTitles,
            wallpapersDir: root.wallpapersDir
        };
        saveProc.command = ["sh", "-c", "echo '" + JSON.stringify(data, null, 2) + "' > ~/.config/quickshell/theme/config.json"];
        saveProc.running = true;
    }

    function load(raw) {
        try {
            if (!raw || raw.length === 0) return;
            let data = JSON.parse(raw);
            if (data.barWidthRatio !== undefined) root.barWidthRatio = data.barWidthRatio;
            if (data.barHeight !== undefined) root.barHeight = data.barHeight;
            if (data.cornerRadius !== undefined) root.cornerRadius = data.cornerRadius;
            if (data.showClockDate !== undefined) root.showClockDate = data.showClockDate;
            if (data.showWindowTitles !== undefined) root.showWindowTitles = data.showWindowTitles;
            if (data.wallpapersDir !== undefined) root.wallpapersDir = data.wallpapersDir;
        } catch (e) {
            console.log("Error reading config.json: " + e);
        }
    }

    Process { id: saveProc }

    FileView {
        id: cfgView
        path: Qt.resolvedUrl("config.json")
        watchChanges: true
        onFileChanged: {
            this.reload();
            root.load(cfgView.text());
        }
        onLoadedChanged: {
            root.load(cfgView.text());
        }
    }
}
