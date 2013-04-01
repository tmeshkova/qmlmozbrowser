import Qt 4.7
import QtQuick 1.0

ListView {
    id: root 

    property string contextImageSrc: ""
    property string contextLinkHref: ""

    visible: false
    height: (contextLinkHref.length > 0 ? 240 : 0) + (contextImageSrc.length > 0 ? 240 : 0)
    clip: true

    signal selected()

    model: ListModel {
        ListElement {
            name: "Open link url in a new window"
            icon: "../icons/context-window-image2.png"
        }
        ListElement {
            name: "Save by link url as..."
            icon: ""
        }
        ListElement {
            name: "Copy link url to clipboard"
            icon: "../icons/context-window-url2.png"
        }
        ListElement {
            name: "Open image url in a new window"
            icon: "../icons/context-window-image2.png"
        }
        ListElement {
            name: "Save by image url as..."
            icon: ""
        }
        ListElement {
            name: "Copy image url to clipboard"
            icon: "../icons/context-window-url2.png"
        }
    }

    delegate: OverlayButton {
        text: model.name
        iconSource: model.icon
        height: (model.index < 3) ? (contextLinkHref.length > 0 ? 80 : 0) : (contextImageSrc.length > 0 ? 80 : 0)
        width: root.width
        visible: height > 0
        fixedHeight: 30
        onClicked: {
            root.selected()
            switch (model.index) {
                case 0: MozContext.newWindow(contextLinkHref, 0)
                    break
                case 1: saveFile(contextLinkHref)
                    break
                case 2: QmlHelperTools.setClipboard(contextLinkHref)
                    break
                case 3: MozContext.newWindow(contextImageSrc, 0)
                    break
                case 4: saveFile(contextImageSrc)
                    break
                case 5: QmlHelperTools.setClipboard(contextImageSrc)
                    break
            }
        }
    }
}
