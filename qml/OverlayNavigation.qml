import QtQuick 1.0

Item {
    id: root

    property bool contextInfoAvialable: false

    visible: false
    width: 300
    height: 300

    signal contextMenuRequested()
    signal selected()

    function clearHighlight() {
        goBack.forceHighlight = false
        goForward.forceHighlight = false
        stopRefresh.forceHighlight = false
        contextMenu.forceHighlight = false
    }

    function handleMouse(ptX, ptY, released) {
        var mapped = mapFromItem(mainScope, ptX, ptY)
        var item = root.childAt(mapped.x, mapped.y)
        if (item) {
            if (!released) {
                item.forceHighlight = true
            }
            else {
                item.clicked()
                clearHighlight()
            }
        }
        else {
            clearHighlight()
            if (released && overlayRightMenu.anchors.rightMargin != 0) {
                root.selected()
            }
        }
    }

    OverlayButton {
        id: goBack

        anchors.left: root.left
        anchors.top: parent.top
        anchors.topMargin: 100

        width: 100
        height: 100

        iconSource: "../icons/backward.png"
        enabled: webViewport.child.canGoBack

        onClicked: {
            root.selected()
            webViewport.child.goBack()
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
        enabled: webViewport.child.canGoForward

        onClicked: {
            root.selected()
            webViewport.child.goForward()
        }
    }

    OverlayButton {
        id: stopRefresh

        anchors.top: root.top
        anchors.left: root.left
        anchors.leftMargin: 100

        width: 100
        height: 100

        iconSource: webViewport.child.loading ? "../icons/stop.png" : "../icons/refresh.png"

        onClicked: {
            root.selected()
            if (webViewport.child.loading) {
                webViewport.child.stop()
            } else {
                webViewport.child.reload()
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
        //enabled: root.contextInfoAvialable

        onClicked: {
            root.contextMenuRequested()
        }
    }
}
