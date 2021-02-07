/*
 * This file is part of Captain's Log.
 *
 * SPDX-FileCopyrightText: 2020 Mirian Margiani
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

Dialog {
    id: exportDialog
    property string homePath: StandardPaths.home
    property string extension: "txt"

    property string defaultFileName: "logbook_export_"+String(new Date().getTime())

    Column {
        width: parent.width
        spacing: Theme.paddingMedium

        DialogHeader {
            title: qsTr("Export your data")
        }
        TextField {
            id: filenameField
            width: parent.width
            placeholderText: qsTr("Define the file name...")
            label: qsTr("Filename")
            text: defaultFileName
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
        }
        ComboBox {
            id: fileTypeCombo

            width: parent.width
            description: qsTr("Export file type selection")
            label: qsTr("Select file type:")

            menu: ContextMenu {
                MenuItem { text: qsTr("Plain text"); property string extension: "txt" }
                MenuItem { text: qsTr("Comma-separated values (CSV)"); property string extension: "csv" }
                MenuItem { text: qsTr("Plain Markdown"); property string extension: "md" }
                MenuItem { text: qsTr("Markdown for Pandoc"); property string extension: "tex.md" }
            }
            onCurrentIndexChanged: {
                extension = fileTypeCombo.currentItem.extension
            }
        }
    }
    onAccepted: {
        var filenameFormat = "%1/%2.%3"
        var filename = filenameFormat.arg(homePath).arg(defaultFileName).arg(extension)

        if(filenameField.text.length > 0) {
            filename = filenameFormat.arg(homePath).arg(filenameField.text).arg(extension)
        }

        var translations = {
            'moodTexts': moodTexts,
            'never': qsTr('never'),
            'Created: {}': qsTr('Created: {}'),
            'Changed: {}': qsTr('Changed: {}'),
            'changed: {}': qsTr('changed: {}'),
            'Title: {}': qsTr('Title: {}'),
            'Entry:\n{}': qsTr('Entry:\n{}'),
            'Hashtags: {}': qsTr('Hashtags: {}'),
            'Bookmark: {}': qsTr('Bookmark: {}'),
            'Mood: {}': qsTr('Mood: {}'),
            'Diary from {} until {}': qsTr('Diary from {} until {}'),
            'yes': qsTr('yes'),
            'no': qsTr('no'),
            // '': qsTr(''),
            // ': {}': qsTr(': {}'),
        }

        showMessage(qsTr("Data exported to: %1").arg(filename)) // defined in harbour-captains-log.qml
        py.call("diary.export", [filename, extension, translations])
    }
}
