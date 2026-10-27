pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services
import qs.utils
import "../bar/components" as BarComponents
import "../bar/popouts" as BarPopouts
import "../windowinfo" as WinInfo

Item {
    id: root

    required property ShellScreen modelData

    readonly property real bottomMargin: 12
    readonly property real popupGap: 6
    readonly property real dockLeft: (root.modelData.width - dockWin.implicitWidth) / 2
    readonly property bool monitorFullscreen: Hypr.monitorFor(root.modelData)?.activeWorkspace?.toplevels.values.some(t => (t.lastIpcObject.fullscreen > 1)) ?? false

    property bool winfoVisible: false

    BarPopouts.PopoutState {
        id: dockPopouts

        property real currentCenter: 0
    }

    // ---------------------------------------------------------------- dock
    StyledWindow {
        id: dockWin

        name: "dock"
        screen: root.modelData
        visible: !root.monitorFullscreen
        exclusionMode: ExclusionMode.Ignore
        anchors {
            left: true
            bottom: true
        }
        margins {
            bottom: root.bottomMargin
            left: (root.modelData.width - dockItem.implicitWidth) / 2
        }
        implicitWidth: dockItem.implicitWidth
        implicitHeight: dockItem.implicitHeight

        HoverHandler {
            id: dockHover

            onHoveredChanged: {
                if (hovered)
                    popupExitTimer.stop();
                else
                    popupExitTimer.restart();
            }
        }

        BarComponents.Dock {
            id: dockItem

            anchors.fill: parent

            bar: QtObject {
                id: barShim

                property bool isHorizontal: true
                property real width: dockItem.width
                property real height: dockItem.height
                property var popouts: dockPopouts
            }
        }
    }

    // --------------------------------------------------------------- popup
    StyledWindow {
        id: popWin

        name: "dock"
        screen: root.modelData
        visible: !root.monitorFullscreen && (dockPopouts.hasCurrent || (reviveTimer.running && dockPopouts.currentName === "dockhover"))
        exclusionMode: ExclusionMode.Ignore
        anchors {
            left: true
            bottom: true
        }
        margins {
            bottom: root.bottomMargin + dockWin.implicitHeight + root.popupGap
            left: Math.max(0, Math.min(root.dockLeft + dockPopouts.currentCenter - popWin.implicitWidth / 2, root.modelData.width - popWin.implicitWidth))
        }
        implicitWidth: activeItem ? activeItem.implicitWidth : 0
        implicitHeight: activeItem ? activeItem.implicitHeight : 0
        readonly property Item activeItem: dockPopouts.currentName === "dockcontext" ? contextHost : hoverItem

        HoverHandler {
            id: popHover

            onHoveredChanged: {
                popupExitTimer.stop();
                if (hovered) {
                    if (dockPopouts.currentName === "dockhover" && !dockPopouts.hasCurrent)
                        dockPopouts.hasCurrent = true;
                } else {
                    popupExitTimer.restart();
                }
            }
        }

        BarPopouts.DockHover {
            id: hoverItem

            visible: dockPopouts.currentName === "dockhover"
            anchors.left: parent.left
            anchors.top: parent.top
            popouts: dockPopouts
        }

        Item {
            id: contextHost

            visible: dockPopouts.currentName === "dockcontext"
            z: 1
            anchors.left: parent.left
            anchors.top: parent.top
            implicitWidth: 200
            implicitHeight: contextItem.implicitHeight

            BarPopouts.DockContext {
                id: contextItem

                anchors.fill: parent
                popouts: dockPopouts
            }
        }
    }

    Timer {
        id: reviveTimer

        interval: 120
    }

    Timer {
        id: popupExitTimer

        interval: 250
        onTriggered: {
            if (dockHover.hovered || popHover.hovered)
                return;
            if (dockPopouts.currentName === "dockcontext")
                return; // Context menu stays open until clicked outside (grab) or an action is chosen.
            dockPopouts.hasCurrent = false;
        }
    }

    Connections {
        target: dockPopouts

        function onHasCurrentChanged(): void {
            if (dockPopouts.hasCurrent)
                reviveTimer.stop();
            else if (dockPopouts.currentName === "dockhover" && popWin.visible)
                reviveTimer.restart();
            contextGrab.active = dockPopouts.hasCurrent && dockPopouts.currentName === "dockcontext";
        }

        function onCurrentNameChanged(): void {
            contextGrab.active = dockPopouts.hasCurrent && dockPopouts.currentName === "dockcontext";
        }

        function onDetachRequested(mode: string): void {
            if (mode === "winfo")
                root.winfoVisible = true;
            dockPopouts.hasCurrent = false;
        }
    }

    // Closes the dock context menu when focus moves outside the popup.
    HyprlandFocusGrab {
        id: contextGrab

        windows: [popWin]
        onCleared: {
            dockPopouts.hasCurrent = false;
            dockPopouts.currentName = "";
        }
    }

    // Focus grab needs the popup to be able to take keyboard focus.
    Binding {
        when: dockPopouts.currentName === "dockcontext"

        target: popWin
        property: "WlrLayershell.keyboardFocus"
        value: WlrKeyboardFocus.OnDemand
    }

    // --------------------------------------------------------------- winfo
    StyledWindow {
        id: winfoWin

        name: "dockwinfo"
        screen: root.modelData
        visible: root.winfoVisible
        exclusionMode: ExclusionMode.Ignore
        anchors {
            left: true
            bottom: true
        }
        margins {
            bottom: root.bottomMargin + dockWin.implicitHeight + root.popupGap
            left: Math.max(0, Math.min((root.modelData.width - winfoItem.implicitWidth) / 2, root.modelData.width - winfoItem.implicitWidth))
        }
        implicitWidth: winfoItem.implicitWidth
        implicitHeight: winfoItem.implicitHeight

        WinInfo.WindowInfo {
            id: winfoItem

            screen: root.modelData
            anchors.left: parent.left
            anchors.top: parent.top
            clientAddress: dockPopouts.selectedClientAddress
        }
    }

    HyprlandFocusGrab {
        id: winfoGrab

        windows: [winfoWin]
        active: winfoWin.visible
        onActiveChanged: {
            if (!active)
                root.winfoVisible = false;
        }
    }
}
