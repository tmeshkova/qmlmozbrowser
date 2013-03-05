import Qt 4.7
import QtMozilla 1.0
import QtQuick 1.0

FocusScope {
    id: mainScope
    objectName: "mainScope"

    anchors.fill: parent

    signal pageTitleChanged(string title)

    function load(address) {
        addressLine.text = address
        webViewport.child().load(address)
    }

    QmlMozContext { id: mozContext }

    QmlMozView {
        id: webViewport
        parentid: createParentID
        objectName: "webViewport"
        visible: true
        focus: true
        enabled: !(alertDlg.visible || confirmDlg.visible || promptDlg.visible || authDlg.visible || overlay.visible || settingsPage.visible)
        property bool movingHorizontally: false
        property bool movingVertically: true
        property variant visibleArea: QtObject {
            property real yPosition: 0
            property real xPosition: 0
            property real widthRatio: 0
            property real heightRatio: 0
        }

        function scrollTimeout() {
            webViewport.movingHorizontally = false
            webViewport.movingVertically = false
        }
        Timer {
            id: scrollTimer
            interval: 500
            running: false
            repeat: false
            onTriggered: webViewport.scrollTimeout()
        }

        anchors.fill: parent

        Connections {
            target: webViewport.child()
            onViewInitialized: {
                mozContext.setPref("browser.ui.touch.left", 32);
                mozContext.setPref("browser.ui.touch.right", 32);
                mozContext.setPref("browser.ui.touch.top", 48);
                mozContext.setPref("browser.ui.touch.bottom", 16);
                mozContext.setPref("browser.ui.touch.weight.visited", 120);
                webViewport.child().loadFrameScript("chrome://embedlite/content/embedhelper.js");
                webViewport.child().addMessageListener("embed:alert");
                webViewport.child().addMessageListener("embed:prompt");
                webViewport.child().addMessageListener("embed:confirm");
                webViewport.child().addMessageListener("embed:auth");
                webViewport.child().addMessageListener("chrome:title")
                webViewport.child().addMessageListener("context:info")
                print("QML View Initialized")
                if (startURL.length != 0 && createParentID == 0) {
                    load(startURL)
                }
            }
            onLoadingChanged: {
                var isLoading = webViewport.child().loading
                if (isLoading && !overlay.visible) {
                    overlay.showAddressBar()
                }
                else if (!isLoading && overlay.visible && !navigation.visible && !contextMenu.visible &&!addressLine.inputFocus) {
                    overlay.hide()
                }
            }
            onHandleLongTap: {
                if ((point.y - navigation.height / 2) < addressLine.height)
                    overlay.show(addressLine.height + navigation.height / 2)
                else if ((point.y + navigation.height / 2) > mainScope.height)
                    overlay.show(mainScope.height - navigation.height)
                else
                    overlay.show(point.y - navigation.height / 2)
            }
            onViewAreaChanged: {
                var r = webViewport.child().contentRect
                var offset = webViewport.child().scrollableOffset
                var s = webViewport.child().scrollableSize
                webViewport.visibleArea.widthRatio = r.width / s.width
                webViewport.visibleArea.heightRatio = r.height / s.height
                webViewport.visibleArea.xPosition = offset.x
                        * webViewport.visibleArea.widthRatio
                        * webViewport.child().resolution
                webViewport.visibleArea.yPosition = offset.y
                        * webViewport.visibleArea.heightRatio
                        * webViewport.child().resolution
                webViewport.movingHorizontally = true
                webViewport.movingVertically = true
                scrollTimer.restart()
            }
            onTitleChanged: {
                pageTitleChanged(webViewport.child().title)
            }
            onRecvAsyncMessage: {
                print("onRecvAsyncMessage:" + message + ", data:" + data)
                if (message == "context:info") {
                    contextMenu.contextLinkHref = data.LinkHref
                    contextMenu.contextImageSrc = data.ImageSrc
                    navigation.contextInfoAvialable = (contextMenu.contextLinkHref.length > 0 || contextMenu.contextImageSrc.length > 0)

                }
            }
            onRecvSyncMessage: {
                print("onRecvSyncMessage:" + message + ", data:" + data)
                if (message == "embed:testsyncresponse") {
                    response.message = {
                        val: "response",
                        numval: 0.04
                    }
                }
            }
            onAlert: {
                print("onAlert: title:" + data.title + ", msg:" + data.text + " winid:" + data.winid)
                alertDlg.show(data.title, data.text, data.winid)
            }
            onConfirm: {
                print("onConfirm: title:" + data.title + ", data.text:" + data.text)
                confirmDlg.show(data.title, data.text, data.winid)
            }
            onPrompt: {
                print("onPrompt: title:" + data.title + ", msg:" + data.text)
                promptDlg.show(data.title, data.text, data.defaultValue, data.winid)
            }
            onAuthRequired: {
                print("onAuthRequired: title:" + data.title + ", msg:" + data.text + ", winid:" + data.winid)
                authDlg.show(data.title, data.text, data.defaultValue, data.winid)
            }
        }

        AlertDialog {
            id: alertDlg
            onHandled: {
                webViewport.child().sendAsyncMessage("alertresponse", {
                                                         winid: winid,
                                                         checkval: alertDlg.checkval,
                                                         accepted: alertDlg.accepted
                                                     })
            }
        }

        ConfirmDialog {
            id: confirmDlg
            onHandled: {
                webViewport.child().sendAsyncMessage("confirmresponse", {
                                                         winid: winid,
                                                         checkval: confirmDlg.checkval,
                                                         accepted: confirmDlg.accepted
                                                     })
            }
        }

        PromptDialog {
            id: promptDlg
            onHandled: {
                webViewport.child().sendAsyncMessage("promptresponse", {
                                                         winid: winid,
                                                         checkval: promptDlg.checkval,
                                                         accepted: promptDlg.accepted,
                                                         promptvalue: promptDlg.prompttext
                                                     })
            }
        }

        AuthenticationDialog {
            id: authDlg
            onHandled: {
                webViewport.child().sendAsyncMessage("authresponse", {
                                                         winid: winid,
                                                         checkval: authDlg.checkval,
                                                         accepted: authDlg.accepted,
                                                         username: authDlg.username,
                                                         password: authDlg.password
                                                     })
            }
        }

        ScrollIndicator {
            id: scrollIndicator
            flickableItem: webViewport
        }
    }

    Item {
        id: overlay
        anchors.fill: mainScope
        visible: false

        function show(posY) {
            navigation.anchors.topMargin = posY
            overlay.visible = true
            contextMenu.visible = false
            navigation.visible = true
        }

        function showAddressBar() {
            navigation.visible = false
            contextMenu.visible = false
            overlay.visible = true
        }

        function hide() {
            overlay.visible = false
        }

        MouseArea {
            anchors.fill: parent
            onPressed: {
                addressLine.unfocusAddressBar()
                overlay.visible = false
            }
        }

        AddressField {
            id: addressLine
            viewport: webViewport
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            onAccepted: {
                overlay.hide()
            }
        }

        OverlayContextMenu {
            id: contextMenu
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            width: Math.min(parent.width, parent.height) - 10
            context: mozContext

            onSelected: {
                overlay.hide()
            }
        }

        OverlayNavigation {
            id: navigation
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            viewport: webViewport

            onContextMenuRequested: {
                contextMenu.visible = true
                navigation.visible = false
            }

            onSelected: {
                overlay.hide()
            }
        }

        OverlayButton {
            id: newPage

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.topMargin: addressLine.height + 10

            width: 100
            height: 100

            visible: navigation.visible

            iconSource: "../icons/plus.png"

            onClicked: {
                mozContext.newWindow()
                overlay.hide()
            }
        }

        OverlayButton {
            id: settings

            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.topMargin: addressLine.height + 10

            width: 100
            height: 100

            visible: navigation.visible

            iconSource: "../icons/settings.png"

            onClicked: {
                overlay.hide()
                settingsPage.show()
            }
        }
    }

    Settings {
        id: settingsPage
        anchors.fill: parent
        context: mozContext
    }

    Keys.onPressed: {
        if (((event.modifiers & Qt.ControlModifier) && event.key == Qt.Key_L)
                || event.key == Qt.key_F6) {
            addressLine.focusAddressBar()
            event.accepted = true
        }
    }
}
