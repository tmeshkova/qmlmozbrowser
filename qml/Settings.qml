import Qt 4.7
import QtQuick 1.0

Rectangle {
    id : root
    visible: true
    color: "white"

    function show() {
        animShow.running = true
        MozContext.sendObserve("embedui:prefs", { msg: "getPrefList", prefs: [ "general.useragent.override",
                                                                               "browser.ui.font.reflow",
                                                                               "browser.ui.font.reflow.fontSize",
                                                                               "font.size.inflation.minTwips",
                                                                               "font.size.inflation.emPerLine",
                                                                               "font.size.inflation.forceEnabled",
                                                                               "keyword.URL",
                                                                               "gfx.azpc.vertical_scroll_lock_ratio",
                                                                               "gfx.azpc.horizontal_scroll_lock_ratio"]})
    }

    function hide() {
        uaString.setFocus(false)
        animHide.running = true
        MozContext.sendObserve("embedui:saveprefs", {})
    }

    Connections {
        target: MozContext
        onRecvObserve: {
            if (message == "embed:prefs") {
                for (var i=0; i<data.length; i++) {
                    console.log(data[i].name + ": " + data[i].value)
                    switch (data[i].name) {
                        case "general.useragent.override": {
                            uaString.text = data[i].value;
                            uaString.cursorPosition = 0;
                            customUA.checked = true
                            break;
                        }
                        case "font.size.inflation.forceEnabled": {
                            forceFontInflation.checked = data[i].value;
                            break;
                        }
                        case "font.size.inflation.emPerLine": {
                            fontInflationEmPerLine.text = data[i].value;
                            fontInflationEmPerLine.cursorPosition = 0;
                            break;
                        }
                        case "font.size.inflation.minTwips": {
                            fontInflationMinTwips.text = data[i].value;
                            fontInflationMinTwips.cursorPosition = 0;
                            break;
                        }
                        case "browser.ui.font.reflow": {
                            zoomReflow.checked = data[i].value;
                            break;
                        }
                        case "browser.ui.font.reflow.fontSize": {
                            fontSizeOnReflow.text = data[i].value;
                            fontSizeOnReflow.cursorPosition = 0;
                            break;
                        }
                        case "keyword.URL": {
                            searchKeyword.text = data[i].value;
                            searchKeyword.cursorPosition = 0;
                            break;
                        }
                        case "gfx.azpc.vertical_scroll_lock_ratio": {
                            verticalScrollLockRatio.text = parseFloat(data[i].value);
                            verticalScrollLockRatio.cursorPosition = 0;
                            break;
                        }
                        case "gfx.azpc.horizontal_scroll_lock_ratio": {
                            horizontalScrollLockRatio.text = parseFloat(data[i].value);
                            horizontalScrollLockRatio.cursorPosition = 0;
                            break;
                        }
                    }
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
        anchors.top: title.bottom
        anchors.left: root.left
        anchors.right: root.right
        anchors.bottom: root.bottom
        anchors.margins: 10
        clip: true
        contentHeight: content.height

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
                        console.log("custom ua: " + checked)
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
                }
            }

            Checkbox {
                id: forceFontInflation
                width: parent.width
                text: "Force font size inflations"
                onClicked: {
                    MozContext.setPref("font.size.inflation.forceEnabled", checked)
                }
            }

            Text {
                id: twipsTitle
                text: "Font inflation min twips"
                font.pixelSize: 26
            }

            InputArea {
                id: fontInflationMinTwips
                width: parent.width-1
                text: ""
                inputMethodHints: Qt.ImhDigitsOnly
                onAccepted: {
                    MozContext.setPref("font.size.inflation.minTwips", parseInt(fontInflationMinTwips.text))
                }
            }

            Text {
                id: emPerLineTitle
                text: "Font em per line"
                font.pixelSize: 26
            }

            InputArea {
                id: fontInflationEmPerLine
                width: parent.width-1
                text: ""
                inputMethodHints: Qt.ImhDigitsOnly
                onAccepted: {
                    MozContext.setPref("font.size.inflation.emPerLine", parseInt(fontInflationEmPerLine.text))
                }
            }

            Checkbox {
                id: zoomReflow
                width: parent.width
                text: "Reflow text on zoom"
                onClicked: {
                    MozContext.setPref("browser.ui.zoom.reflow", checked)
                }
            }

            Text {
                id: reflowTitle
                text: "Font size on reflow"
                font.pixelSize: 26
            }

            InputArea {
                id: fontSizeOnReflow
                width: parent.width-1
                text: ""
                inputMethodHints: Qt.ImhDigitsOnly
                onAccepted: {
                    MozContext.setPref("browser.ui.zoom.reflow.fontSize", parseInt(fontSizeOnReflow.text))
                }
            }

            Text {
                id: searchTitle
                text: "Search engine keyword"
                font.pixelSize: 26
            }

            InputArea {
                id: searchKeyword
                width: parent.width-1
                text: "http://bing.com/results.aspx?q="
                onAccepted: {
                    MozContext.setPref("keyword.URL", searchKeyword.text)
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
                text: "2.0"
                inputMethodHints: Qt.ImhDigitsOnly
                onAccepted: {
                    MozContext.setPref("gfx.azpc.vertical_scroll_lock_ratio", parseFloat(verticalScrollLockRatio.text))
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
                    MozContext.setPref("gfx.azpc.horizontal_scroll_lock_ratio", parseFloat(horizontalScrollLockRatio.text))
                }
            }
        }
    }
}
