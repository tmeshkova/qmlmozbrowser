import Qt 4.7
import QtMozilla 1.0
import QtQuick 1.1

FocusScope {
    id: mainScope
    objectName: "mainScope"

    anchors.fill: parent

    signal pageTitleChanged(string title)

    function load(address) {
        addressLine.text = address
        webViewport.child.load(address)
        overlayRightMenu.hide()
    }

    function saveFile(url) {
        var fileName = url.split("/")
        fileName = fileName[fileName.length - 1]
        var path = filePicker.getFileSync(1, QmlHelperTools.getStorageLocation(0), fileName)
        if (path != "")
            MozContext.sendObserve("embedui:download", { msg: "addDownload", from: url, to: path })
    }

    function addBookmark(url, title, group, type) {
        var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
        db.transaction(
            function(tx) {
                var result = tx.executeSql('delete from bookmarks where url=(?);',[url])
            }
        );
        db.transaction(
            function(tx) {
                var result = tx.executeSql('INSERT INTO bookmarks VALUES (?,?,?,?,?);',[url,title,QmlHelperTools.getFaviconFromUrl(url),group,type])
                if (result.rowsAffected < 1) {
                    console.log("Error inserting url")
                }
            }
        );
        bookmarksPage.fillModelFromDatabase()
        bookmarksPage.fillGroupsModel()
    }

    function removeBookmark(url) {
        var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
        db.transaction(
            function(tx) {
                var result = tx.executeSql('delete from bookmarks where url=(?);',[url])
            }
        );
        bookmarksPage.fillModelFromDatabase()
        bookmarksPage.fillGroupsModel()
    }

    Connections {
        target: MozContext
        onOnInitialized: {
            print("QmlMozContext Initialized");
            MozContext.sendObserve("embedui:setprefs", { prefs :
            [
                { n: "extensions.logging.enabled", v: true},
                { n: "extensions.strictCompatibility", v: false},
                { n: "dom.experimental_forms", v: true},
                { n: "xpinstall.whitelist.add", v: "addons.mozilla.org"},
                { n: "xpinstall.whitelist.add.180", v: "marketplace.firefox.com"},
                { n: "security.alternate_certificate_error_page", v: "certerror"},
                { n: "embedlite.azpc.handle.singletap", v: false},
                { n: "embedlite.azpc.json.singletap", v: true},
                { n: "embedlite.azpc.handle.longtap", v: false},
                { n: "embedlite.azpc.json.longtap", v: true},
                { n: "embedlite.azpc.json.viewport", v: true},
                { n: "browser.ui.touch.left", v: 32},
                { n: "browser.ui.touch.right", v: 32},
                { n: "browser.ui.touch.top", v: 48},
                { n: "browser.ui.touch.bottom", v: 16},
                { n: "browser.ui.touch.weight.visited", v: 120},
                { n: "browser.download.folderList", v: 2}, // 0 - Desktop, 1 - Downloads, 2 - Custom
                { n: "browser.download.useDownloadDir", v: false}, // Invoke filepicker instead of immediate download to ~/Downloads
                { n: "browser.download.manager.retention", v: 2},
                { n: "browser.helperApps.deleteTempFileOnExit", v: false},
                { n: "browser.download.manager.quitBehavior", v: 1},
                { n: "keyword.enabled", v: true}
            ]});
            MozContext.addObservers([
                "embed:download",
                "embed:prefs",
                "embed:allprefs",
                "clipboard:setdata",
                "embed:logger"
            ]);
            MozContext.sendObserve("embedui:logger", { enabled: true })
            // Need to expose flexible API and allow to choose different engines
            MozContext.sendObserve("embedui:search", {msg:"loadxml", uri:"chrome://embedlite/content/bing.xml", confirm: false})
        }
        onRecvObserve: {
            if (message == "clipboard:setdata") {
                QmlHelperTools.setClipboard(data.data);
            }
        }
    }

    QmlMozView {
        id: webViewport
        parentid: createParentID
        objectName: "webViewport"
        visible: true
        focus: true
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
            target: QGVWindow
            onDisplayEntered: {
                webViewport.child.suspendView();
            }
            onDisplayExited: {
                webViewport.child.resumeView();
            }
        }

        Connections {
            target: webViewport.child
            onViewInitialized: {
                print("QmlMozView Initialized");
                webViewport.child.loadFrameScript("chrome://embedlite/content/embedhelper.js");
                webViewport.child.loadFrameScript("chrome://embedlite/content/SelectHelper.js");
                webViewport.child.addMessageListeners([
                    "embed:filepicker",
                    "embed:permissions",
                    "embed:select",
                    "embed:login",
                    "chrome:linkadded",
                    "embed:alert",
                    "embed:confirm",
                    "embed:prompt",
                    "embed:auth",
                    "WebApps:PreInstall",
                    "WebApps:PostInstall",
                    "WebApps:Uninstall",
                    "WebApps:Open",
                    "Content:ContextMenu",
                    "Content:SelectionRange",
                    "Content:SelectionCopied"]);
                webViewport.child.useQmlMouse = true;
                print("QML View Initialized")
                if (startURL.length != 0 && createParentID == 0) {
                    load(startURL)
                }
                else if (createParentID == 0) {
                    load("about:blank")
                }
            }
            onBgColorChanged: {
                QmlHelperTools.setViewPaletteColor(QGVWindow, webViewport.child.bgcolor);
            }
            onLoadingChanged: {
                if (!webViewport.child.loading && webViewport.child.url == "about:blank") {
                    navigation.anchors.topMargin = 0
                    startPage.show()
                }
            }
            onHandleLongTap: {
                webViewport.child.sendAsyncMessage("embed:ContextMenuCreate", { x: point.x, y: point.y })
                navigation.anchors.topMargin = 0
                var posY = mapToItem(navigation, point.x, point.y).y - navigation.height/2
                if (posY < 0) {
                    posY = 10
                }
                else if (point.y + navigation.height/2 > mainScope.height) {
                    posY -= (point.y + navigation.height/2) - mainScope.height + 10
                }
                overlay.show(posY)
                // Way to forward context menu to UI
                webViewport.child.sendAsyncMessage("Gesture:ContextMenuSynth", { x: point.x, y: point.y })
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
                //print("onRecvAsyncMessage:" + message + ", data:" + data)
                switch (message) {
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
                    case "embed:permissions": {
                        print("grant permissions required: title:" + data.title + ", host:" + data.host + ", uid:" + data.id)
                        permissionsDlg.show(data.title, data.host, data.id)
                        break;
                    }
                    case "embed:login": {
                        print("login manager notification: name:" + data.name + ", bt1:" + data.buttons[0].label + ", bt2:" + data.buttons[1].label)
                        loginDlg.show(data.name, data.id)
                        break;
                    }
                    case "WebApps:PostInstall": {
                        break;
                    }
                    case "WebApps:Open": {
                        break;
                    }
                    case "WebApps:Uninstall": {
                        break;
                    }
                    case "Content:ContextMenu": {
                        contextMenu.contextLinkHref = data.linkURL
                        contextMenu.contextImageSrc = data.mediaURL
                        contextMenu.lastContextInfo = data;
                        if (data.types.indexOf("content-text") !== -1) {
                            contextMenu.selectionInfoAvialable = true;
                        } else {
                            contextMenu.selectionInfoAvialable = false;
                        }
                        break;
                    }
                    default:
                        break;
                    }
            }
            onRecvSyncMessage: {
                print("onRecvSyncMessage:" + message + ", data:" + data)
                switch (message) {
                case "embed:testsyncresponse":
                    response.message = {
                        val: "response",
                        numval: 0.04
                    }
                    break;
                case "embed:select":
                    response.message = {
                        button: selectCombo.showSync(data)
                    }
                    break;
                case "WebApps:PreInstall":
                    response.message = { path: "/tmp/webapps" };
                    break;
                }
            }
        }

        MouseArea {
            id: viewportMouse
            anchors.fill: parent
            onPressed: {
                webViewport.child.recvMousePress(mouseX, mouseY)
            }
            onReleased: {
                webViewport.child.recvMouseRelease(mouseX, mouseY)
                if (overlay.visible) {
                    addressLine.handleMouse(mouseX, mouseY)
                    rightTab.handleMouse(mouseX, mouseY)
                    navigation.handleMouse(mouseX, mouseY, true)
                }
                if (addressLine.inputFocus) {
                    addressLine.unfocusAddressBar()
                }
            }
            onPositionChanged: {
                if (!overlay.visible) {
                    webViewport.child.recvMouseMove(mouseX, mouseY)
                }
                else {
                    navigation.handleMouse(mouseX, mouseY, false)
                }
            }
        }

        PermissionsDialog {
            id: permissionsDlg
            onHandled: {
                webViewport.child.sendAsyncMessage("embedui:premissions", {
                                                        allow: permissionsDlg.accepted,
                                                        checkedDontAsk: permissionsDlg.dontAsk,
                                                        id: permissionsDlg.uid
                                                     })
            }
        }

        LoginDialog {
            id: loginDlg
            onHandled: {
                webViewport.child.sendAsyncMessage("embedui:login", {
                                                        buttonidx: loginDlg.accepted ? 0 : 1,
                                                        id: data.id
                                                     })
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
        anchors.top: addressLine.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        visible: false

        function show(posY) {
            navigation.anchors.topMargin = posY
            contextMenu.visible = false
            navigation.visible = true
            overlay.visible = true
        }

        function hide() {
            navigation.visible = false
            contextMenu.visible = false
            overlay.visible = false
        }

        MouseArea {
            anchors.fill: parent
            preventStealing: true
            onClicked: {
                addressLine.unfocusAddressBar()
                overlayRightMenu.hide()
                overlay.hide()
            }
            onPressAndHold: {
                navigation.anchors.topMargin = 0
                var posY = mapToItem(navigation, mouseX, mouseY).y - navigation.height/2
                if (posY < 0) {
                    posY = 10
                }
                else if (mouseY + navigation.height/2 > mainScope.height) {
                    posY -= (mouseY + navigation.height/2) - mainScope.height + 10
                }
                overlay.show(posY)
            }
        }

        OverlayContextMenu {
            id: contextMenu
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            width: Math.min(parent.width, parent.height) - 10

            onSelected: {
                overlay.hide()
            }

            onStartSelectionRequested: {
                if (contextMenu.lastContextInfo) {
                    webViewport.child.sendAsyncMessage("Browser:SelectionStart", {
                                                        xPos: contextMenu.lastContextInfo.xPos,
                                                        yPos: contextMenu.lastContextInfo.yPos
                                                      })
                    webViewport.child.sendAsyncMessage("Browser:SelectionMoveStart", {
                                                        change: "start"
                                                      })
                    selectionStart.x = contextMenu.lastContextInfo.xPos - 20
                    selectionStart.y = contextMenu.lastContextInfo.yPos - 20
                    selectionEnd.x = contextMenu.lastContextInfo.xPos - 20
                    selectionEnd.y = contextMenu.lastContextInfo.yPos - 20
                    selectionStart.visible = true
                    selectionEnd.visible = true
                }
            }
        }

        OverlayNavigation {
            id: navigation
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            contextInfoAvialable: contextMenu.contextLinkHref.length > 0 || contextMenu.contextImageSrc.length > 0

            onContextMenuRequested: {
                navigation.visible = false
                contextMenu.visible = true
            }

            onSelected : {
                overlay.hide()
            }
        }
    }

    AddressField {
        id: addressLine
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        visible: webViewport.child.loading || overlay.visible || inputFocus

        function handleMouse(ptX, ptY) {
            var mapped = mapFromItem(mainScope, ptX, ptY)
            if ((mapped.x > 0 && mapped.x < width) && (mapped.y > 0 && mapped.y < height)) {
                overlay.hide()
                addressLine.inputFocus = true
            }
        }

        onRecentTriggered: {
            navigation.visible = !showRecent
        }

        onAccepted: {
            overlay.hide()
        }
    }

    MouseArea {
        id: selectionArea
        x: Math.min(selectionStart.x, selectionEnd.x)
        y: Math.min(selectionStart.y, selectionEnd.y)
        width: Math.abs(selectionStart.x - selectionEnd.x)
        height: Math.abs(selectionStart.y - selectionEnd.y)
        enabled: selectionStart.visible
        function updateSelection() {
            webViewport.child.sendAsyncMessage("Browser:SelectionMove", {
                                                change: "start",
                                                start: {
                                                    xPos: selectionArea.x + 20,
                                                    yPos: selectionArea.y + 20
                                                }
                                              })

            webViewport.child.sendAsyncMessage("Browser:SelectionMove", {
                                                change: "end",
                                                end: {
                                                    xPos: selectionArea.x + selectionArea.width + 20,
                                                    yPos: selectionArea.y + selectionArea.height + 20
                                                }
                                              })
        }
        onClicked: {
            webViewport.child.sendAsyncMessage("Browser:SelectionCopy", {
                                                xPos: selectionArea.x + 20,
                                                yPos: selectionArea.y + 20
                                              })
            webViewport.child.sendAsyncMessage("Browser:SelectionClose", {
                                                clearSelection: true
                                              })
            selectionStart.visible = false
            selectionEnd.visible = false
        }
    }

    Rectangle {
        id: selectionStart
        visible: false
        color: "transparent"
        width: 40
        height: 40
        radius: 20
        border.width: 1
        border.color: "red"
        smooth: true
        MouseArea {
            anchors.fill: parent
            onPositionChanged: {
                var mapped = mapToItem(mainScope, mouseX, mouseY)
                selectionStart.x = mapped.x - 20
                selectionStart.y = mapped.y - 80
                if (selectionStart.x < 0)
                    selectionStart.x = 0
                if (selectionStart.y < 0)
                    selectionStart.y = 0
                selectionArea.updateSelection()
            }
        }
    }

    Rectangle {
        id: selectionEnd
        visible: false
        color: "transparent"
        width: 40
        height: 40
        radius: 20
        border.width: 1
        border.color: "green"
        smooth: true
        MouseArea {
            anchors.fill: parent
            onPositionChanged: {
                var mapped = mapToItem(mainScope, mouseX, mouseY)
                selectionEnd.x = mapped.x - 20
                selectionEnd.y = mapped.y - 80
                if (selectionEnd.x < 0)
                    selectionEnd.x = 0
                if (selectionEnd.y < 0)
                    selectionEnd.y = 0
                selectionArea.updateSelection()
            }
        }
    }

    StartPage {
        id: startPage
        width: parent.width
        height: parent.height
    }

    Rectangle {
        id: rightTab
        anchors.top: parent.top
        anchors.topMargin: overlay.visible ? addressLine.height : startPage.topArea
        anchors.bottom: parent.bottom
        anchors.right: overlayRightMenu.left
        anchors.rightMargin: -5
        border.width: 1
        border.color: "black"
        radius: 5
        color: "white"
        width: 55
        visible: navigation.visible || startPage.visible
        function handleMouse(ptX, ptY) {
            var mapped = mapFromItem(mainScope, ptX, ptY)
            if ((mapped.x > 0 && mapped.x < width) && (mapped.y > 0 && mapped.y < height)) {
                overlayRightMenu.toggle()
            }
        }
        Image {
            anchors.centerIn: parent
            width: 40
            height: 40
            smooth: true
            source: "../icons/nav-" + (overlayRightMenu.anchors.rightMargin == 0 ? "forward" : "backward") + ".png"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                overlayRightMenu.toggle()
            }
        }
    }

    OverlayRightMenu {
        id: overlayRightMenu
        height: parent.height
        anchors.top: parent.top
        anchors.topMargin: overlay.visible ? addressLine.height : startPage.topArea
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: -111
    }

    Settings {
        id: settingsPage
        width: parent.width
        height: parent.height
        x: parent.width
    }

    Downloads {
        id: downloadsPage
        width: parent.width
        height: parent.height
        x: parent.width
    }

    Config {
        id: configPage
        width: parent.width
        height: parent.height
        x: parent.width
    }

    History {
        id: historyPage
        width: parent.width
        height: parent.height
        x: parent.width
    }

    Bookmarks {
        id: bookmarksPage
        width: parent.width
        height: parent.height
        x: parent.width
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

    Selection {
        id: selectCombo
        anchors.fill: parent
    }

    Keys.onPressed: {
        if (((event.modifiers & Qt.ControlModifier) && event.key == Qt.Key_L)
                || event.key == Qt.key_F6) {
            addressLine.focusAddressBar()
            event.accepted = true
        }
    }
}
