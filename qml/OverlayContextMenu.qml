import Qt 4.7
import QtQuick 1.0

ListView {
    id: root 

    property string contextImageSrc: ""
    property string contextLinkHref: ""
    property variant lastContextInfo: null
    property bool selectionInfoAvialable: false

    visible: false
    height: (contextLinkHref.length > 0 ? 240 : 0) + (contextImageSrc.length > 0 ? 240 : 0) + 80
    clip: true

    signal startSelectionRequested()
    signal selected()

    model: ListModel {
        ListElement {
            name: "Open link url in a new window"
            icon: "../icons/context-window-url5.png"
        }
        ListElement {
            name: "Save by link url as..."
            icon: "../icons/context-window-url3.png"
        }
        ListElement {
            name: "Copy link url to clipboard"
            icon: "../icons/context-clipboard-url.png"
        }
        ListElement {
            name: "Open image url in a new window"
            icon: "../icons/context-window-image5.png"
        }
        ListElement {
            name: "Save by image url as..."
            icon: "../icons/context-window-image4.png"
        }
        ListElement {
            name: "Copy image url to clipboard"
            icon: "../icons/context-clipboard-image2.png"
        }
        ListElement {
            name: "Select text on page"
            //icon: "../icons/context-clipboard-image2.png"
        }
    }

    delegate: OverlayButton {
        text: model.name
        iconSource: model.icon
        height: (model.index < 3) ? (contextLinkHref.length > 0 ? 80 : 0) : (model.index == 6 ? 80 : (contextImageSrc.length > 0 ? 80 : 0))
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
                case 6: root.startSelectionRequested()
                    break
            }
        }
    }
}
