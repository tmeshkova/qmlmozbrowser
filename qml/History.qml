import Qt 4.7
import QtQuick 1.1

Rectangle {
    id : root
    visible: true
    color: "white"

    Component.onCompleted: {
        print("History ready!")
        var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
        db.transaction(
            function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS history (url TEXT, title TEXT, icon TEXT, date INTEGER)')
            }
        );
    }

    Connections {
        target: webViewport.child
        onRecvAsyncMessage: {
            print(data.rel + " " + data.href)
            if (message == "chrome:linkadded" && data.rel == "shortcut icon") {
                var icon = data.href
                var url = "" + webViewport.child.url
                print("adding favicon " + icon + " to " + url)
                var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
                db.transaction(
                    function(tx) {
                        var result = tx.executeSql('update history set icon=(?) where url=(?);',[icon, url])
                        if (result.rowsAffected < 1) {
                            console.log("Error inserting icon")
                        }
                    }
                );
            }
        }
        onUrlChanged: {
            var url = "" + webViewport.child.url
            var date = new Date()
            date = date.getTime()
            if (url.length > 3 && url.substr(0,6) != "about:") {
                var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
                db.transaction(
                    function(tx) {
                        var result = tx.executeSql('delete from history where url=(?);',[url])
                    }
                );
                db.transaction(
                    function(tx) {
                        var result = tx.executeSql('INSERT INTO history VALUES (?,?,?,?);',[url,"","",date])
                        if (result.rowsAffected < 1) {
                            console.log("Error inserting url")
                        }
                    }
                );
            }
        }
        onTitleChanged: {
            var title = webViewport.child.title
            var url = "" + webViewport.child.url
            if (url.length > 3 && url.substr(0,6) != "about:") {
                var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
                db.transaction(
                    function(tx) {
                        var result = tx.executeSql('update history set title=(?) where url=(?);',[title, url])
                        if (result.rowsAffected < 1) {
                            console.log("Error inserting title")
                        }
                    }
                );
            }
        }
    }

    function calculateLastWeek(startdate) {
        var date = new Date()
        date.setTime(startdate)
        var delta = 0        
        delta += date.getDay() * 86400
        delta += date.getHours() * 3600
        delta += date.getMinutes() * 60
        delta += date.getSeconds()
        delta *= 1000
        delta += date.getMilliseconds()
        return (startdate - delta)
    }

    function fillModelFromDatabase(startdate) {
        historyList.isLoading = true
        var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
        var date = new Date()
        if (startdate == 0) {
            startdate = date.getTime()
            historyListModel.clear()
        }
        else {
            startdate -= 1
            date.setTime(startdate)
        }
        var enddate = calculateLastWeek(startdate)
        var count = 0
        db.transaction(
            function(tx) {
                var result = tx.executeSql('SELECT count(*) as cnt FROM history where date between (?) and (?)', [enddate, startdate])
                count = result.rows.item(0).cnt
            }
        );
        if (count == 0) {
            var allcount = 0
            db.transaction(
                function(tx) {
                    var result = tx.executeSql('SELECT count(*) as cnt FROM history where date < (?)', [startdate])
                    allcount = result.rows.item(0).cnt
                }
            );
            if (allcount == 0) {
                return
            }
            else {
                while (count == 0) {
                    enddate = calculateLastWeek(enddate - 1)
                    db.transaction(
                        function(tx) {
                            var result = tx.executeSql('SELECT count(*) as cnt FROM history where date between (?) and (?)', [enddate, startdate])
                            count = result.rows.item(0).cnt
                        }
                    );
                }
            }
        }

        db.transaction(
            function(tx) {
                var result = tx.executeSql('SELECT * FROM history where date between (?) and (?) order by date desc', [enddate, startdate])
                for (var i=0; i < result.rows.length; i++) {
                    historyListModel.append({"url": result.rows.item(i).url,
                                     "title": result.rows.item(i).title,
                                     "icon": result.rows.item(i).icon,
                                     "date": parseInt(result.rows.item(i).date)})
                }
            }
        );

        historyList.isLoading = false
        
        //if (historyListModel.count < 20 && /* check if we have items before enddate */) {
        //    fillModelFromDatabase(enddate)
        //}
    }

    function show() {
        fillModelFromDatabase(0)
        animShow.running = true
    }

    function hide() {
        animHide.running = true
    }

    function filterModel(value) {
        if (value == "") {
            historyList.model = historyListModel
        }
        else {
            filterListModel.clear()
            var lowerValue = value.toLowerCase()
            for (var i=0; i<historyListModel.count; i++) {
                var item = historyListModel.get(i)
                if (item.title.toLowerCase().search(lowerValue) != -1 ||
                    item.url.toLowerCase().search(lowerValue) != -1) {
                    filterListModel.append(item)
                }
            }
            historyList.model = filterListModel
        }
    }

    function getTimeString(value) {
        var d = new Date()
        d.setTime(value)
        return Qt.formatDateTime(d, "hh:mm")
    }

    function getDateString(value) {
        var d = new Date()
        d.setTime(value)
        return Qt.formatDateTime(d, "dd MMM")
    }

    function isNewDate(index) {
        if (index == 0) {
            return true
        }
        else if (index > 0) {
            var prevDate = historyList.model.get(index - 1).date
            var d1 = new Date()
            d1.setTime(historyList.model.get(index).date)
            var d2 = new Date()
            d2.setTime(prevDate)
            if (d1.getDate() != d2.getDate()) {
                return true
            }
            else {
                return false
            }
        }
        return false
    }

    ListModel {
        id: filterListModel
    }

    ListModel {
        id: historyListModel
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
        height: 100 + filterArea.height
        color: "#dddddd"

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
            text: "History"
            font.pixelSize: 40
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
            onAccepted: {
                filterModel(text)
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
        id: historyList
        property bool isLoading: false
        property bool isLocked: false
        clip: true
        anchors.top: title.bottom
        anchors.left: root.left
        anchors.right: root.right
        anchors.bottom: root.bottom
        anchors.margins: 5
        spacing: 3
        model: historyListModel
        delegate: Item {
            id: historyDelegate
            width: parent.width
            height: 70 + dateSeparator.height

            Rectangle {
                id: bg
                anchors.fill: parent
                anchors.topMargin: dateSeparator.height + (dateSeparator.visible ? 5 : 0)
                anchors.margins: 2
                color: mArea.pressed ? "#d0d0d0" : "#efefef"
            }

            Text {
                id: dateSeparator
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.top: parent.top
                font.pixelSize: 16
                text: visible ? getDateString(model.date) : ""
                visible: root.isNewDate(index)
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

            Text {
                id: siteTitle
                anchors.top: dateSeparator.visible ? dateSeparator.bottom : parent.top
                anchors.topMargin: 5
                anchors.left: siteIcon.right
                anchors.leftMargin: 10
                anchors.right: siteDate.left
                anchors.rightMargin: 10
                text: model.title
                font.pixelSize: 20
                elide: Text.ElideRight
            }

            Text {
                id: siteDate
                anchors.top: dateSeparator.visible ? dateSeparator.bottom : parent.top
                anchors.topMargin: 5
                anchors.right: parent.right
                anchors.rightMargin: 10
                text: getTimeString(model.date)
                font.pixelSize: 20
            }

            Text {
                id: siteUrl
                text: "<a href=\"" + model.url + "\">" + model.url + "</a>"
                anchors.left: siteIcon.right
                anchors.leftMargin: 10
                anchors.top: siteTitle.bottom
                anchors.topMargin: 5
                font.pixelSize: 20
                elide: Text.ElideRight
            }

            MouseArea {
                id: mArea
                anchors.fill: parent
                onClicked: {
                    load(model.url)
                    root.hide()
                    startPage.hide()
                }
            }
        }

        onMovementStarted: {

        }

        onMovementEnded: {
            
        }

        Connections {
            target: historyList.visibleArea
            onYPositionChanged: {
                if (historyList.flicking)
                    return;

                var contentYPos = historyList.visibleArea.yPosition * Math.max(historyList.height, historyList.contentHeight);

                if (!historyList.isLoading && (historyList.contentHeight < historyList.height || (contentYPos + historyList.height) - historyList.contentHeight > 30)) {
                    var lastdate = historyListModel.get(historyListModel.count - 1).date
                    fillModelFromDatabase(lastdate)
                }
            }
        }
    }
}