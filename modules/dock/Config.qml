pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Shim for illogical-impulse's Config singleton, backed by the caelestia shell
 * config file (`~/.config/caelestia/shell.json`).
 *
 * The user-facing options (pinned apps, toggles, sizes) are writable and are
 * persisted back into the same file on change. Values that match the shim
 * defaults below are NOT written to the file, so the `.dock` section stays
 * minimal (everything implicit stays implied by this shim). Every other
 * section of the file — including externally edited ones — is preserved by
 * re-reading the file before each write.
 */
Singleton {
    id: root

    // Defaults for the writable dock options; anything not in the file falls
    // back to these. Keep in sync with the nexus Dock settings page.
    readonly property var defaults: ({
            enabled: false,
            hoverToReveal: true,
            pinnedOnStartup: false,
            monochromeIcons: true,
            height: 70,
            bottomOffset: 24,
            hoverRegionHeight: 2
        })

    property var parsed: ({})
    property bool fileReady: false
    // Suppresses change-driven saves while options are being seeded from the
    // file (avoids a redundant write on every external file reload).
    property bool syncingFromFile: false

    readonly property var options: optionsObj

    readonly property QtObject optionsObj: QtObject {
        readonly property QtObject dock: root.dockOptions

        readonly property QtObject search: QtObject {
            // Prefer levenshtein-based scoring over fuzzysort (dock search)
            readonly property bool sloppy: false
        }

        readonly property QtObject interactions: QtObject {
            readonly property QtObject scrolling: QtObject {
                readonly property bool fasterTouchpadScroll: false
                // Deltas past this count get detected as mouse scroll rather than touchpad
                readonly property int mouseScrollDeltaThreshold: 120
                readonly property int mouseScrollFactor: 120
                readonly property int touchpadScrollFactor: 450
            }
        }
    }

    readonly property QtObject dockOptions: QtObject {
        id: dockOpts

        // App IDs shown in the dock by default; persisted to shell.json on change.
        property list<string> pinnedApps: ["kitty", "brave-browser"]

        // `bottomOffset` raises the dock above the bottom edge of the screen (px).

        property bool enabled: root.defaults.enabled
        property bool hoverToReveal: root.defaults.hoverToReveal
        property bool pinnedOnStartup: root.defaults.pinnedOnStartup
        property bool monochromeIcons: root.defaults.monochromeIcons
        property real height: root.defaults.height
        property real bottomOffset: root.defaults.bottomOffset
        property real hoverRegionHeight: root.defaults.hoverRegionHeight

        // File-backed only (not writable from nexus; edit shell.json by hand).
        readonly property var ignoredAppRegexes: root.parsed?.dock?.ignoredAppRegexes ?? []
        readonly property var excludedScreens: root.parsed?.dock?.excludedScreens ?? []

        onPinnedAppsChanged: if (!root.syncingFromFile) root.scheduleDockSave()
        onEnabledChanged: if (!root.syncingFromFile) root.scheduleDockSave()
        onHoverToRevealChanged: if (!root.syncingFromFile) root.scheduleDockSave()
        onPinnedOnStartupChanged: if (!root.syncingFromFile) root.scheduleDockSave()
        onMonochromeIconsChanged: if (!root.syncingFromFile) root.scheduleDockSave()
        onHeightChanged: if (!root.syncingFromFile) root.scheduleDockSave()
        onBottomOffsetChanged: if (!root.syncingFromFile) root.scheduleDockSave()
        onHoverRegionHeightChanged: if (!root.syncingFromFile) root.scheduleDockSave()
    }

    readonly property FileView file: FileView {
        path: Quickshell.env("HOME") + "/.config/caelestia/shell.json"
        watchChanges: true
        printErrors: false

        onLoaded: root.handleFileLoaded()
        onLoadFailed: error => {
            // Missing file: there is nothing else to preserve, so allow the
            // shim to create it with only the dock section when options change.
            if (error === FileViewError.FileNotFound)
                root.fileReady = true;
        }
        onFileChanged: fileReloadTimer.restart()

        // settings.watchFiles is false in the caelestia shell root, so
        // FileViews do not auto-load; read the file explicitly on startup.
        Component.onCompleted: root.file.reload()
    }

    Timer {
        id: saveTimer

        interval: 500
        onTriggered: root.saveDockNow()
    }

    Timer {
        id: fileReloadTimer

        interval: 150
        onTriggered: root.file.reload()
    }

    function readJson(text) {
        if (typeof text !== "string" || text.trim() === "")
            return null;
        try {
            const obj = JSON.parse(text);
            return (obj !== null && typeof obj === "object" && !Array.isArray(obj)) ? obj : null;
        } catch (e) {
            return null;
        }
    }

    function sameList(a, b) {
        if (!Array.isArray(a) || !Array.isArray(b))
            return false;
        if (a.length !== b.length)
            return false;
        for (let i = 0; i < a.length; i++)
            if (String(a[i]) !== String(b[i]))
                return false;
        return true;
    }

    function handleFileLoaded() {
        root.fileReady = true;
        const fresh = root.readJson(root.file.text());
        if (!fresh)
            return;
        root.parsed = fresh;

        const fileDock = fresh?.dock;
        root.syncingFromFile = true;
        for (const key of ["enabled", "hoverToReveal", "pinnedOnStartup", "monochromeIcons", "height", "bottomOffset", "hoverRegionHeight"]) {
            const fileValue = fileDock?.[key];
            const propValue = (fileValue !== undefined && fileValue !== null) ? fileValue : root.defaults[key];
            if (dockOpts[key] !== propValue)
                dockOpts[key] = propValue;
        }
        root.syncingFromFile = false;

        const filePins = fileDock?.pinnedApps;
        if (Array.isArray(filePins)) {
            if (!root.sameList(filePins, dockOpts.pinnedApps))
                dockOpts.pinnedApps = filePins.map(p => String(p));
        } else {
            // Seed the default pins into the file on first load.
            root.scheduleDockSave();
        }
    }

    function scheduleDockSave() {
        saveTimer.restart();
    }

    function saveDockNow() {
        if (!root.fileReady)
            return;

        // Start from the freshest view of the file so external edits to
        // other sections are preserved.
        const fresh = root.readJson(root.file.text());
        if (fresh)
            root.parsed = fresh;

        let cur = (root.parsed !== null && typeof root.parsed === "object") ? root.parsed : {};
        if (!cur.dock || typeof cur.dock !== "object")
            cur.dock = {};

        const pins = [];
        for (let i = 0; i < dockOpts.pinnedApps.length; i++)
            pins.push(String(dockOpts.pinnedApps[i]));
        cur.dock.pinnedApps = pins;
        cur.dock.enabled = dockOpts.enabled;

        // Appearance / behaviour options are only written when they differ
        // from the shim defaults.
        const options = {
            hoverToReveal: dockOpts.hoverToReveal,
            pinnedOnStartup: dockOpts.pinnedOnStartup,
            monochromeIcons: dockOpts.monochromeIcons,
            height: dockOpts.height,
            bottomOffset: dockOpts.bottomOffset,
            hoverRegionHeight: dockOpts.hoverRegionHeight
        };
        for (const key in options) {
            if (options[key] !== root.defaults[key])
                cur.dock[key] = options[key];
            else if (cur.dock[key] !== undefined)
                delete cur.dock[key];
        }
        root.parsed = cur;

        // FileView persists on setText; there is no explicit write call.
        root.file.setText(JSON.stringify(cur, null, 2));
    }
}
