/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2020-2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: root

    property var realModel

    ListView.onRemove: animateRemoval()
    contentHeight: contentRow.height
    openMenuOnPressAndHold: false
    menu: editMenuComponent

    onPressAndHold: {
        menu = editMenuComponent
        openMenu()
    }

    onClicked: {
        pageStack.push(Qt.resolvedUrl("../pages/ReadPage.qml"), {
            "model": realModel, "entry": model
        })
    }

    Component {
        id: editMenuComponent

        ContextMenu {
            MenuItem {
                text: qsTr("Edit")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../pages/WritePage.qml"), {
                        "model": realModel,
                        "index": model.index, "title": model.title,
                        "mood": model.mood, "entry": model.entry,
                        "tags": model.tags, "rowid": model.rowid,
                        "entryDate": model.entry_date, "modifyDate": model.modify_date,
                        "modifyTz": model.modify_tz, "entryTz": model.entry_tz
                    })
                }
            }
            MenuItem {
                text: qsTr("Delete")
                onClicked: {
                    // The remorse action is executed without the current context,
                    // so we have to keep all variables around.
                    var _realModel = realModel, _index = index, _rowid = rowid
                    var deleteProxy = appWindow.deleteEntry
                    remorseDelete(function() { deleteProxy(_realModel, _index, _rowid) })
                }
            }
        }
    }

    Component {
        id: moodMenuComponent

        MoodMenu {
            selectedIndex: model.mood
            onSelectedIndexChanged: {
                if (selectedIndex === model.mood) return
                updateEntry(realModel, model.index, model.entry_date, model.entry_tz,
                            selectedIndex, model.title, model.entry,
                            model.tags, model.rowid)
            }
        }
    }

    Row {
        id: contentRow
        spacing: Theme.paddingMedium
        anchors {
            left: parent.left; right: parent.right
            leftMargin: Theme.horizontalPageMargin
        }

        Column {
            id: textColumn
            width: parent.width - iconsColumn.width - contentRow.spacing
            spacing: Theme.paddingSmall

            Item { width: 1; height: 1 }

            SilicaItem {
                width: parent.width
                height: childrenRect.height

                Label {
                    id: atTimeLabel
                    anchors.left: parent.left
                    color: Theme.highlightColor
                    text: formatDate(model.entry_date, atTimeFormat, model.entry_tz)
                    font.pixelSize: Theme.fontSizeMedium
                }

                Label {
                    anchors {
                        left: atTimeLabel.right
                        leftMargin: Theme.paddingMedium
                        right: parent.right
                        baseline: atTimeLabel.baseline
                    }
                    color: Theme.highlightColor
                    font.italic: true
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: model.is_addendum ?
                              qsTr("Addendum from %1", "as in “Addendum written on May 5th " +
                                   "to a diary entry on May 10th”").arg(
                                  formatDate(model.create_date, dateFormat, model.create_tz)) :
                              ""
                    truncationMode: TruncationMode.Fade
                }
            }

            Label {
                color: Theme.highlightColor
                width: parent.width
                maximumLineCount: 2
                wrapMode: Text.Wrap
                text: model.title
                visible: !!text
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Elide
            }

            Label {
                width: parent.width
                maximumLineCount: 3
                wrapMode: Text.Wrap
                text: model.preview
                visible: !!text
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Elide
            }

            Label {
                width: parent.width
                truncationMode: TruncationMode.Fade
                font.pixelSize: Theme.fontSizeSmall
                visible: !model.preview
                text: qsTr("mood: %1").arg(moodTexts[model.mood])
                palette {
                    primaryColor: Theme.secondaryColor
                    highlightColor: Theme.secondaryHighlightColor
                }
            }

            Label {
                width: parent.width
                truncationMode: TruncationMode.Fade
                text: "// " + model.tags  // TODO RTL support
                visible: !!model.tags
                font.pixelSize: Theme.fontSizeExtraSmall
                palette {
                    primaryColor: Theme.secondaryColor
                    highlightColor: Theme.secondaryHighlightColor
                }
            }

            Item { width: 1; height: 1 }
        }

        BackgroundItem {
            id: icons
            height: Math.max(iconsColumn.height, textColumn.height)

            onClicked: setBookmark(realModel, model.index, model.rowid, !model.bookmark)

            onPressAndHold: {
                root.menu = moodMenuComponent
                root.openMenu()
            }

            Column {
                id: iconsColumn
                spacing: Theme.paddingMedium
                width: Theme.paddingSmall + Theme.iconSizeMedium + Theme.horizontalPageMargin

                HighlightImage {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Theme.iconSizeMedium
                    height: width
                    fillMode: Image.PreserveAspectFit
                    highlighted: icons.highlighted || root.highlighted
                    color: Theme.primaryColor
                    opacity: Theme.opacityHigh
                    source: "image://theme/icon-m-favorite" + (model.bookmark ? "-selected" : "")
                }

                HighlightImage {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 65
                    height: width
                    fillMode: Image.PreserveAspectFit
                    highlighted: icons.highlighted || root.highlighted
                    color: Theme.primaryColor
                    opacity: 1 - model.mood * (1 / moodTexts.length)
                    source: "../images/mood-%1.png".arg(String(model.mood))
                }

                Item { width: 1; height: 1 }
            }
        }
    }
}
