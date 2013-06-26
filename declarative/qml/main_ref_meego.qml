import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import QtMozilla 1.0

PageStackWindow {
    id: appWindow
    showStatusBar: false
    initialPage: MainPageRef {}

    Component.onCompleted: {
        screen.allowedOrientation = Screen.All
    }
}
