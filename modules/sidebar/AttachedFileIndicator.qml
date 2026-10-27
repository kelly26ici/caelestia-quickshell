pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.services
import qs.utils

StyledRect {
    id: root

    signal remove()
    property string filePath: ""
    property string fileName: filePath ? filePath.split("/").pop() : ""
    property bool isImage: {
        var lower = fileName.toLowerCase();
        return lower.endsWith(".png") || lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".webp") || lower.endsWith(".gif");
    }

    visible: filePath !== ""
    implicitHeight: visible ? 52 : 0
    implicitWidth: chipRow.implicitWidth + Tokens.padding.large * 2
    color: Colours.palette.m3surfaceContainer
    radius: 12
    border.color: Colours.palette.m3outlineVariant
    border.width: 1

    RowLayout {
        id: chipRow
        anchors.fill: parent
        anchors.leftMargin: Tokens.padding.medium
        anchors.rightMargin: Tokens.padding.medium
        spacing: Tokens.spacing.small

        Item {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            Layout.alignment: Qt.AlignVCenter

            Image {
                anchors.fill: parent
                source: root.isImage ? Qt.resolvedUrl("file://" + root.filePath) : ""
                fillMode: Image.PreserveAspectCrop
                visible: root.isImage
                asynchronous: true
                mipmap: true
            }

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: Colours.palette.m3primaryContainer
                visible: !root.isImage

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "description"
                    font.pixelSize: 20
                    color: Colours.palette.m3onPrimaryContainer
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                text: root.fileName
                font: Tokens.font.label.large
                color: Colours.palette.m3onSurface
                elide: Text.ElideMiddle
                Layout.maximumWidth: 180
            }

            Text {
                text: root.isImage ? "Image attachment" : "File attached"
                font: Tokens.font.label.small
                color: Colours.palette.m3outline
            }
        }

        Item {
            Layout.preferredWidth: 26
            Layout.preferredHeight: 26
            Layout.alignment: Qt.AlignVCenter

            MaterialIcon {
                anchors.centerIn: parent
                text: "close"
                font.pixelSize: 18
                color: Colours.palette.m3onSurfaceVariant
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.remove()
            }
        }
    }
}
