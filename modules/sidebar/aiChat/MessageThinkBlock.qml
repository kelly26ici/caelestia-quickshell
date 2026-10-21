pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia
import qs.components

StyledRect {
    id: root

    property string thoughtText: ""
    property bool isStreaming: false
    property bool expanded: false

    radius: 12
    color: Colours.palette.m3surfaceContainer
    border.width: 1
    border.color: Colours.palette.m3outlineVariant
    implicitHeight: col.implicitHeight + Tokens.padding.small * 2

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: Tokens.padding.small
        spacing: 4

        RowLayout {
            Layout.fillWidth: true

            Icon {
                name: "psychology"
                size: 16
                color: Colours.palette.m3primary
            }

            Text {
                text: root.isStreaming ? "Thinking..." : "Thought process"
                font: Tokens.font.label.medium
                color: Colours.palette.m3primary
                Layout.fillWidth: true
            }

            IconButton {
                icon: root.expanded ? "expand_less" : "expand_more"
                iconSize: 16
                implicitWidth: 24
                implicitHeight: 24
                onClicked: root.expanded = !root.expanded
            }
        }

        Text {
            visible: root.expanded
            text: root.thoughtText
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }
    }
}
