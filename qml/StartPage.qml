import QtMozilla 1.0
import QtQuick 1.1

Rectangle {
    id: root
    color: "white"
    visible: false
    property int topArea: address.height + 16 + recentSitesList.height + hideRecent.height
    property bool showRecent: false

    function getRecentCount(count) {
        var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
        db.transaction(
            function(tx) {
                var result = tx.executeSql('select * from history order by date desc limit (?)', count)
                recentListModel.clear()
                for (var i=result.rows.length; i > 0; i--) {
                    recentListModel.insert(0, {"url": result.rows.item(i-1).url,
                                     "title": result.rows.item(i-1).title,
                                     "icon": result.rows.item(i-1).icon})
                }
            }
        );
    }

    function getStartPageBookmarks() {
        var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
        db.transaction(
            function(tx) {
                var result = tx.executeSql('SELECT * FROM bookmarks where type=1 order by category desc')
                bookmarksListModel.clear()
                for (var i=0; i < result.rows.length; i++) {
                    bookmarksListModel.insert(0, {"url": result.rows.item(i).url,
                                                  "title": result.rows.item(i).title,
                                                  "icon": result.rows.item(i).icon,
                                                  "group": result.rows.item(i).category,
                                                  "type": parseInt(result.rows.item(i).type)})
                }
            }
        );
    }

    function show() {
        getRecentCount(10)
        getStartPageBookmarks()
        overlay.hide()
        root.visible = true
    }

    function hide() {
        address.setFocus(false)
        root.visible = false
    }

    function hideRecentList() {
        root.showRecent = false
        recentSitesList.height = 0
        root.recentTriggered()
    }

    function fillRecentFromDatabase(value) {
        var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
        db.transaction(
            function(tx) {
                var result = tx.executeSql('SELECT url, title, icon FROM history where url like (?) order by date desc limit 5',["%" + value + "%"])
                addressListModel.clear()
                for (var i=0; i < result.rows.length; i++) {
                    addressListModel.insert(0, {"url": result.rows.item(i).url,
                                     "title": result.rows.item(i).title,
                                     "icon": result.rows.item(i).icon})
                }
            }
        );
    }

    Connections {
        target: webViewport.child

        onUrlChanged: {
            address.text = webViewport.child.url;
            address.cursorPosition = 0;
        }
    }

    Connections {
        target: bookmarksPage

        onBookmarksChanged: {
            getStartPageBookmarks()
        }
    }

    ListModel {
        id: bookmarksListModel
    }

    ListModel {
        id: recentListModel
    }

    InputArea {
        id: address
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5
        inputMethodHints: Qt.ImhNoPredictiveText || Qt.ImhNoAutoUppercase
        selectAllOnFocus: true
        onAccepted: {
            load(text)
            root.hide()
        }
        onTextChanged: {
            if (inputFocus) {
                fillRecentFromDatabase(text)
                root.showRecent = (addressListModel.count > 0)
                if (addressListModel.count > 0) {
                    var url0 = addressListModel.get(0).url
                    if (url0.search(text) == 0) {
                        address.setUrl(url0)
                    }
                }
                if (addressListModel.count > 4) {
                    recentSitesList.height = 200
                }
                else {
                    recentSitesList.height = (50 * addressListModel.count)
                }
            }
        }
    }

    Text {
        id: bookmarksTitle
        text: "Pinned bookmarks"
        font.pixelSize: 26
        anchors.top: address.bottom
        anchors.left: root.left
        anchors.right: root.right
        anchors.margins: 5        
    }

    ListView {
        id: bookmarksList
        anchors.top: bookmarksTitle.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5
        height: (parent.height - address.height - bookmarksTitle.height - recentTitle.height - 20) / 2
        clip: true
        model: bookmarksListModel
        delegate: Item {
            width: parent.width
            height: 60
            Rectangle {
                anchors.fill: parent
                color: mArea.pressed ? "#f0f0f0" : "transparent"
            }
            Image {
                id: siteIcon
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 3
                source: model.icon ? (testIcon.status == Image.Error ? QmlHelperTools.getFaviconFromUrl(model.url) : model.icon) : QmlHelperTools.getFaviconFromUrl(model.url)
                width: 20
                height: 20
                smooth: true
                cache: true
            }
            Image {
                id: testIcon
                visible: false
                source: model.icon
            }
            Text {
                id: siteLabel
                anchors.top: parent.top
                anchors.topMargin: 3
                anchors.left: siteIcon.right
                anchors.leftMargin: 10
                text: model.title
                font.pixelSize: 18
            }
            Text {
                id: siteUrl
                anchors.top: siteLabel.bottom
                anchors.topMargin: 1
                anchors.left: siteIcon.right
                anchors.leftMargin: 10
                text: "<a href=\"" + model.url + "\">" + model.url + "</a>"
                font.pixelSize: 18
            }
            MouseArea {
                id: mArea
                anchors.fill: parent
                onClicked: {
                    load(model.url)
                    root.hide()
                }
            }
        }
    }

    Text {
        id: recentTitle
        text: "Recent sites"
        font.pixelSize: 26
        anchors.top: bookmarksList.bottom
        anchors.topMargin: 5
        anchors.left: root.left
        anchors.right: root.right
        anchors.margins: 5
    }

    ListView {
        id: recentList
        anchors.top: recentTitle.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5
        height: (parent.height - address.height - bookmarksTitle.height - recentTitle.height - 20) / 2
        clip: true
        model: recentListModel
        delegate: Item {
            width: parent.width
            height: 60
            Rectangle {
                anchors.fill: parent
                color: mArea.pressed ? "#f0f0f0" : "transparent"
            }
            Image {
                id: siteIcon
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 3
                source: model.icon ? (testIcon.status == Image.Error ? QmlHelperTools.getFaviconFromUrl(model.url) : model.icon) : QmlHelperTools.getFaviconFromUrl(model.url)
                width: 20
                height: 20
                smooth: true
                cache: true
            }
            Image {
                id: testIcon
                visible: false
                source: model.icon
            }
            Text {
                id: siteLabel
                anchors.top: parent.top
                anchors.topMargin: 3
                anchors.left: siteIcon.right
                anchors.leftMargin: 10
                text: model.title
                font.pixelSize: 18
            }
            Text {
                id: siteUrl
                anchors.top: siteLabel.bottom
                anchors.topMargin: 1
                anchors.left: siteIcon.right
                anchors.leftMargin: 10
                text: "<a href=\"" + model.url + "\">" + model.url + "</a>"
                font.pixelSize: 18
            }
            MouseArea {
                id: mArea
                anchors.fill: parent
                onClicked: {
                    load(model.url)
                    root.hide()
                }
            }
        }
    }

    ListView {
        id: recentSitesList
        anchors.top: address.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        height: 0
        clip: true
        visible: root.showRecent
        model: addressListModel
        delegate: Item {
            width: parent.width
            height: 50
            Rectangle {
                anchors.fill: parent
                color: mArea.pressed ? "#f0f0f0" : "white"
            }
            Image {
                id: siteIcon
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 3
                source: model.icon ? (testIcon.status == Image.Error ? QmlHelperTools.getFaviconFromUrl(model.url) : model.icon) : QmlHelperTools.getFaviconFromUrl(model.url)
                width: 20
                height: 20
                smooth: true
                cache: true
            }
            Image {
                id: testIcon
                visible: false
                source: model.icon
            }
            Text {
                id: siteLabel
                anchors.top: parent.top
                anchors.topMargin: 3
                anchors.left: siteIcon.right
                anchors.leftMargin: 3
                text: model.title
                font.pixelSize: 18
            }
            Text {
                id: siteUrl
                anchors.top: siteLabel.bottom
                anchors.topMargin: 1
                anchors.left: siteIcon.right
                anchors.leftMargin: 3
                text: model.url
                font.pixelSize: 18
            }
            MouseArea {
                id: mArea
                anchors.fill: parent
                onClicked: {
                    address.text = model.url
                    hideRecentList()
                }
            }
        }
    }

    Rectangle {
        id: hideRecent
        anchors.top: recentSitesList.bottom
        width: parent.width
        height: visible ? 30 : 0
        visible: recentSitesList.visible
        color: "white"
        Rectangle {
            width: parent.width / 3 * 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            height: 1
            color: "black"
        }
        Rectangle {
            width: parent.width / 3 * 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 20
            height: 1
            color: "black"
        }
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: "black"
        }
        MouseArea {
            anchors.fill:parent
            onClicked: {
                hideRecentList()
            }
        }
    }

    ListModel {
        id: addressListModel
    }
}
