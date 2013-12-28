import QtQuick 2.0
import Qt5Mozilla 1.0

Item {
    id: mainScope
    objectName: "mainScope"

    property alias webview: webViewport

    signal pageTitleChanged(string title)
    signal newWindow(string url)

    Rectangle {
        id: navigationBar
        color: "#efefef"
        height: 38
        visible: true
        z: webViewport.z + 1
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        Rectangle {
            color: "white"
            height: 26
            border.width: 1
            border.color: "#bfbfbf"
            radius: 3
            anchors {
                left: parent.left
                right: parent.right
                margins: 6
                verticalCenter: parent.verticalCenter
            }
            TextInput {
                id: addressLine
                clip: true
                selectByMouse: true
                horizontalAlignment: TextInput.AlignLeft
                font {
                    pointSize: 11
                    family: "Sans"
                }
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    margins: 6
                }
                Keys.onReturnPressed:{
                    webViewport.load(addressLine.text)
                }
            }
        }
    }

    QmlMozView {
        id: webViewport
        objectName: "webViewport"
        clip: false
        visible: true
        focus: true

        anchors {
            top: navigationBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        Connections {
            target: webViewport
            onViewInitialized: {
                print("QmlMozView Initialized");
                if (startURL.length != 0 && createParentID == 0) {
                    webViewport.load(startURL)
                }
                else if (createParentID == 0) {
                    webViewport.load("about:blank")
                }
            }
        }
    }
}
