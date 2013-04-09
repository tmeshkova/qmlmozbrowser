import Qt 4.7
import QtQuick 1.1

Rectangle {
    id : root
    visible: true
    color: "white"
    property variant viewport
    signal bookmarksChanged()

    Component.onCompleted: {
        print("Bookmarks ready!")
        var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
        db.transaction(
            function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS bookmarks (url TEXT, title TEXT, icon TEXT, category TEXT, type INTEGER)')
            }
        );
        fillModelFromDatabase()
        fillGroupsModel()
    }

    function show() {
        fillModelFromDatabase()
        fillGroupsModel()
        animShow.running = true
    }

    function hide() {
        animHide.running = true
    }

    function updateBookmark(url, title, group, type, oldUrl) {
        var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
        db.transaction(
            function(tx) {
                var result = tx.executeSql('update bookmarks set url=(?), title=(?), icon=(?), category=(?), type=(?) where url=(?)',[url, title, QmlHelperTools.getFaviconFromUrl(url), group, type, oldUrl])
                if (result.rowsAffected < 1) {
                    console.log("Error updating bookmark")
                }
            }
        );
    }

    function fillGroupsModel() {
        var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
        db.transaction(
            function(tx) {
                var result = tx.executeSql('SELECT distinct category from bookmarks')
                groupsListModel.clear()
                for (var i=0; i < result.rows.length; i++) {
                    groupsListModel.insert(0, {"name": result.rows.item(i).category})
                }
            }
        );
    }

    function fillModelFromDatabase() {
        var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
        db.transaction(
            function(tx) {
                var result = tx.executeSql('select * from bookmarks order by category desc')
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

    function filterModel(value) {
        if (value == "") {
            bookmarksList.model = bookmarksListModel
        }
        else {
            filterListModel.clear()
            var lowerValue = value.toLowerCase()
            for (var i=0; i<bookmarksListModel.count; i++) {
                var item = bookmarksListModel.get(i)
                if (item.title.toLowerCase().search(lowerValue) != -1 ||
                    item.url.toLowerCase().search(lowerValue) != -1) {
                    filterListModel.append(item)
                }
            }
            bookmarksList.model = filterListModel
        }
    }

    function isNewGroup(index) {
        if (index == 0) {
            return true
        }
        else if (index > 0) {
            var prevGroup = bookmarksList.model.get(index - 1).group
            var currGroup = bookmarksList.model.get(index).group
            return prevGroup != currGroup
        }
        return false
    }

    function checkUrl(url) {
        for (var i=0; i<bookmarksListModel.count; i++) {
            if (bookmarksListModel.get(i).url == url) {
                return true
            }
        }
        return false
    }

    ListModel {
        id: groupsListModel
    }

    ListModel {
        id: filterListModel
    }

    ListModel {
        id: bookmarksListModel
    }

    ParallelAnimation {
        id: animHide
        PropertyAnimation {
            target: root
            properties: "x"
            from: 0; to: -root.parent.width; duration: 300;
        }
        PropertyAnimation {
            target: root
            properties: "opacity"
            from: 1.0; to: 0.01; duration: 300;
        }
    }

    ParallelAnimation {
        id: animShow
        PropertyAnimation {
            target: root
            properties: "x"
            from: root.parent.width; to: 0; duration: 300;
        }
        PropertyAnimation {
            target: root
            properties: "opacity"
            from: 0.01; to: 1.0; duration: 300;
        }
    }

    Rectangle {
        id: title
        anchors.top: root.top
        anchors.left: root.left
        anchors.right: root.right
        height: 100 + (addMode ? addArea.height : filterArea.height)
        color: "#dddddd"
        property bool addMode: false

        OverlayButton {
            id: back
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 10
            width: 60
            height: 60
            enabled: true
            iconSource: "../icons/backward.png"

            onClicked: {
                root.hide()
            }
        }

        Text {
            anchors.verticalCenter: back.verticalCenter
            anchors.left: back.right
            anchors.leftMargin: 20
            anchors.right: add.left
            anchors.rightMargin: 20
            text: "Bookmarks"
            font.pixelSize: 40
        }

        OverlayButton {
            id: add
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            width: 60
            height: 60
            enabled: true
            iconSource: "../icons/plus.png"

            onClicked: {
                title.addMode = true
            }
        }

        InputArea {
            id: filterArea
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: back.bottom
            anchors.topMargin: 15
            anchors.right: parent.right
            anchors.rightMargin: 10
            inputMethodHints: Qt.ImhNoPredictiveText
            visible: !title.addMode
            onAccepted: {
                filterModel(text)
            }
        }

        Item {
            id: addArea
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: back.bottom
            anchors.topMargin: 15
            anchors.right: parent.right
            anchors.rightMargin: 10
            height: urlLabel.height +
                    newSiteUrl.height +
                    titleLabel.height +
                    newSiteTitle.height + 
                    selectGroup.height + 5 +
                    addButton.height + 5
            visible: title.addMode

            Text {
                id: urlLabel
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: 26
                text: "Site url"
            }

            InputArea {
                id: newSiteUrl
                function fixSchemeUrl() {
                    if (text.search("//") == -1) {
                        text = "http://" + text
                    }
                    return text
                }
                anchors.top: urlLabel.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                inputMethodHints: Qt.ImhNoPredictiveText || Qt.ImhNoAutoUppercase
            }

            Text {
                id: titleLabel
                anchors.top: newSiteUrl.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: 26
                text: "Site title"
            }

            InputArea {
                id: newSiteTitle
                anchors.top: titleLabel.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                inputMethodHints: Qt.ImhNoPredictiveText || Qt.ImhNoAutoUppercase
            }

            OverlayButton {
                id: selectGroup
                anchors.top: newSiteTitle.bottom
                anchors.topMargin: 5
                anchors.left: parent.left
                anchors.right: parent.right
                height: 50
                text: "Select group"
                function callback(index) {
                    print("group index: " + index)
                    text = dialog.model.get(index).name
                    dialog.done.disconnect(selectGroup.callback)
                }
                onClicked: {
                    dialog.model = groupsListModel
                    dialog.show()
                    dialog.done.connect(selectGroup.callback)
                }
            }

            Checkbox {
                id: showOnStart
                width: parent.width / 2
                anchors.left: parent.left
                anchors.verticalCenter: addButton.verticalCenter
                text: "pin bookmark"
            }

            OverlayButton {
                id: addButton
                height: 50
                width: parent.width / 3
                anchors.top: selectGroup.bottom
                anchors.topMargin: 5
                anchors.right: parent.right
                text: "Add"
                enabled: newSiteTitle.text.length > 0 && newSiteUrl.text.length > 0
                onClicked: {
                    newSiteUrl.setFocus(false)
                    newSiteTitle.setFocus(false)
                    addBookmark(newSiteUrl.fixSchemeUrl(), newSiteTitle.text, selectGroup.text, showOnStart ? 1 : 0)
                    title.addMode = false
                    filterArea.text = ""
                    bookmarksChanged()
                }
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: "black"
        }
    }

    ListView {
        id: bookmarksList
        clip: true
        anchors.top: title.bottom
        anchors.left: root.left
        anchors.right: root.right
        anchors.bottom: root.bottom
        anchors.margins: 5
        spacing: 3
        model: bookmarksListModel
        signal hideAll()
        delegate: Item {
            id: historyDelegate
            width: parent.width
            height: showControls ? (siteTitleEdit.height + siteUrlEdit.height + editGroup.height + saveBookmark.height + 30) : (groupSeparator.height + siteTitle.height + siteUrl.height + 15)
            property bool showControls: false

            Connections {
                target: bookmarksList
                onHideAll: {
                    showControls = false
                    siteTitleEdit.setFocus(false)
                    siteUrlEdit.setFocus(false)
                }
            }

            Rectangle {
                id: bg
                anchors.fill: parent
                anchors.topMargin: groupSeparator.height + (groupSeparator.visible ? 5 : 0)
                anchors.margins: 2
                color: mArea.pressed ? "#d0d0d0" : "#efefef"
            }

            Text {
                id: groupSeparator
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.top: parent.top
                font.pixelSize: 16
                text: visible ? model.group : ""
                visible: !showControls && isNewGroup(index)
                height: visible ? 20 : 0
            }

            Image {
                id: siteIcon
                source: model.icon ? (testIcon.status == Image.Error ? QmlHelperTools.getFaviconFromUrl(model.url) : model.icon) : QmlHelperTools.getFaviconFromUrl(model.url)
                width: 20
                height: 20
                smooth: true
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                cache: true
            }

            Image {
                id: testIcon
                visible: false
                source: model.icon
            }

            OverlayButton {
                id: editBookmark
                width: 50
                height: 50
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.top: siteTitle.top
                anchors.topMargin: 5
                visible: !showControls
                iconSource: "../icons/edit.png"
                onClicked: {
                    showControls = true
                }
            }

            Text {
                id: siteTitle
                anchors.top: groupSeparator.visible ? groupSeparator.bottom : parent.top
                anchors.topMargin: 5
                anchors.left: siteIcon.right
                anchors.leftMargin: 10
                anchors.right: editBookmark.left
                anchors.rightMargin: 5
                text: model.title
                font.pixelSize: 20
                elide: Text.ElideRight
                clip: true
                visible: !showControls
            }

            InputArea {
                id: siteTitleEdit
                anchors.top:parent.top
                anchors.topMargin: 5
                anchors.left: siteIcon.right
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                text: model.title
                visible: showControls
            }

            Text {
                id: siteUrl
                text: "<a href=\"" + model.url + "\">" + model.url + "</a>"
                anchors.top: siteTitle.bottom
                anchors.topMargin: 5
                anchors.left: siteIcon.right
                anchors.leftMargin: 10
                anchors.right: editBookmark.left
                anchors.rightMargin: 5
                font.pixelSize: 20
                elide: Text.ElideRight
                clip: true
                visible: !showControls
            }

            InputArea {
                id: siteUrlEdit
                function fixSchemeUrl() {
                    if (text.search("//") == -1) {
                        text = "http://" + text
                    }
                    return text
                }
                text: model.url
                anchors.top: siteTitleEdit.bottom
                anchors.topMargin: 5
                anchors.left: siteIcon.right
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                visible: showControls
            }

            OverlayButton {
                id: editGroup
                anchors.top: siteUrlEdit.bottom
                anchors.topMargin: 5
                anchors.right: parent.right
                anchors.rightMargin: 10
                width: parent.width / 2 - 10
                height: 50
                text: model.group
                visible: showControls
                function callback(index) {
                    if (index != -1) {
                        text = dialog.model.get(index).name
                    }
                    dialog.done.disconnect(editGroup.callback)
                    fillGroupsModel()
                    bookmarksChanged()
                }
                onClicked: {
                    dialog.model = groupsListModel
                    dialog.show()
                    dialog.done.connect(editGroup.callback)
                }
            }

            Checkbox {
                id: showOnStart
                width: parent.width / 2 - 10
                anchors.left: siteIcon.right
                anchors.leftMargin: 10
                anchors.verticalCenter: editGroup.verticalCenter
                text: "pin"
                checked: model.type == 1
                visible: showControls
                onClicked: {

                }
            }

            OverlayButton {
                id: saveBookmark
                anchors.top: editGroup.bottom
                anchors.topMargin: 5
                anchors.right: deleteBookmark.left
                anchors.rightMargin: 10
                width: 50
                height: 50
                iconSource: "../icons/edit.png"
                visible: showControls
                onClicked: {
                    updateBookmark(siteUrlEdit.fixSchemeUrl(), siteTitleEdit.text, editGroup.text, showOnStart.checked ? 1 : 0, model.url)
                    showControls = false
                    fillModelFromDatabase()
                    fillGroupsModel()
                    bookmarksChanged()
                }
            }

            OverlayButton {
                id: deleteBookmark
                anchors.top: editGroup.bottom
                anchors.topMargin: 5
                anchors.right: parent.right
                anchors.rightMargin: 10
                width: 50
                height: 50
                iconSource: "../icons/download-remove.png"
                visible: showControls
                onClicked: {
                    removeBookmark(model.url)
                    showControls = false
                    bookmarksChanged()
                }
            }

            MouseArea {
                id: mArea
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: editBookmark.left
                anchors.rightMargin: showControls ? parent.width : 10
                anchors.bottom: siteUrl.bottom
                onClicked: {
                    if (!showControls) {
                        load(model.url)
                        root.hide()
                        startPage.hide()
                    }
                }
                onPressAndHold: {
                    bookmarksList.hideAll()
                    showControls = true
                }
            }
        }
    }

    SelectDialog {
        id: dialog
        anchors.fill: parent
        canAdd: true
        title: "Select group"
    }
}
