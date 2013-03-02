import Qt 4.7
import QtQuick 1.0

Item {
    id: root
    signal clicked()

    property alias text: label.text
    property int fixedHeight: 0
    property bool checked: false

    height: Math.max(icon.height, label.paintedHeight)

    Image {
        id: icon
        anchors.left: root.left
        anchors.top: root.top
        height: 40
        width: 40
        fillMode: Image.PreserveAspectFit
        smooth: true
        asynchronous: true
        source: "../icons/button" + (root.checked ? "-checked" : "") + ".png"
    }

    Text {
        id: label
        anchors.top: root.top
        anchors.left: icon.right
        anchors.leftMargin: 10
        anchors.right: root.right
        font.pixelSize: root.fixedHeight ? root.fixedHeight : (icon.height / 3 * 2)
        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.WrapAnywhere
    }

    MouseArea {
        anchors.fill: root
        onClicked: {
            root.checked = !root.checked
            root.clicked()
        }
    }
}
