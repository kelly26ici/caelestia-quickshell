// Gate component for the dock: reads the dock section of
// ~/.config/caelestia/shell.json and exposes whether the dock is enabled.
// Instantiated statically in shell.qml (so the dock loads in the same import
// context as the rest of the shell — Loader-sourced files cannot resolve
// `qs.*` URI imports).

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    width: 0
    height: 0
    visible: false

    property var conf: ({})
    property bool retried: false
    readonly property bool gateEnabled: conf?.enabled === true

    FileView {
        id: gateView

        watchChanges: true
        printErrors: false
        path: Quickshell.env("HOME") + "/.config/caelestia/shell.json"
        onLoaded: {
            try {
                root.conf = JSON.parse(gateView.text() || "{}").dock ?? {};
            } catch (e) {
                console.warn("Dock gate: failed to parse shell.json:", e);
            }
        }
        onLoadFailed: err => console.warn("Dock gate: failed to load shell.json:", err)
        onFileChanged: fileReloadTimer.restart()
    }

    // Debounced reload on file changes, so toggling the dock from nexus
    // (which rewrites shell.json) flips `gateEnabled` live.
    Timer {
        id: fileReloadTimer

        interval: 150
        onTriggered: gateView.reload()
    }

    // Retry once shortly after startup in case the file is written between
    // engine start and the first load.
    Timer {
        interval: 1500
        running: true
        onTriggered: {
            if (!root.retried && root.conf.enabled === undefined) {
                root.retried = true;
                gateView.reload();
            }
        }
    }

    function forceLoad(): void {
        gateView.reload();
    }
}
