import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: entryList
    contentHeight: _isMoodOnly ? (iconsColumn.height + (_hasTags ? Theme.paddingLarge : Theme.paddingSmall)) : Theme.itemSizeHuge
    ListView.onRemove: animateRemoval()

    property bool editable: true
    property ListModel realModel: model

    property string _previewData: entry //preview
    property bool _hasPreview: _previewData !== ""
    property bool _hasTitle: title !== ""
    property bool _isMoodOnly: !_hasTitle && !_hasPreview
    property bool _hasTags: hashtagsAndModify.text !== ""

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
        enabled: editable
        MenuItem {
            text: qsTr("Edit")
            onClicked: {
                pageStack.push(Qt.resolvedUrl("../pages/WritePage.qml"), {
                                   "title": title, "mood": mood, "entry": entry,
                                   "hashtags": hashtags, "rowid": rowid,
                                   "creationDate": create_date, "index": index, "model": realModel
                               })
            }
        }
        MenuItem {
            text: qsTr("Delete")
            onClicked: {
                entryList.remorseDelete(function () { deleteEntry(realModel, index, rowid) })
            }
        }
    }

    onClicked: {
        pageStack.push(Qt.resolvedUrl("../pages/ReadPage.qml"), {
                           "creationDate": create_date, "modificationDate": modify_date,
                           "mood": mood, "title": title,
                           "entry": entry, "favorite": favorite,
                           "hashtags": hashtags, "rowid": rowid, "index": index,
                           "model": realModel, "editable": editable
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
            text: _hasPreview ? _previewData : qsTr("mood: %1").arg(moodTexts[mood])
            width: parent.width
            color: _hasPreview ? Theme.primaryColor : Theme.secondaryColor
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

        enabled: editable
        onClicked: setFavorite(realModel, index, rowid, !favorite)

        Column {
            id: iconsColumn
            spacing: Theme.paddingSmall
            anchors.horizontalCenter: parent.horizontalCenter

            Icon {
                id: favStar
                opacity: Theme.opacityHigh
                source: favorite ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
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
