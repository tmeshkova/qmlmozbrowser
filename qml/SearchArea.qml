import QtQuick 1.0

Rectangle {
    id: root
    color: "white"
    height: searchText.height + 20

    function doSearch(text) {
        webViewport.child.sendAsyncMessage("embedui:find", { text: text, backwards: false, again: false })
    }

    function doSearchAgain(text, backwards) {
        webViewport.child.sendAsyncMessage("embedui:find", { text: text, backwards: backwards, again: true })
    }

    Connections {
        target: webViewport.child
        onRecvAsyncMessage: {
            switch (message) {
                case "embed:find": {
                    switch (data.r) {
                      case 0: {
                        //console.log("Page Find: found");
                        break;
                      }
                      case 1: {
                        //console.log("Page Find:  not found")
                        infoBanner.show("Not found", "black", "../icons/context-search.png")
                        break;
                      }
                      case 2: {
                        //console.log("Page Find: found, wrapped");
                        infoBanner.show("Search wrapped", "black", "../icons/context-search.png")
                        break;
                      }
                      case 3: {
                        //console.log("Page Find: pending");
                        break;
                      }
                    }
                    break;
                }
            }
        }
    }

    InputArea {
        id: searchText
        anchors.verticalCenter: root.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: doSearchAgain.left
        anchors.rightMargin: 10
        disableUnfocusOnAccept: true

        onAccepted: {
            root.doSearch(searchText.text)
        }
    }

    OverlayButton {
        id: doSearchAgain
        height: 42
        width: 42
        anchors.verticalCenter: root.verticalCenter
        anchors.right: doSearchBackwards.left
        anchors.rightMargin: 10
        iconSource: "../icons/search-next.png"

        onClicked: {
            root.doSearchAgain(searchText.text, false)
        }
    }

    OverlayButton {
        id: doSearchBackwards
        height: 42
        width: 42
        anchors.verticalCenter: root.verticalCenter
        anchors.right: closeSearch.left
        anchors.rightMargin: 10
        iconSource: "../icons/search-back.png"

        onClicked: {
            root.doSearchAgain(searchText.text, true)
        }
    }

    OverlayButton {
        id: closeSearch
        height: 42
        width: 42
        anchors.verticalCenter: root.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        iconSource: "../icons/close.png"

        onClicked: {
            root.visible = false
        }
    }
} 
