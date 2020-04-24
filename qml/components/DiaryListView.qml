import QtQuick 2.0
import Sailfish.Silica 1.0

SilicaListView {
    id: diaryList
    VerticalScrollDecorator { flickable: diaryList }
    contentHeight: Theme.itemSizeHuge
    spacing: Theme.paddingMedium

    property bool editable: true
    delegate: EntryElement { editable: diaryList.editable }

    section {
        property: "day"
        delegate: Item {
            width: parent.width
            height: childrenRect.height + Theme.paddingSmall

            Label {
                id: label
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                truncationMode: TruncationMode.Fade
                color: Theme.highlightColor
                text: parseDate(section + " | 0:0").toLocaleString(Qt.locale(), fullDateFormat)
            }
            Separator {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: label.baseline
                    topMargin: 8
                }
                width: parent.width-2*Theme.horizontalPageMargin
                horizontalAlignment: Qt.AlignHCenter
                color: Theme.highlightColor
            }
        }
    }

    footer: Item { width: parent.width; height: Theme.horizontalPageMargin }
}
