import Qt 4.7
import QtQuick 1.0

Rectangle {
    id : root
    visible: true
    color: "white"
    property variant context

    function show() {
        //anchors.leftMargin = 0
        animShow.running = true
        //GET SETTINGS NOT IMPLEMENTED
    }

    function hide() {
        uaString.setFocus(false)
        animHide.running = true
        //anchors.leftMargin = root.parent.width
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

            Checkbox {
                id: overrideGeo
                width: parent.width
                text: "Override Geo policy to Accept always"
                onClicked: {
                    console.log("geo override: " + checked)
                    context.setPref("geo.prompt.testing", checked)
                    context.setPref("geo.prompt.testing.allow", checked)
                }
            }

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
                            context.setPref("general.useragent.override", uaString.text)
                        }
                        else {
                            context.setPref("general.useragent.override", "Mozilla/5.0 (X11; Linux x86_64; rv:20.0) Gecko/20130124 Firefox/20.0")
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

                    }
                }
            }

            Checkbox {
                id: test
                width: parent.width
                text: "Some test settings"
                onClicked: {
                    console.log("test: " + checked)
                }
            }

            Rectangle {
                width: 300
                height: 300
                color: "green"
            }

            Rectangle {
                width: 300
                height: 300
                color: "red"
            }

            Rectangle {
                width: 300
                height: 300
                color: "blue"
            }
        }
    }
}
