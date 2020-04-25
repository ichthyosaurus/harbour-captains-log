/*
 * This file is part of harbour-captains-log.
 * Copyright (C) 2020  Gabriel Berkigt, Mirian Margiani
 *
 * harbour-captains-log is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * harbour-captains-log is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with harbour-captains-log.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: entryList
    contentHeight: _isMoodOnly ? (iconsColumn.height + (_hasTags ? Theme.paddingLarge : Theme.paddingSmall)) : Theme.itemSizeHuge
    ListView.onRemove: animateRemoval()
    openMenuOnPressAndHold: false

    property bool editable: true
    property ListModel realModel: model

    property string _previewData: entry //preview
    property bool _hasPreview: _previewData !== ""
    property bool _hasTitle: title !== ""
    property bool _isMoodOnly: !_hasTitle && !_hasPreview
    property bool _hasTags: hashtagsAndModify.text !== ""

    function getHashtagText() {
        if (modify_date.length > 0) {
            var date = formatDate(modify_date, dateTimeFormat, modify_tz)
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

    menu: editMenuComponent

    Component {
        id: moodMenuComponent
        MoodMenu {
            selectedIndex: mood
            onSelectedIndexChanged: updateEntry(realModel, index, selectedIndex /* = new mood */, title, preview, entry, hashtags, rowid)
        }
    }

    Component {
        id: editMenuComponent
        ContextMenu {
            enabled: editable
            MenuItem {
                text: qsTr("Edit")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../pages/WritePage.qml"), {
                                       "title": title, "mood": mood, "entry": entry,
                                       "hashtags": hashtags, "rowid": rowid,
                                       "createDate": create_date, "modifyDate": modify_date,
                                       "index": index, "model": realModel,
                                       "modifyTz": modify_tz, "createTz": create_tz
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
    }

    onPressAndHold: {
        menu = editMenuComponent
        openMenu()
    }

    onClicked: {
        pageStack.push(Qt.resolvedUrl("../pages/ReadPage.qml"), {
                           "createDate": create_date, "modifyDate": modify_date,
                           "mood": mood, "title": title,
                           "entry": entry, "favorite": favorite,
                           "hashtags": hashtags, "rowid": rowid, "index": index,
                           "model": realModel, "editable": editable,
                           "modifyTz": modify_tz, "createTz": create_tz
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
            id: createDateLabel
            anchors { top: parent.top }
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.highlightColor
            text: formatDate(create_date, atTimeFormat, create_tz)
        }

        Label {
            id: titleText
            anchors { top: createDateLabel.bottom; topMargin: Theme.paddingSmall }
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

        onPressAndHold: {
            entryList.menu = moodMenuComponent
            entryList.openMenu()
        }

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
                opacity: 1-mood*(1/moodTexts.length)
                source: "../images/mood-%1.png".arg(String(mood))
            }
        }
    }
}
