import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Caelestia
import Caelestia.Blobs
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Keybinds")
    isSubPage: true

    property var vars: ({})
    property var defaults: ({})

    readonly property string configPath: Quickshell.env("HOME") + "/.config/caelestia/hypr-vars.lua"
    readonly property string defaultsPath: Quickshell.env("HOME") + "/.config/hypr/variables.lua"

    // Single source of truth for the visual editor. Every bind that exists in
    // the Hyprland config is listed here, grouped by what it does.
    readonly property var keybindSections: [
        {
            title: qsTr("Launcher & Shell"),
            entries: [
                { key: "kbLauncher", label: qsTr("Launcher") },
                { key: "kbSession", label: qsTr("Session menu") },
                { key: "kbShowSidebar", label: qsTr("Toggle sidebar") },
                { key: "kbClearNotifs", label: qsTr("Clear notifications") },
                { key: "kbShowPanels", label: qsTr("Show all panels") },
                { key: "kbWorkspaceOverview", label: qsTr("Workspace overview") },
                { key: "kbLock", label: qsTr("Lock screen") },
                { key: "kbRestoreLock", label: qsTr("Restore lock screen") },
                { key: "kbSleep", label: qsTr("Sleep") },
                { key: "kbRestartShell", label: qsTr("Restart shell") },
                { key: "kbReloadShell", label: qsTr("Reload shell") },
                { key: "kbTestNotification", label: qsTr("Test notification") },
                { key: "kbAiAssistant", label: qsTr("AI assistant") },
                { key: "kbWallpaperSelector", label: qsTr("Wallpaper selector") }
            ]
        },
        {
            title: qsTr("Workspaces"),
            entries: [
                { key: "kbGoToWs", label: qsTr("Go to workspace"), hint: qsTr("hold + 1–0") },
                { key: "kbGoToWsGroup", label: qsTr("Go to workspace group"), hint: qsTr("hold + 1–0") },
                { key: "kbMoveWinToWs", label: qsTr("Move window to workspace"), hint: qsTr("hold + 1–0") },
                { key: "kbMoveWinToWsGroup", label: qsTr("Move window to workspace group"), hint: qsTr("hold + 1–0") },
                { key: "kbMoveWinToWsSpecial", label: qsTr("Move window to special workspace") },
                { key: "kbMoveWinFromWsSpecial", label: qsTr("Move window from special workspace") },
                { key: "kbMoveWinToWsNext", label: qsTr("Move window to next workspace") },
                { key: "kbMoveWinToWsPrev", label: qsTr("Move window to previous workspace") },
                { key: "kbNextWs", label: qsTr("Next workspace") },
                { key: "kbPrevWs", label: qsTr("Previous workspace") },
                { key: "kbNextWsGroup", label: qsTr("Next workspace group") },
                { key: "kbPrevWsGroup", label: qsTr("Previous workspace group") }
            ]
        },
        {
            title: qsTr("Window Groups"),
            entries: [
                { key: "kbWindowCycleNext", label: qsTr("Cycle to next window") },
                { key: "kbWindowCyclePrev", label: qsTr("Cycle to previous window") },
                { key: "kbWindowGroupCycleNext", label: qsTr("Cycle to next window in group") },
                { key: "kbWindowGroupCyclePrev", label: qsTr("Cycle to previous window in group") },
                { key: "kbUngroup", label: qsTr("Ungroup window") },
                { key: "kbToggleGroup", label: qsTr("Toggle group") },
                { key: "kbGroupLockActive", label: qsTr("Lock active group") }
            ]
        },
        {
            title: qsTr("Window Actions"),
            entries: [
                { key: "kbFocusWindow", label: qsTr("Focus window"), hint: qsTr("hold + arrows") },
                { key: "kbMoveWindowDir", label: qsTr("Move window"), hint: qsTr("hold + arrows") },
                { key: "kbWindowDecreaseWidth", label: qsTr("Decrease width") },
                { key: "kbWindowIncreaseWidth", label: qsTr("Increase width") },
                { key: "kbWindowDecreaseHeight", label: qsTr("Decrease height") },
                { key: "kbWindowIncreaseHeight", label: qsTr("Increase height") },
                { key: "kbMoveWindow", label: qsTr("Move window with mouse (keyboard)") },
                { key: "kbResizeWindow", label: qsTr("Resize window with mouse (keyboard)") },
                { key: "kbCenterWindow", label: qsTr("Center window") },
                { key: "kbNormalizeWindow", label: qsTr("Normalize window") },
                { key: "kbWindowPip", label: qsTr("Picture-in-picture") },
                { key: "kbPinWindow", label: qsTr("Pin window") },
                { key: "kbWindowFullscreen", label: qsTr("Fullscreen") },
                { key: "kbWindowBorderedFullscreen", label: qsTr("Bordered fullscreen") },
                { key: "kbToggleWindowFloating", label: qsTr("Toggle floating") },
                { key: "kbCloseWindow", label: qsTr("Close window") }
            ]
        },
        {
            title: qsTr("Mouse"),
            entries: [
                { key: "kbMoveWindowMouse", label: qsTr("Move window (drag)") },
                { key: "kbResizeWindowMouse", label: qsTr("Resize window (drag)") }
            ]
        },
        {
            title: qsTr("Special Workspaces"),
            entries: [
                { key: "kbSpecialWs", label: qsTr("Special workspace toggle") },
                { key: "kbSystemMonitorWs", label: qsTr("System monitor") },
                { key: "kbMusicWs", label: qsTr("Music") },
                { key: "kbCommunicationWs", label: qsTr("Communication") },
                { key: "kbTodoWs", label: qsTr("To-do") }
            ]
        },
        {
            title: qsTr("Apps"),
            entries: [
                { key: "kbTerminal", label: qsTr("Terminal") },
                { key: "kbBrowser", label: qsTr("Browser") },
                { key: "kbEditor", label: qsTr("Editor") },
                { key: "kbFileExplorer", label: qsTr("File explorer") },
                { key: "kbAudioSettings", label: qsTr("Audio settings") }
            ]
        },
        {
            title: qsTr("Screenshots & Recording"),
            entries: [
                { key: "kbScreenshot", label: qsTr("Screenshot") },
                { key: "kbScreenshotFreeze", label: qsTr("Freeze screen for screenshot") },
                { key: "kbScreenshotRegion", label: qsTr("Screenshot region") },
                { key: "kbRecord", label: qsTr("Record screen") },
                { key: "kbRecordSound", label: qsTr("Record screen with sound") },
                { key: "kbRecordRegion", label: qsTr("Record region") },
                { key: "kbColorPicker", label: qsTr("Colour picker") }
            ]
        },
        {
            title: qsTr("Media, Volume & Brightness"),
            entries: [
                { key: "kbMediaToggle", label: qsTr("Play / pause") },
                { key: "kbMediaNext", label: qsTr("Next track") },
                { key: "kbMediaPrev", label: qsTr("Previous track") },
                { key: "kbMediaStop", label: qsTr("Stop media") },
                { key: "kbVolumeMute", label: qsTr("Mute output") },
                { key: "kbVolumeUp", label: qsTr("Volume up") },
                { key: "kbVolumeDown", label: qsTr("Volume down") },
                { key: "kbMicMute", label: qsTr("Mute microphone") },
                { key: "kbBrightnessUp", label: qsTr("Brightness up") },
                { key: "kbBrightnessDown", label: qsTr("Brightness down") }
            ]
        },
        {
            title: qsTr("Clipboard & Emoji"),
            entries: [
                { key: "kbClipboard", label: qsTr("Clipboard history") },
                { key: "kbClipboardDel", label: qsTr("Delete clipboard entry") },
                { key: "kbClipboardPasteLatest", label: qsTr("Paste latest clipboard entry") },
                { key: "kbEmoji", label: qsTr("Emoji picker") }
            ]
        }
    ]

    // Non-keybind settings are kept in the same write order as before so
    // saving a keybind does not scramble the rest of hypr-vars.lua.
    readonly property var settingSections: [
        { title: qsTr("Apps"), keys: ["terminal", "browser", "editor", "fileExplorer", "audioSettings"] },
        { title: qsTr("Touchpad"), keys: ["touchpadDisableTyping", "touchpadScrollFactor", "gestureFingers", "workspaceSwipeFingers", "gestureFingersMore"] },
        { title: qsTr("Blur"), keys: ["blurEnabled", "blurSpecialWs", "blurPopups", "blurInputMethods", "blurSize", "blurPasses", "blurXray"] },
        { title: qsTr("Shadow"), keys: ["shadowEnabled", "shadowRange", "shadowRenderPower", "shadowColour"] },
        { title: qsTr("Gaps"), keys: ["workspaceGaps", "windowGapsIn", "windowGapsOut", "singleWindowGapsOut"] },
        { title: qsTr("Window styling"), keys: ["windowOpacity", "windowRounding", "windowRoundingPower", "windowBorderSize", "activeWindowBorderColour", "inactiveWindowBorderColour"] },
        { title: qsTr("Misc"), keys: ["volumeStep", "volumeMax", "cursorTheme", "cursorSize", "sleepGestureCmd"] }
    ]

    Component.onCompleted: {
        if (Hypr.usingLua) {
            Quickshell.execDetached(["hyprctl", "eval", "hl.define_submap('record', function() hl.bind('XF86LaunchA', hl.dsp.submap('reset')) end)"]);
        } else {
            Hypr.extras.batchMessage([
                "keyword submap record",
                "keyword bind ,XF86LaunchA,submap,reset",
                "keyword submap reset"
            ]);
        }
        loadVars();
    }

    function parseRawVars(content) {
        let result = {};
        if (!content) return result;

        let lines = content.split("\n");
        for (let i = 0; i < lines.length; i++) {
            let match = lines[i].match(/^\s*([a-zA-Z0-9_]+)\s*=\s*(.+?)\s*,?$/);
            if (match)
                result[match[1]] = match[2];
        }
        return result;
    }

    function parseValue(raw) {
        if (raw === undefined || raw === null) return undefined;

        let val = String(raw).trim();
        if (val.endsWith(",")) val = val.slice(0, -1).trim();

        if (val === "true") return true;
        if (val === "false") return false;

        if (val.startsWith("{") && val.endsWith("}")) {
            let values = [];
            let inner = val.slice(1, -1);
            let re = /"([^"]*)"|'([^']*)'|([^,]+)/g;
            let match;
            while ((match = re.exec(inner)) !== null) {
                let item = match[1] !== undefined ? match[1] : (match[2] !== undefined ? match[2] : match[3]);
                item = item.trim();
                if (item.length > 0) values.push(item);
            }
            return values;
        }

        if ((val.startsWith("\"") && val.endsWith("\"")) || (val.startsWith("'") && val.endsWith("'")))
            return val.slice(1, -1);

        let number = Number(val);
        if (val.length > 0 && !isNaN(number)) return number;

        return val;
    }

    function serializeValue(value) {
        if (typeof value === "boolean") return value ? "true" : "false";
        if (typeof value === "number") return String(value);
        if (Array.isArray(value)) {
            let parts = [];
            for (let i = 0; i < value.length; i++)
                parts.push("\"" + String(value[i]).replace(/\\/g, "\\\\").replace(/"/g, "\\\"") + "\"");
            return "{ " + parts.join(", ") + " }";
        }

        let text = String(value);
        if (text.startsWith("rgba(") || text.startsWith("scheme.")) return text;
        return "\"" + text.replace(/\\/g, "\\\\").replace(/"/g, "\\\"") + "\"";
    }

    function displayValue(key) {
        let value = root.vars[key] !== undefined ? root.vars[key] : root.defaults[key];
        if (value === undefined) return qsTr("Unbound");
        if (Array.isArray(value)) return value.join("  /  ");
        return String(value);
    }

    function writeSchema() {
        let sections = [];
        for (let i = 0; i < settingSections.length; i++)
            sections.push(settingSections[i]);

        for (let i = 0; i < keybindSections.length; i++) {
            let entries = keybindSections[i].entries;
            let keys = [];
            for (let j = 0; j < entries.length; j++)
                keys.push(entries[j].key);
            sections.push({ title: keybindSections[i].title, keys: keys });
        }
        return sections;
    }

    function buildContent(currentVars) {
        let needsScheme = false;
        for (let k in currentVars) {
            if (String(currentVars[k]).includes("scheme.")) needsScheme = true;
        }

        let content = needsScheme ? "local scheme = require(\"scheme.current\")\n\nreturn {\n" : "return {\n";
        let written = {};
        let sections = writeSchema();

        for (let s = 0; s < sections.length; s++) {
            let keys = sections[s].keys;
            let emitted = false;

            for (let i = 0; i < keys.length; i++) {
                let key = keys[i];
                if (currentVars[key] === undefined) continue;

                if (!emitted) {
                    content += "    -- " + sections[s].title + "\n";
                    emitted = true;
                }
                content += "    " + key.padEnd(26) + " = " + currentVars[key] + ",\n";
                written[key] = true;
            }
            if (emitted) content += "\n";
        }

        let custom = false;
        for (let key in currentVars) {
            if (written[key]) continue;
            if (!custom) {
                content += "    -- Custom\n";
                custom = true;
            }
            content += "    " + key.padEnd(26) + " = " + currentVars[key] + ",\n";
        }

        return content.replace(/\s+$/, "") + "\n}\n";
    }

    function writeConfig(content) {
        try {
            CUtils.writeFile(configPath, content);
        } catch (e) {
            console.log("Could not write file natively yet: " + e);
            Quickshell.execDetached(["bash", "-c", "cat << 'EOF' > " + configPath + "\n" + content + "\nEOF"]);
        }
    }

    function saveVar(key, val) {
        let currentVars = parseRawVars(CUtils.fileExists(configPath) ? CUtils.readFile(configPath) : "");
        currentVars[key] = serializeValue(val);
        writeConfig(buildContent(currentVars));
        loadVars();
    }

    function deleteVar(key) {
        if (!CUtils.fileExists(configPath)) return;

        let currentVars = parseRawVars(CUtils.readFile(configPath));
        if (currentVars[key] === undefined) return;

        delete currentVars[key];
        writeConfig(buildContent(currentVars));
        loadVars();
    }

    function loadVars() {
        let dVars = {};
        let defContent = CUtils.readFile(defaultsPath);
        if (defContent) {
            let rawDefaults = parseRawVars(defContent);
            for (let key in rawDefaults)
                dVars[key] = parseValue(rawDefaults[key]);
        }
        root.defaults = dVars;

        let newVars = {};
        if (CUtils.fileExists(configPath)) {
            let rawVars = parseRawVars(CUtils.readFile(configPath));
            for (let key in rawVars)
                newVars[key] = parseValue(rawVars[key]);
        }
        root.vars = newVars;
    }

    component KeybindRow : ConnectedRect {
        id: kroot
        property string label
        property string varKey
        property string hint: ""
        property bool recording: false

        Layout.fillWidth: true
        implicitHeight: contentRow.implicitHeight + contentRow.anchors.margins * 2

        StateLayer {
            id: stateLayer
            anchors.fill: parent
            onClicked: {
                kroot.recording = !kroot.recording;
                if (kroot.recording) {
                    focusItem.forceActiveFocus();
                    if (Hypr.usingLua) {
                        Quickshell.execDetached(["hyprctl", "eval", "hl.define_submap('record', function() hl.bind('XF86LaunchA', hl.dsp.submap('reset')) end); hl.dispatch(hl.dsp.submap('record'))"]);
                    } else {
                        Hypr.extras.batchMessage([
                            "keyword submap record",
                            "keyword bind ,XF86LaunchA,submap,reset",
                            "keyword submap reset"
                        ]);
                        Hypr.dispatch("submap record");
                    }
                } else {
                    Hypr.dispatch(Hypr.usingLua ? 'hl.dsp.submap("reset")' : "submap reset");
                }
            }
        }

        RowLayout {
            id: contentRow
            anchors.fill: parent
            anchors.margins: Tokens.padding.medium
            anchors.leftMargin: Tokens.padding.largeIncreased
            anchors.rightMargin: Tokens.padding.largeIncreased
            spacing: Tokens.spacing.medium

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small

                    StyledText {
                        text: kroot.label
                        font: Tokens.font.body.small
                        elide: Text.ElideRight
                    }

                    IconButton {
                        icon: "delete"
                        type: IconButton.Text
                        font: Tokens.font.icon.small
                        visible: root.vars[kroot.varKey] !== undefined
                        onClicked: root.deleteVar(kroot.varKey)
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                StyledText {
                    text: kroot.recording ? qsTr("Recording…") : root.displayValue(kroot.varKey) + (kroot.hint.length > 0 ? "  ·  " + kroot.hint : "")
                    color: Colours.palette.m3outline
                    font: Tokens.font.label.small
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            Item {
                id: recordBtn

                implicitWidth: btn.implicitWidth * 0.9
                implicitHeight: btn.implicitHeight * 0.9

                BlobGroup {
                    id: blobGroup
                    color: kroot.recording || stateLayer.containsMouse ? Colours.palette.m3secondaryContainer : Colours.palette.m3surfaceContainerHighest
                    smoothing: kroot.Tokens.rounding.medium
                    cornerFill: false

                    Behavior on color {
                        CAnim {}
                    }
                }

                BlobRect {
                    id: btnRect
                    anchors.fill: parent
                    anchors.margins: (stateLayer.containsMouse ? -Tokens.padding.extraSmall : 0) + (kroot.recording ? -Tokens.padding.extraSmall : 0)
                    group: blobGroup
                    radius: kroot.recording ? Tokens.rounding.large : Tokens.rounding.medium

                    Behavior on anchors.margins {
                        Anim {}
                    }

                    Behavior on radius {
                        Anim {
                            type: Anim.DefaultEffects
                        }
                    }
                }

                Item {
                    id: btn
                    anchors.centerIn: parent
                    implicitWidth: implicitHeight
                    implicitHeight: icon.implicitHeight + Tokens.padding.extraSmall * 2

                    MaterialIcon {
                        id: icon
                        anchors.centerIn: parent
                        text: kroot.recording ? "stop_circle" : "screen_record"
                        color: kroot.recording || stateLayer.containsMouse ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                        fontStyle: Tokens.font.icon.medium
                    }
                }
            }
        }

        Item {
            id: focusItem
            focus: kroot.recording
            property bool modifierOnly: false
            property var lastMods: []

            Keys.onPressed: (event) => {
                if (!kroot.recording) return;
                let k = event.key;
                if (k === Qt.Key_Escape) {
                    kroot.recording = false;
                    Hypr.dispatch(Hypr.usingLua ? 'hl.dsp.submap("reset")' : "submap reset");
                    event.accepted = true;
                    return;
                }

                let mods = [];
                if (event.modifiers & Qt.ControlModifier) mods.push("CTRL");
                if (event.modifiers & Qt.ShiftModifier) mods.push("SHIFT");
                if (event.modifiers & Qt.AltModifier) mods.push("ALT");
                if (event.modifiers & Qt.MetaModifier) mods.push("SUPER");

                let keyStr = "";
                if (k >= Qt.Key_A && k <= Qt.Key_Z) {
                    keyStr = String.fromCharCode(k);
                } else if (k >= Qt.Key_0 && k <= Qt.Key_9) {
                    keyStr = String.fromCharCode(k);
                } else {
                    let map = {
                        [Qt.Key_Return]: "Return",
                        [Qt.Key_Enter]: "Return",
                        [Qt.Key_Space]: "Space",
                        [Qt.Key_Tab]: "Tab",
                        [Qt.Key_Backtab]: "Tab",
                        [Qt.Key_Backspace]: "Backspace",
                        [Qt.Key_Minus]: "minus",
                        [Qt.Key_Equal]: "equal",
                        [Qt.Key_BracketLeft]: "bracketleft",
                        [Qt.Key_BracketRight]: "bracketright",
                        [Qt.Key_Semicolon]: "semicolon",
                        [Qt.Key_Apostrophe]: "apostrophe",
                        [Qt.Key_Grave]: "grave",
                        [Qt.Key_Slash]: "slash",
                        [Qt.Key_Period]: "period",
                        [Qt.Key_Backslash]: "backslash",
                        [Qt.Key_Comma]: "comma",
                        [Qt.Key_Right]: "Right",
                        [Qt.Key_Left]: "Left",
                        [Qt.Key_Up]: "Up",
                        [Qt.Key_Down]: "Down",
                        [Qt.Key_Delete]: "Delete"
                    };
                    if (map[k] !== undefined) keyStr = map[k];
                    else keyStr = event.text.toUpperCase();
                }

                let isModKey = (k === Qt.Key_Control || k === Qt.Key_Shift || k === Qt.Key_Alt || k === Qt.Key_Meta || k === Qt.Key_Super_L || k === Qt.Key_Super_R);

                if (keyStr !== "" && !isModKey) {
                    modifierOnly = false;
                    mods.push(keyStr);
                    let finalBind = mods.join(" + ");
                    root.saveVar(kroot.varKey, finalBind);
                    kroot.recording = false;
                    Hypr.dispatch(Hypr.usingLua ? 'hl.dsp.submap("reset")' : "submap reset");
                    event.accepted = true;
                } else if (isModKey) {
                    modifierOnly = true;
                    let modStr = "";
                    if (k === Qt.Key_Control) modStr = "CTRL";
                    else if (k === Qt.Key_Shift) modStr = "SHIFT";
                    else if (k === Qt.Key_Alt) modStr = "ALT";
                    else if (k === Qt.Key_Meta || k === Qt.Key_Super_L || k === Qt.Key_Super_R) modStr = "SUPER";

                    if (!mods.includes(modStr) && modStr !== "") mods.push(modStr);
                    lastMods = mods;
                    event.accepted = true;
                }
            }

            Keys.onReleased: (event) => {
                if (!kroot.recording) return;
                let k = event.key;
                let isModKey = (k === Qt.Key_Control || k === Qt.Key_Shift || k === Qt.Key_Alt || k === Qt.Key_Meta || k === Qt.Key_Super_L || k === Qt.Key_Super_R);

                if (isModKey && modifierOnly && lastMods.length > 0) {
                    let finalBind = lastMods.join(" + ");
                    root.saveVar(kroot.varKey, finalBind);
                    kroot.recording = false;
                    Hypr.dispatch(Hypr.usingLua ? 'hl.dsp.submap("reset")' : "submap reset");
                    event.accepted = true;
                }
            }
        }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        Repeater {
            model: root.keybindSections

            delegate: ColumnLayout {
                id: sectionColumn
                required property var modelData
                required property int index

                Layout.fillWidth: true
                spacing: Tokens.spacing.extraSmall / 2

                SectionHeader {
                    first: sectionColumn.index === 0
                    text: sectionColumn.modelData.title
                }

                Repeater {
                    model: sectionColumn.modelData.entries

                    delegate: KeybindRow {
                        required property var modelData
                        required property int index

                        first: index === 0
                        last: index === sectionColumn.modelData.entries.length - 1
                        label: modelData.label
                        varKey: modelData.key
                        hint: modelData.hint !== undefined ? modelData.hint : ""
                    }
                }
            }
        }

        Item {
            Layout.preferredHeight: Tokens.padding.large
            Layout.fillWidth: true
        }
    }
}
