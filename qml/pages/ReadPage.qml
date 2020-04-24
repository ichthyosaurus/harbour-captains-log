import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property string creationDate
    property string modificationDate
    property int mood
    property string title
    property string entry
    property bool favorite
    property string hashtags
    property int rowid
    property int index

    property bool editable: true
    allowedOrientations: Orientation.All

    Connections {
        target: appWindow
        onEntryFavoriteToggled: {
            if (index !== page.index) return
            favorite = isFavorite
        }
        onEntryUpdated: {
            if (rowid !== page.rowid) return
            modificationDate = changeDate
            page.mood = mood
            page.title = title
            page.entry = entry
            hashtags = hashs
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge

        PullDownMenu {
            enabled: editable
            MenuItem {
                text: qsTr("Edit")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("WritePage.qml"), {
                                       "title": title, "mood": mood, "entry": entry,
                                       "hashtags": hashtags, "rowid": rowid,
                                       "creationDate": creationDate, "index": index,
                                       "acceptDestination": "" // return to the calling page
                                   })
                }
            }
        }

        Column {
            id: content
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                id: header
                title: parseDate(creationDate).toLocaleString(Qt.locale(), "dddd");
                description: parseDate(creationDate).toLocaleString(Qt.locale(), dateTimeFormat)
                _titleItem.truncationMode: TruncationMode.Fade
                _titleItem.horizontalAlignment: Text.AlignRight
            }

            Label {
                id: modDateLabel
                visible: modificationDate !== ""
                anchors {
                    left: parent.left; leftMargin: Theme.horizontalPageMargin
                    right: parent.right; rightMargin: Theme.horizontalPageMargin
                }
                horizontalAlignment: Text.AlignRight
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryHighlightColor
                text: modificationDate !== "" ? qsTr("Last change: %1").arg(parseDate(modificationDate).toLocaleString(Qt.locale(), dateTimeFormat)) : ""
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall
                onClicked: setFavorite(index, rowid, !favorite)
                enabled: editable

                HighlightImage {
                    id: favStar
                    anchors { verticalCenter: parent.verticalCenter; right: parent.right }
                    highlighted: parent.down
                    source: favorite ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
                }

                Label {
                    id: moodLabel
                    anchors { verticalCenter: favStar.verticalCenter; left: parent.left; leftMargin: Theme.horizontalPageMargin }
                    color: Theme.highlightColor; text: qsTr("mood:")
                }

                Label {
                    anchors {
                        verticalCenter: favStar.verticalCenter
                        left: moodLabel.right; leftMargin: Theme.paddingSmall
                        right: favStar.left; rightMargin: Theme.paddingMedium
                    }
                    color: Theme.primaryColor
                    text: moodTexts[mood]
                    truncationMode: TruncationMode.Fade
                }
            }

            Label {
                anchors {
                    right: parent.right; rightMargin: Theme.horizontalPageMargin
                    left: parent.left; leftMargin: Theme.horizontalPageMargin
                }
                visible: title !== ""
                text: title
                wrapMode: Text.WordWrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
            }

            TextArea {
                id: entryArea
                visible: !moodImage.visible
                width: parent.width
                wrapMode: TextEdit.WordWrap
                // horizontalAlignment: Text.AlignJustify
                readOnly: true
                text: entry
            }

            TextArea {
                id: hashtagArea
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                readOnly: true
                text: hashtags.length > 0 ? "# "+hashtags : ""
            }

            Item { visible: moodImage.visible; width: parent.width; height: Theme.paddingLarge }

            HighlightImage {
                id: moodImage
                visible: entry === ""
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(page.width, page.height)/4; height: width
                fillMode: Image.PreserveAspectFit
                color: Theme.primaryColor
                opacity: Theme.opacityLow
                source: "../images/mood-%1.png".arg(String(mood))
            }
        }
    }
}

