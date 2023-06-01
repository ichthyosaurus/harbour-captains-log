/*
 * This file is part of Captain's Log.
 *
 * SPDX-FileCopyrightText: 2020 Gabriel Berkigt
 * SPDX-FileCopyrightText: 2020-2023 Mirian Margiani
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Captain's Log is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Captain's Log is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Dialog {
    id: page
    allowedOrientations: Orientation.All // effective value restricted by ApplicationWindow.allowedOrientations

    onStatusChanged: {
        // make sure the date is always correct, even if the page has been
        // on the stack for a long time
        if (status !== PageStatus.Activating) return;
        currentDate = new Date().toLocaleString(Qt.locale(), fullDateTimeFormat);
        dbCurrentDate = new Date().toLocaleString(Qt.locale(), dbDateFormat);

        if (!editing) {
            moodCombo.clicked(null) // open mood menu
        }
    }

    property string currentDate: new Date().toLocaleString(Qt.locale(), fullDateTimeFormat);
    property string dbCurrentDate: Qt.formatDateTime(new Date(), dbDateFormat)
    property bool editing: rowid > -1

    property string entryDate: dbCurrentDate
    property string entryTz: appWindow.timezone
    property string modifyDate: ""
    property string modifyTz: ""
    property alias title: titleField.text
    property alias entry: entryArea.text
    property alias tags: tagsField.text
    property alias mood: moodMenu.selectedIndex
    property int rowid: -1
    property int index: -1
    property var model: null

    onAccepted: {
        var mood = page.mood
        var title_text = titleField.text.trim()
        // regular expression to kick out all newline chars in preview
        var preview = entryArea.text.substring(0, 150).replace(/\r?\n|\r/g, " ").trim()
        var entry = entryArea.text.trim()
        var tags = tagsField.text.trim()

        if (editing) {
            updateEntry(model, index, entryDate, entryTz,
                        mood, title_text, preview, entry, tags, rowid);
        } else {
            addEntry(dbCurrentDate, entryDate, entryTz,
                     mood, title_text, preview, entry, tags);
        }
    }

    onDone: {
        if (result != DialogResult.Rejected && result != DialogResult.None) {
            return
        }

        if (title == "" && entry == "" && tags == "") {
            return
        }

        appWindow._currentlyEditedEntry.entryDate  = entryDate
        appWindow._currentlyEditedEntry.entryTz    = entryTz
        appWindow._currentlyEditedEntry.modifyDate = modifyDate
        appWindow._currentlyEditedEntry.modifyTz   = modifyTz
        appWindow._currentlyEditedEntry.title      = title
        appWindow._currentlyEditedEntry.entry      = entry
        appWindow._currentlyEditedEntry.tags       = tags
        appWindow._currentlyEditedEntry.mood       = mood
        appWindow._currentlyEditedEntry.rowid      = rowid
        appWindow._currentlyEditedEntry.index      = index
        appWindow._currentlyEditedEntry.model      = model

        try {
            var page = pageStack.previousPage(page)
        } catch(error) {
            page = appWindow
        }

        if (editing) {
            remorseCancelWriting(page || appWindow, qsTr("Discarded all changes"))
        } else {
            remorseCancelWriting(page || appWindow, qsTr("Discarded the entry"))
        }
    }

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge
        VerticalScrollDecorator { flickable: flick }

        Column {
            id: content
            width: parent.width
            spacing: Theme.paddingMedium

            DialogHeader {
                title: editing ? qsTr("Edit Entry") : qsTr("New Entry")
                acceptText: qsTr("Save")
                cancelText: qsTr("Discard")
            }

            DateTimePickerCombo {
                label: qsTr("Date")
                date: entryDate
                timeZone: entryTz
                description: modifyDate !== "" ?
                                 qsTr("Last edited: %1").arg(formatDate(
                                     modifyDate, fullDateTimeFormat, modifyTz, qsTr("never"))) :
                                 ""
                onDateChanged: entryDate = date

                // Changing the entry date is not allowed later because
                // it is too complicated to ensure entries are properly
                // sorted, due to timezones and the way entries are
                // stored in the database.
                enabled: !editing
            }

            ComboBox {
                id: moodCombo
                value: moodTexts[mood]
                width: parent.width
                description: editing ? qsTr("How did you feel?") : qsTr("How do you feel?")
                label: qsTr("Your mood")

                menu: MoodMenu {
                    id: moodMenu
                    selectedIndex: 2
                    onClosed: if (!editing) entryArea.forceActiveFocus()
                }
            }

            TextField {
                id: titleField
                width: parent.width
                placeholderText: qsTr("Add a title")
                label: qsTr("Title")
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: {
                    entryArea.focus = true
                }
            }

            TextArea {
                id: entryArea
                width: parent.width
                placeholderText: editing ? qsTr("What do you want to say?") : qsTr("Entry...")
                label: qsTr("Entry")
                wrapMode: TextEdit.WordWrap
            }

            TextField {
                id: tagsField
                width: parent.width
                placeholderText: qsTr("Tags")
                font.pixelSize: Theme.fontSizeExtraSmall
                label: qsTr("Tags")
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: {
                    tagsField.focus = false
                }
            }
        }
    }
}
