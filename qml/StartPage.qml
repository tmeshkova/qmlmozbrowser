import Qt 4.7
import QtMozilla 1.0
import QtQuick 1.1

Rectangle {
    id: root
    color: "white"
    visible: false
    property int topArea: address.height + 10

    function getRecentCount(count) {
        var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
        db.transaction(
            function(tx) {
                var result = tx.executeSql('select * from history order by date desc limit (?)', count)
                recentListModel.clear()
                for (var i=0; i < result.rows.length; i++) {
                    recentListModel.insert(0, {"url": result.rows.item(i).url,
                                     "title": result.rows.item(i).title,
                                     "icon": result.rows.item(i).icon})
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
        onAccepted: {
            load(text)
            root.hide()
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
}
