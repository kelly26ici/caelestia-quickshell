pragma ComponentBehavior: Bound

import QtQuick
import Caelestia
import Caelestia.Config
import qs.components

Item {
    id: root

    required property ScreenState screenState
    property var popouts
    property var utilities
    readonly property Props props: Props {}

    readonly property bool shouldBeActive: screenState.sidebar && Config.sidebar.enabled
    property real offsetScale: shouldBeActive ? 0 : 1

    visible: offsetScale < 0.999
    property real slideAmount: (-implicitWidth - Config.border.thickness - Tokens.spacing.medium) * offsetScale
    anchors.leftMargin: slideAmount
    anchors.rightMargin: slideAmount

    // Extend width toggle (Ctrl+O)
    property bool isExtended: false
    implicitWidth: isExtended ? Math.min(screen ? screen.width * 0.48 : 680, 720) : Tokens.sizes.sidebar.width

    Behavior on implicitWidth {
        Anim {
            type: Anim.DefaultSpatial
        }
    }

    opacity: Math.min(1, Math.pow(Math.max(0, 1 - offsetScale), 2))

    Behavior on offsetScale {
        Anim {
            type: Anim.SlowSpatial
        }
    }

    property bool isStreaming: false

    Loader {
        id: content

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: Tokens.padding.large
        anchors.margins: CUtils.clamp(anchors.leftMargin - Config.border.thickness, 0, anchors.leftMargin)
        anchors.bottomMargin: 0

        active: root.shouldBeActive || root.visible || root.isStreaming

        sourceComponent: Content {
            implicitWidth: root.implicitWidth - content.anchors.leftMargin - content.anchors.margins
            props: root.props
            screenState: root.screenState
            popouts: root.popouts
            utilities: root.utilities
            onSidebarStreamingChanged: root.isStreaming = sidebarStreaming
        }
    }
}
