import QtQuick 1.0
import QtMozilla 1.0

ApplicationWindow {
    id: window
    QmlMozContext { id: mozContext }
    QmlMozView {
        id: webViewport
        visible: true
        focus: true
        anchors.fill: parent
        Connections {
            target: webViewport.child
            onViewInitialized: {
                print("QML View Initialized")
                 webViewport.child.url = "about:mozilla"
            }
        }
    }
    Component.onCompleted: {
        // mozContext.init();
    }
}
