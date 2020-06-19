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

Page {
    id: page

    property string createDate
    property string modifyDate
    property int mood
    property string title
    property string entry
    property bool bookmark
    property string hashtags
    property string createTz
    property string modifyTz
    property int rowid
    property int index
    property var model

    property bool editable: true
    allowedOrientations: Orientation.All

    Connections {
        target: appWindow
        onEntryBookmarkToggled: {
            if (rowid !== page.rowid) return
            bookmark = isBookmark
        }
        onEntryUpdated: {
            if (rowid !== page.rowid) return
            page.modifyDate = changeDate
            page.mood = mood
            page.title = title
            page.entry = entry
            page.hashtags = hashs
            page.modifyTz = modifyTz
        }
    }

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: content.height + Theme.horizontalPageMargin
        VerticalScrollDecorator { flickable: flick }

        PullDownMenu {
            enabled: editable
            MenuItem {
                text: qsTr("Edit")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("WritePage.qml"), {
                                       "title": title, "mood": mood, "entry": entry,
                                       "hashtags": hashtags, "rowid": rowid,
                                       "createDate": createDate, "index": index, "model": model,
                                       "modifyTz": modifyTz, "createTz": createTz,
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
                title: formatDate(createDate, "dddd")
                description: formatDate(createDate, dateTimeFormat, createTz)
                _titleItem.truncationMode: TruncationMode.Fade
                _titleItem.horizontalAlignment: Text.AlignRight
            }

            Label {
                id: modDateLabel
                visible: modifyDate !== ""
                anchors {
                    left: parent.left; leftMargin: Theme.horizontalPageMargin
                    right: parent.right; rightMargin: Theme.horizontalPageMargin
                }
                horizontalAlignment: Text.AlignRight
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryHighlightColor
                text: modifyDate !== "" ? qsTr("changed: %1").arg(formatDate(modifyDate, dateTimeFormat, modifyTz)) : ""
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall
                onClicked: setBookmark(model, index, rowid, !bookmark)
                enabled: editable

                HighlightImage {
                    id: favStar
                    anchors { verticalCenter: parent.verticalCenter; right: parent.right }
                    highlighted: parent.down
                    source: bookmark ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
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

