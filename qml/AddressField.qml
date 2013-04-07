import Qt 4.7
import QtQuick 1.1

Item {
    id: root

    property alias text: addressLine.text
    property alias inputFocus: addressLine.inputFocus
    property variant viewport
    property bool showRecent: false
    signal accepted()
    signal recentTriggered()
    height: 40 + addressLine.height + recentSitesList.height + hideRecent.height
    width: parent.width

    function focusAddressBar() {
        addressLine.setFocus(true)
    }

    function unfocusAddressBar() {
        addressLine.setFocus(false)
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
                var result = tx.executeSql('SELECT url, title, icon FROM history where url like (?)',["%" + value + "%"])
                recentListModel.clear()
                for (var i=0; i < result.rows.length; i++) {
                    recentListModel.insert(0, {"url": result.rows.item(i).url,
                                     "title": result.rows.item(i).title,
                                     "icon": result.rows.item(i).icon})
                }
            }
        );
    }

    Connections {
        target: viewport.child

        onUrlChanged: {
            addressLine.text = viewport.child.url;
            addressLine.cursorPosition = 0;
        }
        onTitleChanged: {
            pageTitle.text = viewport.child.title;
        }
    }

    Rectangle {
        anchors.fill: root
        color: "white"
        opacity: 0.8
    }

    Rectangle {
        anchors.left: root.left
        anchors.right: root.right
        anchors.bottom: root.bottom
        height: 1
        color: "black"
    }

    Text {
        id: pageTitle

        height: 20
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.top: root.top
        font.pixelSize: height
        text: " "
        horizontalAlignment: (paintedWidth > parent.width) ? Text.AlignLeft : Text.AlignHCenter
    }

    InputArea {
        id: addressLine
        anchors.top: root.top
        anchors.topMargin: 30
        anchors.left: root.left
        anchors.right: root.right
        anchors.margins: 10
        loadProgress: viewport.child.loadProgress
        inputMethodHints: Qt.ImhNoPredictiveText || Qt.ImhNoAutoUppercase
        selectAllOnFocus: true
        onAccepted: {
            hideRecentList()
            load(text);
            root.accepted()
        }
        onTextChanged: {
            if (inputFocus) {
                fillRecentFromDatabase(text)
                root.showRecent = (recentListModel.count > 0)
                if (recentListModel.count > 0) {
                    var url0 = recentListModel.get(0).url
                    if (url0.search(text) == 0) {
                        addressLine.setUrl(url0)
                    }
                }
                if (recentListModel.count > 4) {
                    recentSitesList.height = 200
                }
                else {
                    recentSitesList.height = (50 * recentListModel.count)
                }
                root.recentTriggered()
            }
        }
    }

    ListView {
        id: recentSitesList
        anchors.top: addressLine.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        height: 0
        clip: true
        visible: root.showRecent
        model: recentListModel
        delegate: Item {
            width: parent.width
            height: 50
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
                    addressLine.text = model.url
                    hideRecentList()
                }
            }
        }
    }

    ListModel {
        id: recentListModel
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
        MouseArea {
            anchors.fill:parent
            onClicked: {
                hideRecentList()
            }
        }
    }
}
