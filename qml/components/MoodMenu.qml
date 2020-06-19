import QtQuick 2.0
import Sailfish.Silica 1.0

ContextMenu {
    id: moodMenu
    property int selectedIndex: 2

    Flow {
        anchors.horizontalCenter: parent.horizontalCenter
        property int maxPerLine: Math.floor(parent.width / Theme.itemSizeMedium)
        property int itemsPerLine: ((maxPerLine > 3) ? 3 : maxPerLine)

        width: itemsPerLine*Theme.itemSizeMedium
        height: Math.ceil(moodTexts.length/itemsPerLine)*Theme.itemSizeMedium

        Repeater {
            model: moodTexts
            delegate: BackgroundItem {
                property bool selected: index === moodMenu.selectedIndex
                width: Theme.itemSizeMedium; height: width
                highlighted: down || selected

                HighlightImage {
                    anchors.centerIn: parent
                    source: "../images/mood-%1.png".arg(index)
                    highlighted: parent.highlighted
                    color: Theme.primaryColor
                    highlightColor: Theme.highlightColor
                }

                onClicked: {
                    moodMenu.selectedIndex = index
                    moodMenu.close()
                }
            }
        }
    }
}
