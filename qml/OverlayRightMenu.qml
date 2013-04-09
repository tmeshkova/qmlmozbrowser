import Qt 4.7
import QtMozilla 1.0
import QtQuick 1.0

Rectangle {
    id: root
    color: "white"
    width: 111

    function toggle() {
        if (root.anchors.rightMargin == 0) {
            hide()
        }
        else {
            show()
        }
    }

    function show() {
        root.anchors.rightMargin = 0
    }

    function hide() {
        root.anchors.rightMargin = -111
    }

    Rectangle {
        id: rightSeparator
        anchors.top: parent.top
        anchors.left: parent.left
        width: 1
        height: parent.height
        color: "black"
    } 

    Flickable {
        id: flick
        clip: true
        anchors.right: parent.right
        anchors.left: rightSeparator.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        flickableDirection: Flickable.VerticalFlick
        pressDelay: 200
        contentHeight: buttonsColumn.height

        Column {
            id: buttonsColumn
            width: 110
            spacing: 10

            OverlayButton {
                id: goStart

                width: 100
                height: 100
                anchors.horizontalCenter: parent.horizontalCenter

                iconSource: "../icons/" + (startPage.visible ? "backward" : "home") + ".png"

                onClicked: {
                    if (startPage.visible) {
                        startPage.hide()
                    }
                    else {
                        startPage.show()
                    }
                    root.toggle()
                }
            }

            OverlayButton {
                id: newPage

                width: 100
                height: 100
                anchors.horizontalCenter: parent.horizontalCenter

                iconSource: "../icons/plus.png"

                onClicked: {
                    MozContext.newWindow("about:blank", 0)
                    root.toggle()
                }
            }

            OverlayButton {
                id: favorite
                property bool isFavorite: bookmarksPage.checkUrl(webViewport.child.url)
                width: 100
                height: 100
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !startPage.visible
                iconSource: "../icons/" + (isFavorite ? "" : "un") +"favorite.png"

                onClicked: {
                    if (isFavorite) {
                        removeBookmark(webViewport.child.url)
                    }
                    else {
                        addBookmark(webViewport.child.url, webViewport.child.title, "uncategorized", 0)
                    }
                    isFavorite = bookmarksPage.checkUrl(webViewport.child.url)
                }
            }

            OverlayButton {
                id: settings

                width: 100
                height: 100
                anchors.horizontalCenter: parent.horizontalCenter

                iconSource: "../icons/settings.png"

                onClicked: {
                    settingsPage.show()
                    root.toggle()
                }
            }

            OverlayButton {
                id: history

                width: 100
                height: 100
                anchors.horizontalCenter: parent.horizontalCenter

                iconSource: "../icons/history.png"

                onClicked: {
                    historyPage.show()
                    root.toggle()
                }
            }

            OverlayButton {
                id: bookmarks

                width: 100
                height: 100
                anchors.horizontalCenter: parent.horizontalCenter

                iconSource: "../icons/bookmarks.png"

                onClicked: {
                    bookmarksPage.show()
                    root.toggle()
                }
            }

            OverlayButton {
                id: downloads

                width: 100
                height: 100
                anchors.horizontalCenter: parent.horizontalCenter

                iconSource: "../icons/download.png"

                onClicked: {
                    downloadsPage.show()
                    root.toggle()
                }
            }
        }
    }
}
