import QtQuick 2.0
import Sailfish.Silica 1.0

    ListItem {
        id: entryList

        contentHeight: Theme.itemSizeHuge

        function getHashtagText() {
            if(modify_date.length > 0 && hashtags.length > 0) {
                return "Edit: "+modify_date + "\t# "+hashtags
            }
            else if(modify_date.length > 0 && hashtags.length === 0) {
                return "Edit: "+modify_date
            }
            else {
                if(hashtags.length > 0) {return hashtags}
                else {return ""}
            }
        }

        menu: ContextMenu {
            MenuItem {
                text: qsTr("Edit")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../pages/EditPage.qml"), {
                                       title_p: title, mood_p: mood, entry_p: entry,
                                       hashtags_p: hashtags, rowid_p: rowid
                                   })
                }
            }
            MenuItem {
                text: qsTr("Delete")
                onClicked: {
                    entryList.remorseDelete(function () {
                        py.call("diary.delete_entry", [rowid])
                        firstPage.loadModel()
                    })
                }
            }
        }

        onClicked: {
            pageStack.push(Qt.resolvedUrl("../pages/ReadPage.qml"), {
                               creation_date_p: create_date, modify_date_p: modify_date,
                               mood_p: mood, title_p: title,
                               entry_p: entry, favorite_p: favorite,
                               hashtags_p: hashtags, rowid_p: rowid
                           })
        }

        Column {
            id: labels
            spacing: Theme.paddingSmall
            height: parent.height
            anchors {
                left: parent.left; right: icons.right
                leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.paddingMedium
            }

            Label {
                id: createDate
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
                text: create_date
                font.bold: true
            }
            Label {
                id: titleText
                text: title
                width: parent.width
                truncationMode: TruncationMode.Fade
            }

            Label {
                id: entryTextPreview
                text: preview
                width: parent.width
                truncationMode: TruncationMode.Fade
                font.pixelSize: Theme.fontSizeExtraSmall
            }
            Label {
                id: hashtagsAndModify
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryHighlightColor
                text: entryList.getHashtagText()
                truncationMode: TruncationMode.Fade
            }
        }

        BackgroundItem {
            id: icons
            height: parent.height
            width: favStar.width + 2*Theme.paddingLarge
            anchors.right: parent.right

            onClicked: {
                var status = favorite === 1 ? 0 : 1
                py.call("diary.update_favorite", [rowid, status])
                firstPage.loadModel()
            }

            Column {
                id: iconsColumn
                spacing: Theme.paddingSmall
                anchors.horizontalCenter: parent.horizontalCenter

                Icon {
                    id: favStar
                    opacity: Theme.opacityHigh
                    source: favorite === 0 ? "image://theme/icon-m-favorite" : "image://theme/icon-m-favorite-selected"
                }

                Label {
                    // TODO use images instead to be consistent across devices
                    anchors.horizontalCenter: favStar.horizontalCenter
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.primaryColor
                    opacity: 1-Theme.opacityFaint*mood
                    text: {
                        switch(mood) {
                        case 0:
                            return "😄";
                        case 1:
                            return "😊";
                        case 2:
                            return "😐";
                        case 3:
                            return "😞";
                        case 4:
                            return "😧";
                        }
                    }
                }
            }
        }
    }
