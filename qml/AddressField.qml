import Qt 4.7
import QtQuick 1.0

Item {
    id: root

    property alias text: addressLine.text
    property variant viewport

    height: 80 + (textInputOverlay.visible ? textInputOverlay.height : 0)
    width: parent.width

    function focusAddressBar() {
        addressLine.forceActiveFocus()
        addressLine.selectAll()
    }

    function unfocusAddressBar() {
        addressLine.focus = false
    }

    Connections {
        target: viewport.child()

        onUrlChanged: {
            addressLine.text = viewport.child().url;
            addressLine.cursorPosition = 0;
        }
        onTitleChanged: {
            pageTitle.text = viewport.child().title;
        }
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

    Rectangle {
        anchors.top: root.top
        anchors.topMargin: 30
        anchors.left: root.left
        anchors.right: root.right
        anchors.margins: 10

        color: "white"
        border.width: 1
        height: 40
        radius: 10
        smooth: true

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: parent.width / 100 * viewport.child().loadProgress
            radius: 10
            color: "blue"
            opacity: 0.3
            visible: viewport.child().loadProgress != 100
        }

        TextInput {
            id: addressLine

            selectByMouse: true
            font {
                pixelSize: 25
                family: "Nokia Pure Text"
            }
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right

            onActiveFocusChanged: {
                addressLine.focus ? textInputOverlay.visible = true : textInputOverlay.visible = false
            }

            Keys.onReturnPressed:{
                viewport.child().load(addressLine.text);
                viewport.focus = true
            }

            Keys.onPressed: {
                if (((event.modifiers & Qt.ControlModifier) && event.key == Qt.Key_L) || event.key == Qt.key_F6) {
                    focusAddressBar()
                    event.accepted = true
                }
            }
        }
    }

    Row {
        id: textInputOverlay
        visible: false
        spacing: 3
        height: 40

        anchors.left: root.left
        anchors.right: root.right
        anchors.bottom: root.bottom
        anchors.margins: 3

        OverlayButton {
            height: parent.height-3
            width: parent.width/3-3
            text: "Copy"
            onClicked: addressLine.copy()
        }

        OverlayButton {
            height: parent.height-3
            width: parent.width/3-3
            text: "Paste"
            enabled: addressLine.canPaste
            onClicked: addressLine.paste()
        }

        OverlayButton {
            height: parent.height-3
            width: parent.width/3-3
            text: "Select all"
            onClicked: addressLine.selectAll()
        }
    }
}