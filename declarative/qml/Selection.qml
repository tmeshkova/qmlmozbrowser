import QtQuick 1.0

Item {
    id: root
    visible: false
    property bool selectMulti: false

    signal selected(variant data)
    signal canceled()

    function done() {
        var result = []
        var item

        for (var i = 0; i < selectModel.count; i++) {
            item = selectModel.get(i)
            result.push({
                "selected": item.selected,
                "index": item.index
            })
        }
        root.visible = false
        selected(result)
    }

    function cancel() {
        root.visible = false
        canceled()
    }

    function show(data) {
        selectMulti = data.multiple
        selectModel.clear()
        root.visible = true
        for (var i=0; i < data.options.length; i++) {
            selectModel.append(data.options[i])
        }
    }

    ListModel {
        id: selectModel
    }

    MouseArea {
        id: rejectArea
        anchors.fill: parent
        onClicked: {
            cancel()
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
            text: "Select item"
        }

        ListView {
            id: selectContent
            anchors.margins: 10
            anchors.horizontalCenter: content.horizontalCenter
            clip: true
            width: parent.width - 20
            height: root.height - 160

            section {
                property: "group"
                delegate: Text {
                    font.pixelSize: 30
                    text: section
                }
            }

            model: selectModel
            delegate: Item {
                height: 60
                width: parent.width
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    color: mArea.pressed ? "gray" : (model.selected ? "lightgray" : "transparent")
                }
                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 3
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 20
                    text: model.label
                }
                MouseArea {
                    id: mArea
                    anchors.fill: parent
                    enabled: !model.disabled
                    onClicked: {
                        if (selectMulti) {
                            selectModel.setProperty(index, "selected", !model.selected)
                        } else {
                            selectModel.setProperty(index, "selected", true)
                            for (var i = 0; i < selectModel.count; i++) {
                                if (i !== index) {
                                    selectModel.setProperty(i, "selected", false)
                                }
                            }
                            done()
                        }
                    }
                }
            }
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: btOk.width + (btOk.visible ? 10 : 0) + btCancel.width
            height: btCancel.height

            DialogButton {
                id: btOk
                anchors.left: parent.left
                width: visible ? (content.width / 2 - 15) : 0
                visible: selectMulti > 0
                text: "Done"
                onClicked: {
                    done()
                }
            }

            DialogButton {
                id: btCancel
                anchors.left: btOk.visible ? btOk.right : parent.left
                anchors.leftMargin: btOk.visible ? 10 : 0
                width: btOk.visible ? (content.width / 2 - 15) : 200
                text: "Cancel"
                onClicked: {
                    cancel()
                }
            }
        }
    }
}