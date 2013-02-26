import QtQuick 1.1
import QtMozilla 1.0

Item {
    id: root

    property variant flickableItem

    anchors {
        fill: flickableItem
        margins: 5
    }

    property bool __movingHorizontally: flickableItem ? flickableItem.movingHorizontally : false
    property bool __movingVertically: flickableItem ? flickableItem.movingVertically : false

    property real __viewWidth: flickableItem ? flickableItem.width - (anchors.margins * 2) : 0
    property real __viewHeight: flickableItem ? flickableItem.height - (anchors.margins * 2) : 0

    property int __hideTimeout: 800
    property real __indicatorSize: 5
    property real __indicatorBorder: 1

    Item {
        id: horizontalIndicator
        opacity: 0

        width: __viewWidth - __indicatorSize
        height: __indicatorSize

        anchors.bottom: root.bottom

        Rectangle {
            id: horRect
            radius: 10
            color: "black"
            border.color: "gray"
            border.width: 1
            opacity: 0.5
            smooth: true

            width: flickableItem ? flickableItem.visibleArea.widthRatio
                                   * horizontalIndicator.width : 0
            height: __indicatorSize

            x: flickableItem ? flickableItem.visibleArea.xPosition : 0
            y: 0
        }

        states: [
            State {
                name: "show"
                when: __movingHorizontally
                PropertyChanges {
                    target: horizontalIndicator
                    opacity: 1
                }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation {
                    target: horizontalIndicator
                    properties: "opacity"
                    duration: __hideTimeout
                }
            }
        ]
    }

    Item {
        id: verticalIndicator
        opacity: 0

        width: __indicatorSize
        height: __viewHeight - __indicatorSize

        anchors.right: root.right

        Rectangle {
            id: vertRect
            radius: 10
            color: "black"
            border.color: "gray"
            border.width: 1
            opacity: 0.5
            smooth: true

            width: __indicatorSize
            height: flickableItem ? flickableItem.visibleArea.heightRatio
                                    * verticalIndicator.height : 0

            x: 0
            y: flickableItem ? flickableItem.visibleArea.yPosition : 0
        }

        states: [
            State {
                name: "show"
                when: __movingVertically
                PropertyChanges {
                    target: verticalIndicator
                    opacity: 1
                }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation {
                    target: verticalIndicator
                    properties: "opacity"
                    duration: __hideTimeout
                }
            }
        ]
    }
}
