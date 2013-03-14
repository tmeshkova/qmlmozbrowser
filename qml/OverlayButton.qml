import Qt 4.7
import QtQuick 1.0

Item {
    id: root

    signal clicked()
    signal pressAndHold()
    signal pressed()

    property alias iconSource: icon.source
    property alias text: label.text
    property int fixedHeight: 0

    Rectangle {
        id: background

        anchors.fill: root

        radius: root.height / 5
        border.color: "black"
        border.width: 1
        smooth: true
        color: root.enabled ? (mouseArea.pressed ? "cyan" : "white") : "transparent"
        opacity: mouseArea.pressed ? 0.5 : 0.8
    }

    Image {
        id: icon
        anchors.left: root.left
        anchors.top: root.top
        anchors.bottom: root.bottom
        anchors.margins: root.height / 20
        height: root.height - anchors.leftMargin
        width: height
        fillMode: Image.PreserveAspectFit
        smooth: true
        asynchronous: true
        visible: source != ""
        opacity: root.enabled ? 1.0 : 0.2
    }

    Text {
        id: label
        anchors.verticalCenter: root.verticalCenter
        anchors.left: icon.visible ? icon.right : root.left
        font.pixelSize: root.fixedHeight ? root.fixedHeight : (root.height - background.radius * 2)
        anchors.right: parent.right
        horizontalAlignment: icon.visible ? Text.AlignLeft : Text.AlignHCenter
        elide: Text.ElideRight

        opacity: root.enabled ? 1.0 : 0.2
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        onPressed: {
            root.pressed()
            mouse.accepted = true
        }
        onReleased: {
            root.clicked()
            mouse.accepted = true
        }
        onPressAndHold: {
            root.pressAndHold()
            mouse.accepted = true
        }
    }
}
