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
        }
        ListElement {
            name: "Save by link url as..."
        }
        ListElement {
            name: "Copy link url to clipboard"
        }
        ListElement {
            name: "Open image url in a new window"
        }
        ListElement {
            name: "Save by image url as..."
        }
        ListElement {
            name: "Copy image url to clipboard"
        }
    }

    delegate: OverlayButton {
        text: model.name
        height: (model.index < 3) ? (contextLinkHref.length > 0 ? 80 : 0) : (contextImageSrc.length > 0 ? 80 : 0)
        width: root.width
        visible: height > 0
        fixedHeight: 30
        onClicked: {
            root.selected()
            switch (model.index) {
                case 0: MozContext.newWindow(contextLinkHref)
                    break
                case 1: saveFile(contextLinkHref)
                    break
                case 2: MozContext.setClipboard(contextLinkHref)
                    break
                case 3: MozContext.newWindow(contextImageSrc)
                    break
                case 4: saveFile(contextImageSrc)
                    break
                case 5: MozContext.setClipboard(contextImageSrc)
                    break
            }
        }
    }
}
