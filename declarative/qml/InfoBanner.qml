import QtQuick 1.0

Rectangle {
    id: root
    color: "white"
    height: infoText.height + 10

    function show(text, color, icon) {
        infoText.text = text
        infoText.font.color = color
        infoIcon.source = icon
        root.visible = true
        infoTimer.start()
    }

    Image {
        id: infoIcon
        height: 30
        width: 30
        anchors.left: root.left
        anchors.leftMargin: 10
        anchors.verticalCenter: root.verticalCenter
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    Text {
        id: infoText
        height: 26
        font.pixelSize: 26
        anchors.verticalCenter: root.verticalCenter
        anchors.horizontalCenter: root.horizontalCenter
    }

    Timer {
        id: infoTimer
        interval: 2000
        repeat: false
        onTriggered: {
            root.visible = false
        }
    }
} 
