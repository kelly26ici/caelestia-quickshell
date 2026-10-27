pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.utils
import qs.modules.nexus.common
import qs.modules.dock as DockConfig

PageBase {
    id: root

    title: qsTr("Dock")
    isSubPage: true

    readonly property var dockOpts: DockConfig.Config.options.dock

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: qsTr("General")
        }

        ToggleRow {
            first: true
            text: qsTr("Enable dock")
            checked: root.dockOpts.enabled
            onToggled: root.dockOpts.enabled = checked
        }

        ToggleRow {
            text: qsTr("Reveal on hover")
            subtext: qsTr("Slide the dock in when the cursor touches the bottom edge. Disable to hide it completely.")
            checked: root.dockOpts.hoverToReveal
            onToggled: root.dockOpts.hoverToReveal = checked
        }

        ToggleRow {
            text: qsTr("Pin on startup")
            subtext: qsTr("Start with the dock kept visible")
            checked: root.dockOpts.pinnedOnStartup
            onToggled: root.dockOpts.pinnedOnStartup = checked
        }

        ToggleRow {
            text: qsTr("Monochrome icons")
            checked: root.dockOpts.monochromeIcons
            onToggled: root.dockOpts.monochromeIcons = checked
        }

        SectionHeader {
            text: qsTr("Layout")
        }

        StepperRow {
            first: true
            label: qsTr("Dock height")
            value: root.dockOpts.height
            from: 40
            to: 140
            onMoved: v => root.dockOpts.height = Math.round(v)
        }

        StepperRow {
            label: qsTr("Float height")
            subtext: qsTr("Gap between the dock and the bottom edge of the screen")
            value: root.dockOpts.bottomOffset
            from: 0
            to: 64
            onMoved: v => root.dockOpts.bottomOffset = Math.round(v)
        }

        StepperRow {
            label: qsTr("Hot region height")
            subtext: qsTr("Invisible strip at the bottom edge used to reveal the dock on hover")
            value: root.dockOpts.hoverRegionHeight
            from: 0
            to: 24
            onMoved: v => root.dockOpts.hoverRegionHeight = Math.round(v)
        }

        SectionHeader {
            text: qsTr("Pinned apps")
        }

        component AddAppRow: PopupRow {
            id: addRow

            readonly property int popupHeight: root.flickable.height - y + root.flickable.contentY - Tokens.padding.large - Tokens.padding.extraExtraLarge

            keepPopupAsChild: {
                if (!addRow.popup.open && addRow.popup.animDriver === 0)
                    return true;

                if (root.nState.animatingContainer || root.opacity < 1)
                    return true;

                let p = root.parent;
                while (p && p.objectName !== "PageContainer")
                    p = p.parent;
                return p ? (p.opacity < 1) : false;
            }
            popup.topMovement: Math.max(Tokens.sizes.nexus.minPopupHeight - popupHeight, Tokens.padding.large)

            first: true
            icon: "add"
            label: qsTr("Add app")
            status: qsTr("Search installed applications and pin them to the dock")

            Loader {
                anchors.centerIn: parent
                active: addRow.popup.animDriver > 0

                sourceComponent: VerticalFadeListView {
                    id: list

                    implicitWidth: Tokens.sizes.nexus.popupWidth
                    implicitHeight: CUtils.clamp(addRow.popupHeight, Tokens.sizes.nexus.minPopupHeight, Tokens.sizes.nexus.maxPopupHeight)

                    model: {
                        const apps = [...DesktopEntries.applications.values];
                        return apps.sort((a, b) => a.name.localeCompare(b.name));
                    }

                    delegate: StateLayer {
                        id: appItem

                        required property DesktopEntry modelData
                        required property int index

                        anchors.fill: undefined
                        anchors.left: list.contentItem.left
                        anchors.right: list.contentItem.right
                        implicitHeight: itemLayout.implicitHeight + itemLayout.anchors.margins * 2
                        radius: Tokens.rounding.small
                        disabled: root.dockOpts.pinnedApps.includes(appItem.modelData.id)

                        onClicked: {
                            addRow.popup.open = false;
                            root.dockOpts.pinnedApps = [...root.dockOpts.pinnedApps, appItem.modelData.id];
                        }

                        RowLayout {
                            id: itemLayout

                            anchors.fill: parent
                            anchors.margins: Tokens.padding.medium
                            spacing: Tokens.spacing.medium

                            IconImage {
                                asynchronous: true
                                implicitSize: Math.round(Tokens.font.icon.large.pointSize * 1.8)
                                source: Quickshell.iconPath(appItem.modelData.icon, "image-missing")
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                StyledText {
                                    Layout.fillWidth: true
                                    text: appItem.modelData.name
                                    font: Tokens.font.body.small
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    visible: text
                                    text: (appItem.modelData.comment || appItem.modelData.genericName) ?? ""
                                    color: Colours.palette.m3outline
                                    font: Tokens.font.label.small
                                    elide: Text.ElideRight
                                }
                            }

                            MaterialIcon {
                                visible: root.dockOpts.pinnedApps.includes(appItem.modelData.id)
                                text: "pin"
                                fill: 1
                                color: Colours.palette.m3primary
                                fontStyle: Tokens.font.icon.small
                            }
                        }
                    }
                }
            }
        }

        AddAppRow {}

        ListEditor {
            function labelFor(item: var): string {
                return DesktopEntries.byId(String(item))?.name ?? item;
            }

            function toggledFor(item: var): bool {
                return true;
            }

            z: 1
            values: root.dockOpts.pinnedApps
            onItemMoved: (from, to) => {
                const pins = [...root.dockOpts.pinnedApps];
                pins.splice(to, 0, pins.splice(from, 1)[0]);
                root.dockOpts.pinnedApps = pins;
            }
            onItemRemoved: index => {
                root.dockOpts.pinnedApps = root.dockOpts.pinnedApps.filter((_, i) => i !== index);
            }
            onItemToggled: (index, checked) => {
                // "Unchecking" an entry unpins it, matching the dock's
                // right-click behaviour.
                if (!checked)
                    root.dockOpts.pinnedApps = root.dockOpts.pinnedApps.filter((_, i) => i !== index);
            }
        }
    }
}
