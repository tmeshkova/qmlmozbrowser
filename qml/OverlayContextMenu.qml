import Qt 4.7
import QtQuick 1.0

ListView {
    id: root 

    property string contextImageSrc: ""
    property string contextLinkHref: ""
    property variant context

    visible: false
    height: (contextLinkHref.length > 0 ? 160 : 0) + (contextImageSrc.length > 0 ? 160 : 0)
    clip: true

    signal selected()

    model: ListModel {
        ListElement {
            name: "Open link url in a new window"
        }
        ListElement {
            name: "Copy link url to clipboard"
        }
        ListElement {
            name: "Open image url in a new window"
        }
        ListElement {
            name: "Copy image url to clipboard"
        }
    }

    delegate: OverlayButton {
        text: model.name
        height: (model.index < 2) ? (contextLinkHref.length > 0 ? 80 : 0) : (contextImageSrc.length > 0 ? 80 : 0)
        width: root.width
        visible: height > 0
        fixedHeight: 30
        onClicked: {
            root.selected()
            switch (model.index) {
                case 0: context.newWindow(contextLinkHref)
                    break
                case 1: context.setClipboard(contextLinkHref)
                    break
                case 2: context.newWindow(contextImageSrc)
                    break
                case 3: context.setClipboard(contextImageSrc)
                    break
            }
        }
    }
}
