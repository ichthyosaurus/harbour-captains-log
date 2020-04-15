import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property string creation_date_p
    property string modify_date_p
    property int mood_p
    property string title_p
    property string entry_p
    property int favorite_p
    property string hashtags_p
    property int rowid

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SilicaFlickable {

        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content

            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - (2*Theme.horizontalPageMargin)
            spacing: Theme.paddingMedium

            PageHeader {
                id: header
                title: title_p
            }

            Label {
                id: createDateLabel
                width: parent.width
                color: Theme.highlightColor
                text: qsTr("Created on: ")+creation_date_p
            }
            Label {
                id: modDateLabel
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.highlightColor
                text: qsTr("Last change: ")+modify_date_p
            }

            Row {
                spacing: Theme.paddingSmall

                Icon {
                    id: favStar
                    source: favorite_p === 1 ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
                }

                // Like thumb is rotated to show mood
                Icon {
                    anchors.verticalCenter: favStar.verticalCenter
                    source: "image://theme/icon-s-like"
                    rotation: {
                        switch(mood_p) {
                        case 0:
                            return 0;
                        case 1:
                            return 35;
                        case 2:
                            return 75;
                        case 3:
                            return 120;
                        case 4:
                            return 180
                        }
                    }
                }
            }
            TextArea {
                id: entryArea

                width: parent.width
                label: qsTr("Your Entry")
                wrapMode: TextEdit.WordWrap
                readOnly: true
                text: entry_p
            }
            TextArea {
                id: hashtagArea

                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                label: qsTr("#Hashtags")
                readOnly: true
                text: hashtags_p.length > 0 ? "# "+hashtags_p : ""
            }
        }
    }
}

