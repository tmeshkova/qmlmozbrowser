import Qt 4.7
import QtQuick 1.0 

Item {
    id: root
    visible: false
    property string currPath
    property variant selectedItems
    property int pickerMode: 0
    property int winid: 0
    property bool syncLock: false
    property string syncFileName: ""
    signal selected(variant path, bool accepted)

    function done(path, accepted) {
        if (!syncLock) {
            selected(path, accepted)
        }
        else {
            syncFileName = "file://" + path[0]
            syncLock = false
        }
    }

    function getFileSync(mode, path, name) {
        syncFileName = ""
        syncLock = true
        show(mode, path, "", name, 0)
        while (syncLock) {
            QmlHelperTools.processEvents()
        }
        root.visible = false
        return syncFileName
    }

    function show(mode, path, title, name, winId) {
        titleText.text = title ? title : getTitleByMode(mode)
        fileName.text = name
        root.winid = winId
        pickerMode = mode
        currPath = path
        var emptyArr = []
        root.selectedItems = emptyArr
        folderContent.model = null
        folderContent.model = QmlHelperTools.getFolderModel(currPath)
        root.visible = true
    }

    function getTitleByMode(mode) {
        switch (mode) {
            case 0: return "Open file"
            case 1: return "Save file"
            case 2: return "Open directory"
            case 3: return "Select files"
            default: return " "
        }
    }

    MouseArea {
        id: rejectArea
        anchors.fill: parent
        onClicked: {
            root.done([ "null" ], false)
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

        Text {
            id: pathText
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
            height: root.height - 160 - (fileName.visible ? fileName.height : 0)
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
                            if (pickerMode == 3) {
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
                                fileName.setFocus(false)
                                root.done([ item ], true)
                            }
                        }
                    }
                }
            }
        }

        InputArea {
            id: fileName
            visible: pickerMode == 1
            anchors.left: parent.left
            anchors.leftMargin: 10
            width: parent.width - 20
            onAccepted: {
                fileName.setFocus(false)
                root.done([ currPath + "/" + fileName.text ], true)
            }
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: btOk.visible ? (parent.width - 20) : btCancel.width
            height: btCancel.height

            DialogButton {
                id: btOk
                anchors.left: parent.left
                width: parent.width / 2 - 5
                visible: pickerMode > 0
                text: "Done"
                onClicked: {
                    fileName.setFocus(false)
                    switch (pickerMode) {
                        case 1:
                            root.done([ currPath + "/" + fileName.text ], true)
                            break;
                        case 2:
                            root.done([ currPath ], true)
                            break;
                        case 3:
                            root.done(root.selectedItems, true)
                            break;
                        default:
                            break
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
                    fileName.setFocus(false)
                    root.done([ "null" ], false)
                }
            }
        }
    }
}