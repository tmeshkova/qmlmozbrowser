import Qt 4.7
import QtQuick 1.0

Item {
    id: root

    property bool contextInfoAvialable: false
    property variant viewport

    visible: false
    width: 300
    height: 300

    signal contextMenuRequested()
    signal selected()

    OverlayButton {
        id: goBack

        anchors.left: root.left
        anchors.top: parent.top
        anchors.topMargin: 100

        width: 100
        height: 100

        iconSource: "../icons/backward.png"
        enabled: viewport.child().canGoBack

        onClicked: {
            root.selected()
            viewport.child().goBack()
        }
    }

    OverlayButton {
        id: goForward

        anchors.right: root.right
        anchors.top: root.top
        anchors.topMargin: 100

        width: 100
        height: 100

        iconSource: "../icons/forward.png"
        enabled: viewport.child().canGoForward

        onClicked: {
            root.selected()
            viewport.child().goForward()
        }
    }

    OverlayButton {
        id: stopRefresh

        anchors.top: root.top
        anchors.left: root.left
        anchors.leftMargin: 100

        width: 100
        height: 100

        iconSource: viewport.child().loading ? "../icons/stop.png" : "../icons/refresh.png"

        onClicked: {
            //root.selected()
            if (viewport.child().loading) {
                viewport.child().stop()
            } else {
                viewport.child().reload()
            }
        }
    }

    OverlayButton {
        id: contextMenu

        anchors.bottom: root.bottom
        anchors.left: root.left
        anchors.leftMargin: 100

        width: 100
        height: 100

        iconSource: "../icons/menu.png"
        enabled: root.contextInfoAvialable

        onClicked: {
            root.contextMenuRequested()
        }
    }
}
