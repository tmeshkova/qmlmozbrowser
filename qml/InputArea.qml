import Qt 4.7
import QtQuick 1.0

Item {
    id: root
    property int loadProgress: 0
    property alias text: inputLine.text
    signal accepted()
    height: inputArea.height + textInputOverlay.height
    property alias cursorPosition: inputLine.cursorPosition

    function setFocus(op) {
        if (op)
            inputLine.forceActiveFocus()
        else
            inputArea.forceActiveFocus()
    }

    Rectangle {
        id: inputArea
        anchors.top: root.top
        anchors.left: root.left
        anchors.right: root.right

        color: "transparent"
        border.width: 1
        height: 40
        radius: 10
        smooth: true

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: parent.width / 100 * root.loadProgress
            radius: 10
            color: "cyan"
            opacity: 0.3
            visible: (root.loadProgress > 0) ? (root.loadProgress < 100 ? true : false) : false
            smooth: true
        }

        TextInput {
            id: inputLine
            autoScroll: true
            selectByMouse: true
            font {
                pixelSize: 26
                family: "Nokia Pure Text"
            }
            anchors.verticalCenter: inputArea.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5

            Keys.onReturnPressed:{
                root.accepted()
                closeSoftwareInputPanel()
                root.setFocus(false)
            }

            Keys.onPressed: {
                if (((event.modifiers & Qt.ControlModifier) && event.key == Qt.Key_L) || event.key == Qt.key_F6) {
                    root.setFocus(true)
                    event.accepted = true
                }
            }
        }
    }

    Row {
        id: textInputOverlay
        spacing: 3
        anchors.left: root.left
        anchors.right: root.right
        anchors.rightMargin: 3
        anchors.top: inputArea.bottom
        anchors.topMargin: 5
        visible: inputLine.focus
        height: visible ? 40 : 0

        OverlayButton {
            height: parent.height-3
            width: parent.width/3
            text: "Copy"
            onClicked: inputLine.copy()
        }

        OverlayButton {
            height: parent.height-3
            width: parent.width/3
            text: "Paste"
            enabled: inputLine.canPaste
            onClicked: inputLine.paste()
        }

        OverlayButton {
            height: parent.height-3
            width: parent.width/3
            text: "Select all"
            onClicked: inputLine.selectAll()
        }
    }
}
