import QtQuick 2.0
import QtMozilla 1.0

Item {
    id: mainScope
    objectName: "mainScope"

    property alias webview: webView

    signal pageTitleChanged(string title)
    signal newWindow(string url)

    Rectangle {
        id: navigationBar
        color: "#efefef"
        height: 38
        z: webView.z + 1
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
            }
        }
    }

    QmlMozView {
        id: webView
        clip: false
        visible: true
        focus: true

        anchors {
            top: navigationBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }
}
