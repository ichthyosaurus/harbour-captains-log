import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: entryList
    contentHeight: _isMoodOnly ? iconsColumn.height+Theme.paddingSmall : Theme.itemSizeHuge
    ListView.onRemove: animateRemoval()

    property bool _hasTitle: title !== ""
    property bool _isMoodOnly: !_hasTitle && preview === ""

    function getHashtagText() {
        if (modify_date.length > 0) {
            var date = parseDate(modify_date).toLocaleString(Qt.locale(), dateTimeFormat);
            var ret = qsTr("Edit: %1").arg(date)

            if (hashtags.length > 0) {
                return "%1 – # %2".arg(ret).arg(hashtags)
            } else {
                return ret
            }
        } else {
            if (hashtags.length > 0) return "# %1".arg(hashtags)
            else return ""
        }
    }

    menu: ContextMenu {
        MenuItem {
            text: qsTr("Edit")
            onClicked: {
                pageStack.push(Qt.resolvedUrl("../pages/WritePage.qml"), {
                                   title_p: title, mood_p: mood, entry_p: entry,
                                   hashtags_p: hashtags, rowid_p: rowid,
                                   creation_date_p: create_date
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

    Item {
        id: labels
        height: parent.height
        anchors {
            top: parent.top; bottom: parent.bottom
            left: parent.left; right: icons.left
            leftMargin: Theme.horizontalPageMargin; rightMargin: 0
        }

        Label {
            id: createDate
            anchors { top: parent.top }
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.highlightColor
            // text: create_date
            text: parseDate(create_date).toLocaleString(Qt.locale(), atTimeFormat)
        }

        Label {
            id: titleText
            anchors { top: createDate.bottom; topMargin: Theme.paddingSmall }
            text: title
            height: _hasTitle ? contentHeight : 0
            width: parent.width
            maximumLineCount: 1
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.highlightColor
            truncationMode: TruncationMode.Fade
        }

        Label {
            id: entryTextPreview
            anchors {
                top: titleText.bottom
                topMargin: _hasTitle ? Theme.paddingSmall : 0
                bottom: hashtagsAndModify.top
            }
            text: preview !== "" ? preview + "..." : qsTr("mood: %1").arg(moodTexts[mood])
            width: parent.width
            color: preview !== "" ? Theme.primaryColor : Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            truncationMode: TruncationMode.Elide
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Label {
            id: hashtagsAndModify
            anchors { bottom: parent.bottom; bottomMargin: Theme.paddingSmall }
            width: parent.width
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
            text: entryList.getHashtagText()
            height: text !== "" ? contentHeight : 0
            maximumLineCount: 1
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

            HighlightImage {
                id: moodImage
                anchors.horizontalCenter: favStar.horizontalCenter
                width: 65; height: width
                fillMode: Image.PreserveAspectFit
                color: Theme.primaryColor
                opacity: 1-Theme.opacityFaint*mood
                source: "../images/mood-%1.png".arg(String(mood))
            }
        }
    }
}
