pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root

    property string id: ""
    property string role: "user" // user | assistant | tool
    property string text: ""
    property string thoughtText: ""
    property bool isFinished: true
    property string attachedFilePath: ""
    property string attachedFileBase64: ""
    property var toolCalls: []
    property string toolCallId: ""
    property string toolName: ""
    property string toolResult: ""
}
