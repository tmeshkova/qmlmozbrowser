import Qt 4.7
import QtQuick 1.0

Rectangle {
    id : root
    visible: true
    color: "white"

    Connections {
        target: MozContext
        onRecvObserve: {
            if (message == "embed:download") {
                switch (data.msg) {
                    case "dl-list": {
                        downloadsListModel.clear()
                        console.log("data count: " + data.list.length);
                        console.log("appending download items");
                        for (var i=0; i<data.list.length; i++) {
                            console.log("appending: " + data.list[i].id + " from:" + data.list[i].from + " to:" + data.list[i].to)
                            downloadsListModel.append({id: data.list[i].id,
                                                       from: data.list[i].from, 
                                                       to: data.list[i].to,
                                                       cur: data.list[i].cur,
                                                       max: data.list[i].max,
                                                       state: data.list[i].state,
                                                       percent: data.list[i].percent,
                                                       speed: 0})
                        }
                        console.log("items appended")
                        break;
                    }
                    default:
                        break;
                }
            }
        }
    }

    function show() {
        animShow.running = true
        MozContext.sendObserve("embedui:download", { msg: "requestDownloadsList" })
    }

    function hide() {
        animHide.running = true
    }

    function bytesToSize(bytes) {
        var sizes = [ 'n/a', 'bytes', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB'];
        var i = +Math.floor(Math.log(bytes) / Math.log(1024));
        return  (bytes / Math.pow(1024, i)).toFixed( i ? 1 : 0 ) + ' ' + sizes[ isNaN( bytes ) ? 0 : i+1 ];
    }

    function stateToText(value) {
        switch (value) {
            default: return "Not downloading"
            case 0: return "Downloading"
            case 1: return "Finished"
            case 2: return "Failed"
            case 3: return "Cancelled"
            case 4: return "Paused"
            case 5: return "Queued"
            case 6: return "Blocked parental"
            case 7: return "Scanning"
            case 8: return "Dirty"
        }
    }

    function stateToColor(value) {
        switch (value) {
            default: return "transparent"
            case 0: return "black"
            case 1: return "green"
            case 2: return "red"
            case 3: return "blue"
            case 4: return "cyan"
            case 5: return "lime"
            case 6: return "red"
            case 7: return "lime"
            case 8: return "red"
        }
    }

    ListModel {
        id: downloadsListModel
    }

    ParallelAnimation {
        id: animHide
        PropertyAnimation {
            target: root
            properties: "x"
            from: 0; to: -root.parent.width; duration: 300;
        }
        PropertyAnimation {
            target: root
            properties: "opacity"
            from: 1.0; to: 0.01; duration: 300;
        }
    }

    ParallelAnimation {
        id: animShow
        PropertyAnimation {
            target: root
            properties: "x"
            from: root.parent.width; to: 0; duration: 300;
        }
        PropertyAnimation {
            target: root
            properties: "opacity"
            from: 0.01; to: 1.0; duration: 300;
        }
    }

    Rectangle {
        id: title
        anchors.top: root.top
        anchors.left: root.left
        anchors.right: root.right
        height: 80
        color: "#dddddd"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                downloadsList.hideAll()
            }
        }

        OverlayButton {
            id: back
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            width: 60
            height: 60
            enabled: true
            iconSource: "../icons/backward.png"

            onClicked: {
                root.hide()
            }
        }

        Text {
            anchors.verticalCenter: back.verticalCenter
            anchors.left: back.right
            anchors.leftMargin: 20
            text: "Downloads"
            font.pixelSize: 40
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: "black"
        }
    }

    ListView {
        id: downloadsList
        signal hideAll()
        clip: true
        anchors.top: title.bottom
        anchors.left: root.left
        anchors.right: root.right
        anchors.bottom: root.bottom
        anchors.margins: 10
        spacing: 10
        model: downloadsListModel
        delegate: Rectangle {
            width: parent.width-border.width
            height: content.height
            property bool showControls: false
            radius: 5
            color: showControls ? "#dddddd" : "#f0f0f0"
            border.width: 1
            border.color: stateToColor(model.state)

            Connections {
                target: MozContext
                onRecvObserve: {
                    if (message == "embed:download") {
                        if (data.id == id) {
                            switch (data.msg) {
                                case "dl-progress": {
                                    downloadsListModel.setProperty(index, "cur", data.cur)
                                    downloadsListModel.setProperty(index, "max", data.max)
                                    downloadsListModel.setProperty(index, "speed", data.speed)
                                    downloadsListModel.setProperty(index, "percent", data.percent)
                                    break;
                                }
                                case "dl-state":
                                case "dl-security": {
                                    downloadsListModel.setProperty(index, "state", data.state)
                                    break;
                                }
                                default: {
                                    console.log(data.msg + " message for id:" + data.id + " state:" + data.state)
                                    downloadsListModel.setProperty(index, "state", data.state)
                                    break;
                                }
                            }
                        }
                    }
                }
            }

            Connections {
                target: downloadsList
                onHideAll: {
                    showControls = false
                }
            }

            Item {
                id: content
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                height: progress.height + infoText.height + fromText.height + toText.height + controls.height + 20 + (controls.visible ? 10 : 0)

                Rectangle {
                    color: "white"
                    radius: 3
                    height: 20
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    smooth: true
                }

                Rectangle {
                    color: stateToColor(model.state)
                    radius: 3
                    anchors.left: parent.left
                    anchors.top: parent.top
                    height: 20
//                    width: (cur / (max / 100)) * (parent.width / 100)
                    width: parent.width * (percent / 100)
                    smooth: true
                }

                Rectangle {
                    id: progress
                    color: "transparent"
                    border.color: "black"
                    border.width: 1
                    radius: 3
                    height: 20
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    smooth: true
                }

                Text {
                    id: infoText
                    anchors.top: progress.bottom
                    font.pixelSize: 20
                    text: bytesToSize(cur) + " of " + bytesToSize(max) + " | " + percent + "%\n"
                        + stateToText(model.state) + (model.state == 0 ? (" | Speed: " + bytesToSize(speed) + "/s") : "" )
                }

                Text {
                    id: fromText
                    anchors.top: infoText.bottom
                    width: parent.width
                    font.pixelSize: 20
                    wrapMode: Text.WrapAnywhere
                    text: from
                }

                Text {
                    id: toText
                    anchors.top: fromText.bottom
                    width: parent.width
                    font.pixelSize: 20
                    wrapMode: Text.WrapAnywhere
                    text: to
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onPressed: {
                        downloadsList.hideAll()
                        showControls = true
                    }
                    onDoubleClicked: {
                        if (model.state == 1) {
                            QmlHelperTools.openFileBySystem(model.to)
                        }
                    }
                }

                Item {
                    id: controls
                    visible: showControls
                    height: visible ? 60 : 0
                    width: parent.width
                    anchors.top: toText.bottom
                    anchors.topMargin: 10

                    OverlayButton {
                        id: pauseResumeButton
                        width: 60
                        height: 60
                        anchors.left: parent.left
                        iconSource: "../icons/download-" + (model.state == 0 ? "pause" : "start") + ".png"
                        visible: (model.state == 0 || model.state == 4)
                        onClicked: {
                            console.log("pauseResumeButton clicked")
                            MozContext.sendObserve("embedui:download", { msg: (model.state == 0 ? "pauseDownload" : "resumeDownload"), id: id })
                        }
                    }

                    OverlayButton {
                        id: stopButton
                        width: 60
                        height: 60
                        anchors.left: pauseResumeButton.visible ? pauseResumeButton.right : parent.left
                        anchors.leftMargin: pauseResumeButton.visible ? 15 : 0
                        iconSource: "../icons/download-stop.png"
                        visible: (model.state == 0 || model.state == 4)
                        onClicked: {
                            console.log("stopButton clicked")
                            MozContext.sendObserve("embedui:download", { msg: "cancelDownload", id: id })
                        }
                    }

                    OverlayButton {
                        id: retryButton
                        width: 60
                        height: 60
                        anchors.left: stopButton.visible ? stopButton.right : ( pauseResumeButton.visible ? pauseResumeButton.right : parent.left)
                        anchors.leftMargin: pauseResumeButton.visible ? 15 : 0
                        iconSource: "../icons/download-retry.png"
                        visible: (model.state != 0 && model.state != 4)
                        onClicked: {
                            console.log("removeButton clicked")
                            MozContext.sendObserve("embedui:download", { msg: "retryDownload", id: id })
                        }
                    }

                    OverlayButton {
                        id: removeButton
                        width: 60
                        height: 60
                        anchors.left: retryButton.right
                        anchors.leftMargin: 15
                        iconSource: "../icons/download-remove.png"
                        visible: (model.state != 0 && model.state != 4)
                        onClicked: {
                            console.log("removeButton clicked")
                            MozContext.sendObserve("embedui:download", { msg: "removeDownload", id: id })
                            downloadsListModel.remove(index)
                        }
                    }
                }
            }
        }
    }
}