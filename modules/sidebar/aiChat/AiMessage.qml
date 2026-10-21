pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia
import qs.components

Item {
    id: root

    property string role: "user"
    property string text: ""
    property string thought: ""
    property bool isThinking: false
    property bool isFinished: true
    property var attachedFile: null

    implicitHeight: bubbleCol.implicitHeight + Tokens.spacing.medium
    width: parent ? parent.width : 360

    ColumnLayout {
        id: bubbleCol
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spacing.small

        // Thought block (collapsible)
        MessageThinkBlock {
            visible: root.thought.length > 0
            thoughtText: root.thought
            isStreaming: root.isThinking
            Layout.fillWidth: true
        }

        // Message body
        StyledRect {
            Layout.fillWidth: true
            Layout.maximumWidth: parent.width * 0.95
            Layout.alignment: root.role === "user" ? Qt.AlignRight : Qt.AlignLeft
            radius: 16
            color: root.role === "user" ? Colours.palette.m3primary : Colours.palette.m3surfaceContainerHigh
            border.width: root.role === "user" ? 0 : 1
            border.color: Colours.palette.m3outlineVariant

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.padding.medium
                spacing: Tokens.spacing.small

                Text {
                    text: root.text
                    color: root.role === "user" ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                    font: Tokens.font.body.medium
                    wrapMode: Text.Wrap
                    textFormat: Text.MarkdownText
                    Layout.fillWidth: true
                }
            }
        }
    }
}
