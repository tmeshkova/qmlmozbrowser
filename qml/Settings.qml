import QtQuick 1.0

Rectangle {
    id : root
    visible: true
    color: "white"

    Component.onCompleted: {
        print("Settings ready!")
        var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
        db.transaction(
            function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS settings (name TEXT, value TEXT)')
            }
        );
        var items = null
        db.transaction(
            function(tx) {
                var result = tx.executeSql('select * from settings')
                items = result.rows
            }
        );
        if (items.length < 1) {
            console.log("Settings empty!")
            db.transaction(
                function(tx) {
                    var name = "one_touch_ui"
                    var value = "disabled"
                    var result = tx.executeSql('INSERT INTO settings VALUES (?,?);',[name,value])
                    if (result.rowsAffected < 1) {
                        console.log("Error inserting settings!")
                    }
                }
            );
        }
        else {
            for (var i=0; i < items.length; i++) {
                var item = items.item(i)
                switch (item.name) {
                    case "one_touch_ui": {
                        oneTouchUI.checked = (item.value == "enabled")
                        overlay.useOldBehaviour = !oneTouchUI.checked
                        break
                    }
                }
            }
        }
    }

    function show() {
        animShow.running = true
        MozContext.sendObserve("embedui:prefs", { msg: "getPrefList", prefs: [ "general.useragent.override",
                                                                               "browser.zoom.reflowOnZoom",
                                                                               "browser.zoom.reflowMobilePages",
                                                                               "gfx.azpc.vertical_scroll_lock_ratio",
                                                                               "gfx.azpc.horizontal_scroll_lock_ratio",
                                                                               "gfx.azpc.touch_start_tolerance",
                                                                               "ui.click_hold_context_menus.delay"]})
        MozContext.sendObserve("embedui:search", { msg: "getlist"})
    }

    function hide() {
        uaString.setFocus(false)
        animHide.running = true
        MozContext.sendObserve("embedui:saveprefs", {})
    }

    Connections {
        target: MozContext
        onRecvObserve: {
            switch (message) {
                case "embed:prefs": {
                    for (var i=0; i<data.length; i++) {
                        switch (data[i].name) {
                            case "general.useragent.override": {
                                uaString.text = data[i].value;
                                uaString.cursorPosition = 0;
                                customUA.checked = true
                                break;
                            }
                            case "browser.zoom.reflowOnZoom": {
                                zoomReflow.checked = data[i].value;
                                break;
                            }
                            case "browser.zoom.reflowMobilePages": {
                                mobileReflow.checked = data[i].value;
                                break;
                            }
                            case "keyword.URL": {
                                searchKeyword.text = data[i].value;
                                searchKeyword.cursorPosition = 0;
                                break;
                            }
                            case "gfx.azpc.vertical_scroll_lock_ratio": {
                                verticalScrollLockRatio.text = data[i].value.replace("f", "");
                                verticalScrollLockRatio.cursorPosition = 0;
                                break;
                            }
                            case "gfx.azpc.horizontal_scroll_lock_ratio": {
                                horizontalScrollLockRatio.text = data[i].value.replace("f", "");
                                horizontalScrollLockRatio.cursorPosition = 0;
                                break;
                            }
                            case "gfx.azpc.touch_start_tolerance": {
                                longTapCancelDistance.text = parseFloat(data[i].value.replace("f", "")) * 72;
                                longTapCancelDistance.cursorPosition = 0;
                                break;
                            }
                            case "ui.click_hold_context_menus.delay": {
                                longTapDelay.text = data[i].value;
                                longTapDelay.cursorPosition = 0;
                                break;
                            }
                        }
                    }
                    break
                }
                case "embed:search": {
                    switch (data.msg) {
                        case "init": {
                            if (data.defaultEngine == null) {
                                MozContext.sendObserve("embedui:search", {msg:"setcurrent", name:"Google"})
                                MozContext.sendObserve("embedui:search", {msg:"setdefault", name:"Google"})
                                selectSearchEngine.text = "Google"
                            }
                            else {
                                selectSearchEngine.text = data.defaultEngine
                            }
                            break
                        }
                        case "pluginslist":
                        {
                            searchEnginesModel.clear()
                            for (var i=0; i<data.list.length; i++) {
                                var plugin = data.list[i]
                                if (plugin.isDefault) {
                                    selectSearchEngine.text = plugin.name
                                }
                                searchEnginesModel.append({name: plugin.name})
                            }
                            break
                        }
                    }
                    break
                }
            }
        }
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
        height: 80
        color: "#dddddd"

        OverlayButton {
            id: back
            anchors.verticalCenter: parent.verticalCenter
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
            text: "Settings"
            font.pixelSize: 40
        }

        OverlayButton {
            id: config
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            width: 60
            height: 60
            enabled: true
            iconSource: "../icons/settings.png"

            onClicked: {
                root.hide()
                configPage.show()
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: "black"
        }
    }

    Flickable {
        id: flick
        anchors.top: title.bottom
        anchors.left: root.left
        anchors.right: root.right
        anchors.bottom: root.bottom
        anchors.margins: 10
        clip: true
        contentHeight: content.height
        function flickToItem(item) {
            var posY = item.y
            if (contentHeight - posY < root.height) {
                posY = posY - root.height + item.height + 15
            }
            contentY = posY
        }
        Column {
            id: content
            width: parent.width
            spacing: 5

            Text {
                text: "Custom user-agent string"
                font.pixelSize: 26
            }

            Item {
                id: uaItem
                width: parent.width
                height: Math.max(customUA.height, uaString.height)

                Checkbox {
                    id: customUA
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: 40
                    text: ""
                    onClicked: {
                        if (checked) {
                            MozContext.setPref("general.useragent.override", uaString.text)
                        }
                        else {
                            MozContext.setPref("general.useragent.override", "")
                        }
                    }
                }

                InputArea {
                    id: uaString
                    anchors.left: customUA.right
                    anchors.leftMargin: 15
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.top: parent.top
                    text: "Mozilla/5.0 (X11; Linux x86_64; rv:20.0) Gecko/20130124 Firefox/20.0"
                    onAccepted: {
                        MozContext.setPref("general.useragent.override", uaString.text)
                    }
                    onActiveFocusChanged: {
                        if (inputFocus) {
                            flick.flickToItem(uaString)
                        }
                    }
                }
            }

            Checkbox {
                id: zoomReflow
                width: parent.width
                text: "Reflow text on zoom"
                onClicked: {
                    MozContext.setPref("browser.zoom.reflowOnZoom", checked)
                }
            }

            Checkbox {
                id: mobileReflow
                width: parent.width
                text: "Allow reflow mobile pages"
                onClicked: {
                    MozContext.setPref("browser.zoom.reflowMobilePages", checked)
                }
            }

            Text {
                id: verticalScrollLockText
                text: "Vertical scroll lock ratio"
                font.pixelSize: 26
            }

            InputArea {
                id: verticalScrollLockRatio
                width: parent.width-1
                text: "1.2"
                inputMethodHints: Qt.ImhDigitsOnly
                onAccepted: {
                    MozContext.setPref("gfx.azpc.vertical_scroll_lock_ratio", verticalScrollLockRatio.text + "f")
                }
                onActiveFocusChanged: {
                    if (inputFocus) {
                        flick.flickToItem(verticalScrollLockRatio)
                    }
                }
            }

            Text {
                id: horizontalScrollLockText
                text: "Horizontal scroll lock ratio"
                font.pixelSize: 26
            }

            InputArea {
                id: horizontalScrollLockRatio
                width: parent.width-1
                text: "0.5"
                inputMethodHints: Qt.ImhDigitsOnly
                onAccepted: {
                    MozContext.setPref("gfx.azpc.horizontal_scroll_lock_ratio", horizontalScrollLockRatio.text + "f")
                }
                onActiveFocusChanged: {
                    if (inputFocus) {
                        flick.flickToItem(horizontalScrollLockRatio)
                    }
                }
            }

            Text {
                id: longTapCancelDistanceText
                text: "Distance to cancel LongTap"
                font.pixelSize: 26
            }

            InputArea {
                id: longTapCancelDistance
                width: parent.width-1
                text: "10"
                inputMethodHints: Qt.ImhDigitsOnly
                onAccepted: {
                    MozContext.setPref("gfx.azpc.touch_start_tolerance", (parseInt(longTapCancelDistance.text) / 72) + "f")
                }
                onActiveFocusChanged: {
                    if (inputFocus) {
                        flick.flickToItem(longTapCancelDistance)
                    }
                }
            }

            Text {
                id: longTapDelayText
                text: "LongTap delay (ms)"
                font.pixelSize: 26
            }

            InputArea {
                id: longTapDelay
                width: parent.width-1
                text: "500"
                inputMethodHints: Qt.ImhDigitsOnly
                onAccepted: {
                    MozContext.setPref("ui.click_hold_context_menus.delay", parseInt(longTapDelay.text))
                }
                onActiveFocusChanged: {
                    if (inputFocus) {
                        flick.flickToItem(longTapDelay)
                    }
                }
            }

            Checkbox {
                id: oneTouchUI
                width: parent.width
                text: "Use One-touch overlay UI behaviour"
                onClicked: {
                    overlay.useOldBehaviour = !checked
                    var name = "one_touch_ui"
                    var value = checked ? "enabled" : "disabled"
                    var db = openDatabaseSync("qmlbrowser","0.1","historydb", 100000)
                    db.transaction(
                        function(tx) {
                            var result = tx.executeSql('update settings set value=(?) where name=(?);',[value, name])
                            if (result.rowsAffected < 1) {
                                console.log("Error inserting value!")
                            }
                        }
                    );
                }
            }

            Text {
                id: searchEnginesText
                text: "Search engine"
                font.pixelSize: 26
            }

            OverlayButton {
                id: selectSearchEngine
                width: parent.width
                height: 40
                function done(index) {
                    if (index != -1) {
                        text = enginesDialog.model.get(index).name
                        searchEnginesModel = enginesDialog.model
                        enginesDialog.done.disconnect(selectSearchEngine.done)
                        MozContext.sendObserve("embedui:search", {msg:"setcurrent", name:text})
                        MozContext.sendObserve("embedui:search", {msg:"setdefault", name:text})
                    }
                }
                onClicked: {
                    enginesDialog.model = searchEnginesModel
                    enginesDialog.show()
                    enginesDialog.done.connect(selectSearchEngine.done)
                }
            }
        }
    }

    ListModel {
        id: searchEnginesModel
    }

    SelectDialog {
        id: enginesDialog
        anchors.fill: parent
        canAdd: false
        title: "Select search engine"
    }
}
