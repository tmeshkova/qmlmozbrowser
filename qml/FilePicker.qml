import Qt 4.7
import QtQuick 1.0 

Item {
    id: root
    visible: false
    property string currPath
    property variant selectedItems
    property int pickerMode: 0
    property int winid: 0
    signal selected(variant path, bool accepted)

    function show(mode, path, winId) {
        console.log("winId: " + winId)
        root.winid = winId
        pickerMode = mode
        currPath = path
        var emptyArr = []
        root.selectedItems = emptyArr
        folderContent.model = null
        folderContent.model = QmlHelperTools.getFolderModel(currPath)
        root.visible = true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.selected("null", false)
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
        id: fancy
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
        anchors.centerIn: parent
        width: Math.min(Math.min(parent.width, parent.height) - 10, 400)
        spacing: 10

        Text {
            id: titleText
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 20
            font.weight: Font.Bold
            elide: Text.ElideRight
            text: pickerMode == 0 ? "Select file" : (pickerMode == 1 ? "Select folder" : "Select files") + (pickerMode == 2 ? ". Items selected: " + selectedItems.length : "")
        }

        Text {
            id: messageText
            wrapMode: Text.WrapAnywhere
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 20
            font.pixelSize: 20
            text: currPath
        }

        ListView {
            id: folderContent
            anchors.margins: 10
            anchors.horizontalCenter: content.horizontalCenter
            clip: true
            width: parent.width - 20
            height: root.height - 160
            model: QmlHelperTools.getFolderModel(currPath)
            delegate: Item {
                property bool selected: false
                height: 60
                width: parent.width
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    color: mArea.pressed ? "gray" : (selected ? "lightgray" : "transparent")
                }
                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 3
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: modelData[1] == 0 ? 30 : 20
                    text: modelData[0]
                }
                MouseArea {
                    id: mArea
                    anchors.fill: parent
                    onClicked: {
                        var item = currPath + "/" + modelData[0]
                        if (modelData[1] == 0) {
                            currPath = QmlHelperTools.getFolderCleanPath(item)
                            var emptyArr = []
                            root.selectedItems = emptyArr
                            folderContent.model = null
                            folderContent.model = QmlHelperTools.getFolderModel(currPath)
                        }
                        else {
                            if (pickerMode > 1) {
                                var arr = selectedItems
                                var itemIndex = arr.indexOf(item)
                                if (itemIndex > -1) {
                                    arr.splice(itemIndex, 1)
                                    selected = false
                                }
                                else {
                                    arr.push(item)
                                    selected = true
                                }
                                selectedItems = arr
                                arr = []
                            }
                            else if (pickerMode == 0) {
                                root.selected(item, true)
                            }
                        }
                    }
                }
            }
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: btOk.visible ? parent.width - 20 : btCancel.width
            height: btCancel.height

            DialogButton {
                id: btOk
                anchors.left: parent.left
                width: parent.width / 2 - 5
                visible: pickerMode > 0
                text: pickerMode > 1 ? "Done" : "Select"
                onClicked: {
                    if (pickerMode == 1) {
                        root.selected(currPath, true)
                    }
                    else {
                        root.selected(root.selectedItems, true)
                    }
                }
            }

            DialogButton {
                id: btCancel
                anchors.left: btOk.visible ? btOk.right : parent.left
                anchors.leftMargin: btOk.visible ? 10 : 0
                width: btOk.visible ? (parent.width / 2 - 5) : 200
                text: "Cancel"
                onClicked: {                  
                    root.selected("null", false)
                }
            }
        }
    }
}