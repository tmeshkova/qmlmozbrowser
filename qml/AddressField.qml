import Qt 4.7
import QtQuick 1.0

Item {
    id: root

    property alias text: addressLine.text
    property alias inputFocus: addressLine.inputFocus
    property variant viewport
    signal accepted()

    height: 40 + addressLine.height
    width: parent.width

    function focusAddressBar() {
        addressLine.setFocus(true)
    }

    function unfocusAddressBar() {
        addressLine.setFocus(false)
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
        onAccepted: {
            viewport.child.load(text);
            root.accepted()
        }
    }
}
