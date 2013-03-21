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
        webViewport.child.load(address)
    }

    QmlMozContext { id: mozContext }

    function saveFile(url) {
        var fileName = url.split("/")
        fileName = fileName[fileName.length - 1]
        var path = filePicker.getFileSync(1, QmlHelperTools.getStorageLocation(0), fileName)
        if (path != "")
            mozContext.child.sendObserve("embedui:download", { msg: "addDownload", from: url, to: path })
    }

    Connections {
        target: mozContext.child
        onOnInitialized: {
            print("QmlMozContext Initialized");
            mozContext.setPref("browser.download.manager.retention", 2);
            mozContext.setPref("browser.ui.touch.left", 32);
            mozContext.setPref("browser.ui.touch.right", 32);
            mozContext.setPref("browser.ui.touch.top", 48);
            mozContext.setPref("browser.ui.touch.bottom", 16);
            mozContext.setPref("browser.ui.touch.weight.visited", 120);
            mozContext.setPref("browser.download.folderList", 2); // 0 - Desktop, 1 - Downloads, 2 - Custom
            mozContext.setPref("browser.download.useDownloadDir", false); // Invoke filepicker instead of immediate download to ~/Downloads
            mozContext.setPref("browser.download.manager.retention", 2);
            mozContext.child.addObserver("embed:download");
            mozContext.child.sendObserve("embedui:download", { msg: "requestDownloadsList" })
        }
    }

    QmlMozView {
        id: webViewport
        parentid: createParentID
        objectName: "webViewport"
        visible: true
        focus: true
        enabled: !(alertDlg.visible || confirmDlg.visible || promptDlg.visible || authDlg.visible || overlay.visible || settingsPage.x==0 || downloadsPage.x==0 || filePicker.visible)
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
            target: webViewport.child
            onViewInitialized: {
                webViewport.child.loadFrameScript("chrome://embedlite/content/embedhelper.js");
                webViewport.child.addMessageListener("embed:filepicker");
                webViewport.child.addMessageListener("context:info");
                print("QML View Initialized")
                if (startURL.length != 0 && createParentID == 0) {
                    load(startURL)
                }
                else if (createParentID == 0) {
                    load("about:blank")
                }
            }
            onLoadingChanged: {
                var isLoading = webViewport.child.loading
                if (isLoading && !overlay.visible) {
                    overlay.showAddressBar()
                }
                else if (!isLoading && overlay.visible && !navigation.visible && !contextMenu.visible && !addressLine.inputFocus && !filePicker.visible) {
                    overlay.hide()
                }
            }
            onHandleLongTap: {
                navigation.anchors.topMargin = 0
                var posY = mapToItem(navigation, point.x, point.y).y - navigation.height/2
                if (posY < 0) {
                    posY = 10
                }
                else if (point.y + navigation.height/2 > mainScope.height) {
                    posY -= (point.y + navigation.height/2) - mainScope.height + 10
                }
                overlay.show(posY)
            }
            onViewAreaChanged: {
                var r = webViewport.child.contentRect
                var offset = webViewport.child.scrollableOffset
                var s = webViewport.child.scrollableSize
                webViewport.visibleArea.widthRatio = r.width / s.width
                webViewport.visibleArea.heightRatio = r.height / s.height
                webViewport.visibleArea.xPosition = offset.x
                        * webViewport.visibleArea.widthRatio
                        * webViewport.child.resolution
                webViewport.visibleArea.yPosition = offset.y
                        * webViewport.visibleArea.heightRatio
                        * webViewport.child.resolution
                webViewport.movingHorizontally = true
                webViewport.movingVertically = true
                scrollTimer.restart()
            }
            onTitleChanged: {
                pageTitleChanged(webViewport.child.title)
            }
            onRecvAsyncMessage: {
                print("onRecvAsyncMessage:" + message + ", data:" + data)
                switch (message) {
                    case "context:info": {
                        contextMenu.contextLinkHref = data.LinkHref
                        contextMenu.contextImageSrc = data.ImageSrc
                        navigation.contextInfoAvialable = (contextMenu.contextLinkHref.length > 0 || contextMenu.contextImageSrc.length > 0)
                        break;
                    }
                    case "embed:filepicker": {
                        filePicker.show(data.mode, QmlHelperTools.getStorageLocation(0), data.title, data.name, data.winid)
                        break;
                    }
                    case "embed:alert": {
                        print("onAlert: title:" + data.title + ", msg:" + data.text + " winid:" + data.winid)
                        alertDlg.show(data.title, data.text, data.winid)
                        break;
                    }
                    case "embed:confirm": {
                        print("onConfirm: title:" + data.title + ", data.text:" + data.text)
                        confirmDlg.show(data.title, data.text, data.winid)
                        break;
                    }
                    case "embed:prompt": {
                        print("onPrompt: title:" + data.title + ", msg:" + data.text)
                        promptDlg.show(data.title, data.text, data.defaultValue, data.winid)
                        break;
                    }
                    case "embed:auth": {
                        print("onAuthRequired: title:" + data.title + ", msg:" + data.text + ", winid:" + data.winid)
                        authDlg.show(data.title, data.text, data.defaultValue, data.winid)
                        break;
                    }
                    default:
                        break;
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
        }

        AlertDialog {
            id: alertDlg
            onHandled: {
                webViewport.child.sendAsyncMessage("alertresponse", {
                                                         winid: winid,
                                                         checkval: alertDlg.checkval,
                                                         accepted: alertDlg.accepted
                                                     })
            }
        }

        ConfirmDialog {
            id: confirmDlg
            onHandled: {
                webViewport.child.sendAsyncMessage("confirmresponse", {
                                                         winid: winid,
                                                         checkval: confirmDlg.checkval,
                                                         accepted: confirmDlg.accepted
                                                     })
            }
        }

        PromptDialog {
            id: promptDlg
            onHandled: {
                webViewport.child.sendAsyncMessage("promptresponse", {
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
                webViewport.child.sendAsyncMessage("authresponse", {
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
        visible: opacity > 0.01
        opacity: 0.01

        function show(posY) {
            buttonsHide.running = false
            navigation.anchors.topMargin = posY
            contextMenu.visible = false
            navigation.visible = true
            buttonsShow.running = true
        }

        function showAddressBar() {
            addressLine.visible = true
            navigation.visible = false
            contextMenu.visible = false
            buttonsShow.running = true
        }

        function hide() {
            buttonsShow.running = false
            buttonsHide.running = true
        }

        function hideExceptBar() {
            buttonsHide.running = false
            buttonsShow.running = false
            navigation.visible = false
            contextMenu.visible = false
        }

        PropertyAnimation {
            id: buttonsHide
            target: overlay
            properties: "opacity"
            from: 1.0; to: 0.01; duration: 300;
            running: false
        }

        PropertyAnimation {
            id: buttonsShow
            target: overlay
            properties: "opacity"
            from: 0.01; to: 1.0; duration: 300;
            running: false
        }

        PropertyAnimation {
            id: menuHide
            target: contextMenu
            properties: "anchors.bottomMargin"
            from: 5; to: 5-contextMenu.height; duration: 300
            running: false
        }

        PropertyAnimation {
            id: menuShow
            target: contextMenu
            properties: "anchors.bottomMargin"
            from: 5-contextMenu.height; to: 5; duration: 300
            running: false
        }

        MouseArea {
            anchors.fill: parent
            onPressed: {
                addressLine.unfocusAddressBar()
                overlay.hide()
            }
        }

        AddressField {
            id: addressLine
            viewport: webViewport
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            onAccepted: {
                overlay.hideExceptBar()
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
                menuHide.running = true
                overlay.hide()
            }
        }

        OverlayNavigation {
            id: navigation
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: addressLine.bottom
            viewport: webViewport

            onContextMenuRequested: {
                navigation.visible = false
                menuShow.running = true
                contextMenu.visible = true
            }

            onSelected: {
                overlay.hideExceptBar()
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

        OverlayButton {
            id: downloads

            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.bottomMargin: 10

            width: 100
            height: 100

            visible: navigation.visible

            iconSource: "../icons/download.png"

            onClicked: {
                overlay.hide()
                downloadsPage.show()
            }
        }
    }

    Settings {
        id: settingsPage
        width: parent.width
        height: parent.height
        x: parent.width
        context: mozContext
    }

    Downloads {
        id: downloadsPage
        width: parent.width
        height: parent.height
        x: parent.width
        context: mozContext
    }

    FilePicker {
        id: filePicker
        anchors.fill: parent
        onSelected: {
            filePicker.visible = false
            console.log("FilePicker selected: " + path + " accepted: " + accepted)
            webViewport.child.sendAsyncMessage("filepickerresponse", {
                                                         winid: winid,
                                                         accepted: accepted,
                                                         items: path
                                                     })
        }
    }

    Keys.onPressed: {
        if (((event.modifiers & Qt.ControlModifier) && event.key == Qt.Key_L)
                || event.key == Qt.key_F6) {
            addressLine.focusAddressBar()
            event.accepted = true
        }
    }
}
