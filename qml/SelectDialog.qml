import QtQuick 1.0

Item {
    id: root
    visible: false
    property int selectedIndex
    property bool syncLock: true
    property alias title: titleText.text
    property bool canAdd: false
    property alias model: selectContent.model
    signal done(int index)

    function hide() {
        newName.setFocus(false)
        root.visible = false
        done(selectedIndex)
    }

    function show() {
        syncLock = true
        root.visible = true
    }

    function tryAddGroup(value) {
        var index = -1
        for (var i=0; i<model.count; i++) {
            if (model.get(i).name == value) {
                index = i
                break;
            }
        }
        if (index == -1) {
            selectContent.model.append({"name": value})
            index = selectContent.model.count - 1
        }
        selectedIndex = index
        hide()
    }

    ListModel {
        id: selectModel
    }

    MouseArea {
        id: rejectArea
        anchors.fill: parent
        onClicked: {
            selectedIndex = -1
            hide()
        }
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
        border.width: 1
        border.color: "#cfcfcf"
        smooth: true
        radius: 5
    }

    Rectangle {
        id: fancyBorder
        color: "#efefef"
        anchors.fill: dialogWindow
        anchors.topMargin: titleText.height
        anchors.leftMargin: 3
        anchors.rightMargin: 3
        anchors.bottomMargin: 3
        border.width: 1
        border.color: "#bfbfbf"
        smooth: true
        radius: 3
    }

    Column {
        id: content
        anchors.centerIn: root
        width: Math.min(Math.min(root.width, root.height) - 10, 400)
        spacing: 10

        Text {
            id: titleText
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 20
            font.weight: Font.Bold
            elide: Text.ElideRight
        }

        ListView {
            id: selectContent
            anchors.margins: 10
            anchors.horizontalCenter: content.horizontalCenter
            clip: true
            width: parent.width - 20
            height: root.height - 200
            model: selectModel
            delegate: Item {
                height: 60
                width: parent.width
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    color: mArea.pressed ? "gray" : "transparent"
                }
                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 3
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 20
                    text: model.name
                }
                MouseArea {
                    id: mArea
                    anchors.fill: parent
                    onClicked: {
                        selectedIndex = index
                        hide()
                    }
                }
            }
        }

        InputArea {
            id: newName
            visible: false
            anchors.left: parent.left
            anchors.leftMargin: 10
            width: parent.width - 20
            onAccepted: {
                if (text.length > 0) {
                    root.tryAddGroup(text)
                }
            }
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: btNew.width + (btNew.visible ? 10 : 0) + btCancel.width
            height: btCancel.height

            DialogButton {
                id: btNew
                anchors.left: parent.left
                width: visible ? (content.width / 2 - 15) : 0
                visible: canAdd
                text: newName.visible ? "Ok" : "New item"
                onClicked: {
                    if (newName.visible) {
                        if (newName.text.length > 0) {
                            root.tryAddGroup(newName.text)
                        }
                    }
                    else {
                        newName.visible = true
                    }
                }
            }

            DialogButton {
                id: btCancel
                anchors.left: btNew.visible ? btNew.right : parent.left
                anchors.leftMargin: btNew.visible ? 10 : 0
                width: btNew.visible ? (content.width / 2 - 15) : 200
                text: "Cancel"
                onClicked: {
                    selectedIndex = -1
                    hide()
                }
            }
        }
    }
} 
