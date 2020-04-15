import QtQuick 2.0
import Sailfish.Silica 1.0

Component {
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
                text: qsTr("Favorite")
                onClicked: {
                    var status = favorite === 1 ? 0 : 1
                    py.call("diary.update_favorite", [rowid, status])
                    firstPage.loadModel()
                }
            }
            MenuItem {
                text: qsTr("Edit")
                onClicked: {
                    pageStack.pushAttached(Qt.resolvedUrl("../pages/EditPage.qml"),
                                           {title_p: title, mood_p: mood, entry_p: entry, hashtags_p: hashtags, rowid_p: rowid})
                    pageStack.navigateForward()
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

        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - (2*Theme.horizontalPageMargin)

        onClicked: {
            pageStack.pushAttached(Qt.resolvedUrl("../pages/ReadPage.qml"),
                                        { creation_date_p: create_date, modify_date_p: "", mood_p: mood, title_p: title, entry_p: entry, favorite_p: favorite, hashtags_p: hashtags, rowid_p: rowid })
            pageStack.navigateForward()
        }

        Row {
            width: parent.width
            height: parent.height
            spacing: Theme.paddingMedium

            Column {
                id: labels
                spacing: Theme.paddingSmall
                width: parent.width - icons.width

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

            Column {
                id: icons
                spacing: Theme.paddingSmall

                Icon {
                    id: favStar
                    source: favorite === 0 ? "image://theme/icon-m-favorite" : "image://theme/icon-m-favorite-selected"
                }

                // Like thumb is rotated to show mood
                Icon {
                    id: feel

                    anchors.horizontalCenter: favStar.horizontalCenter
                    source: "image://theme/icon-s-like"
                    rotation: {
                        switch(mood) {
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
        }
    }
}
