import QtQuick 1.1

Item {
    id: dialog

    anchors.fill: parent
    parent: mainScope

    property string title: ""
    property string host: ""
    property alias dontAsk: dontAskBox.checked
    property bool accepted: false
    property variant uid
    visible: false
    signal handled

    function show(atitle, ahost, aid) {
        dialog.title = atitle;
        dialog.host = ahost;
        dialog.uid = aid;
        visible = true;
    }

    function handle(aAccept) {
        dialog.accepted = aAccept;
        dialog.handled();
        visible = false;
    }

    MouseArea {
        id: mouseBlocker
        anchors.fill: parent
        onPressed: mouse.accepted = true

        // FIXME: This does not block touch events :(
    }

    Rectangle {
        id: dimBackground
        anchors.fill: parent
        color: "black"
        opacity: 0.4
    }

    Rectangle {
        id: dialogWindow

        color: "#fefefe"

        anchors.top: content.top
        anchors.horizontalCenter: content.horizontalCenter
        width: content.width
        height: content.height + 10

        border {
            width: 1
            color: "#cfcfcf"
        }

        smooth: true
        radius: 5
    }

    Rectangle {
        id: fancy

        color: "#efefef"

        anchors.fill: dialogWindow
        anchors.topMargin: titleText.height
        anchors.leftMargin: 3
        anchors.rightMargin: 3
        anchors.bottomMargin: 3

        border {
            width: 1
            color: "#bfbfbf"
        }

        smooth: true
        radius: 3
    }

    Column {
        id: content
        anchors.centerIn: parent
        width: Math.min(Math.min(parent.width, parent.height) - 10, 400)
        spacing: 10

        Text {
            id: titleText
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 20
            font.weight: Font.Bold
            elide: Text.ElideRight
            text: "Premission request: " + title
        }

        Text {
            id: messageText
            wrapMode: Text.WordWrap
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 20
            font.pixelSize: 20
            text: "Host: " + host
        }

        Column {
            id: dynamicColumn
            spacing: 5
            anchors.margins: 10
            width: parent.width - 20
            anchors.horizontalCenter: content.horizontalCenter

            Checkbox {
                id: dontAskBox
                width: parent.width
                fixedHeight: 20
                text: "Don't ask"
            }

            Row {
                spacing: 6
                DialogButton {
                    width: dynamicColumn.width/2 - 3
                    text: "Allow"
                    onClicked: handle(true)
                }

                DialogButton {
                    width: dynamicColumn.width/2 - 3
                    text: "Deny"
                    onClicked: handle(false)
                }
            }
        }
    }
}
