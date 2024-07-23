/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2020-2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"

Page {
    id: root
    allowedOrientations: Orientation.All

    property var entry  // list element
    property var model  // actual list model

    Connections {
        target: appWindow
        onEntryUpdated: {
            if (rowid !== page.rowid) return
            root.entry = newEntry
        }
    }

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: column.height + Theme.horizontalPageMargin

        VerticalScrollDecorator { flickable: flick }

        PullDownMenu {
            MenuItem {
                text: qsTr("Edit")

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("WritePage.qml"), {
                        "entryDate": entry.entry_date,
                        "entryTz": entry.entry_tz,
                        "modifyDate": entry.modify_date,
                        "modifyTz": entry.modify_tz,
                        "title": entry.title,
                        "entry": entry['entry'],
                        "tags": entry['tags'],
                        "mood": entry['mood'],
                        "rowid": entry['rowid'],
                        "index": entry['index'],
                        "model": model,
                        "acceptDestination": "" // return to the calling page
                    })
                }
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                id: header
                interactive: !config.useMoodTracking
                title: appWindow.formatDate(entry.entry_date, "dddd")
                description: appWindow.formatDate(
                    entry.entry_date, appWindow.dateTimeFormat, entry.entry_tz)

                Connections {
                    target: header._navigateForwardMouseArea
                    onClicked: headerBookmarkButton.clicked(mouse)
                }

                IconButton {
                    id: headerBookmarkButton
                    visible: !config.useMoodTracking
                    parent: header.extraContent
                    anchors {
                        verticalCenter: parent.verticalCenter
                        verticalCenterOffset: Theme.paddingMedium
                        left: parent.left
                        leftMargin: Theme.paddingMedium
                        right: parent.right
                    }

                    icon.anchors {
                        centerIn: undefined
                        left: headerBookmarkButton.left
                    }

                    Binding on highlighted {
                        when: header._navigateForwardMouseArea &&
                              header._navigateForwardMouseArea.containsPress
                        value: true
                    }

                    enabled: root.enabled
                    icon.source: "image://theme/icon-m-favorite" + (entry.bookmark ? "-selected" : "")
                    onClicked: {
                        appWindow.setBookmark(
                            model, entry.index, entry.rowid, !entry.bookmark)
                    }
                }
            }

            ComboBox {
                id: moodCombo
                width: parent.width
                rightMargin: Theme.horizontalPageMargin + Theme.iconSizeMedium
                label: qsTr("Mood")
                value: appWindow.moodTexts[entry.mood]
                visible: config.useMoodTracking

                menu: null
                onClicked: bookmarkButton.clicked(null)
                onPressAndHold: {
                    menu = moodMenu
                    _controller.openMenu()
                }

                MoodMenu {
                    id: moodMenu
                    selectedIndex: entry.mood
                    onClosed: moodCombo.menu = null
                    onSelectedIndexChanged: {
                        if (selectedIndex === entry.mood) return

                        appWindow.updateEntry(
                            model, entry.index, entry.entry_date, entry.entry_tz,
                            selectedIndex, entry.title, entry.entry,
                            entry.tags, entry.rowid)
                    }
                }

                IconButton {
                    id: bookmarkButton
                    enabled: root.enabled
                    anchors.right: parent.right
                    Binding on highlighted { when: moodCombo.highlighted; value: true }
                    icon.source: "image://theme/icon-m-favorite" + (entry.bookmark ? "-selected" : "")
                    onClicked: {
                        appWindow.setBookmark(
                            model, entry.index, entry.rowid, !entry.bookmark)
                    }
                }
            }

            Item { width: 1; height: Theme.paddingMedium }

            Column {
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
                spacing: parent.spacing

                Label {
                    visible: entry.is_addendum
                    width: parent.width
                    text: qsTr("Addendum from %1", "as in “Addendum written on May 5th " +
                               "to a diary entry on May 10th”").
                          arg(appWindow.formatDate(
                              entry.create_date, appWindow.dateFormat,
                              entry.create_tz))
                    color: palette.highlightColor
                    font.italic: true
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                }

                Label {
                    visible: !!entry.title
                    width: parent.width
                    wrapMode: Text.Wrap
                    text: entry.title
                    color: palette.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                }

                Label {
                    visible: !!entry.entry
                    width: parent.width
                    wrapMode: Text.Wrap
                    text: entry.entry
                }

                HighlightImage {
                    visible: !entry.entry
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(root.width, root.height) / 4
                    height: width + Theme.paddingLarge
                    verticalAlignment: Image.AlignBottom
                    fillMode: Image.PreserveAspectFit
                    color: Theme.primaryColor
                    opacity: Theme.opacityLow
                    source: "../images/mood-%1.png".arg(String(entry.mood))
                }

                Item { width: 1; height: Theme.paddingMedium }

                Row {
                    visible: !!entry.tags
                    width: parent.width

                    Label {
                        id: tagsHint
                        text: "// "
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryColor
                    }

                    Label {
                        width: parent.width - tagsHint.width
                        wrapMode: Text.Wrap
                        text: entry.tags
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryColor
                    }
                }

                Label {
                    visible: !!entry.modify_date
                    width: parent.width
                    wrapMode: Text.Wrap
                    text: "// " + modified  // TODO RTL support
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor

                    property string modified: !!entry.modify_date ?
                        qsTr("last edited on %1").arg(appWindow.formatDate(
                            entry.modify_date, appWindow.dateTimeFormat, entry.modify_tz)) : ''
                }
            }
        }
    }
}
