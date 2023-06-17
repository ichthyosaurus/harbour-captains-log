/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2020-2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Opal.InfoCombo 1.0 as I
import "../components"

Dialog {
    id: root
    allowedOrientations: Orientation.All

    property string homePath: StandardPaths.documents  // Sailjail permission required
    property string kind: "txt"

    property string defaultFileName: "logbook_export_" + String(new Date().getTime())

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

        I.InfoCombo {
            id: fileTypeCombo

            width: parent.width
            description: qsTr("Export file type selection")
            label: qsTr("Select file type:")

            I.InfoComboSection {
                title: qsTr("Note")
                text: qsTr("Data exports are meant for archival/printing and not as a backup. " +
                           "If you want to manually backup the database, select the " +
                           '“Database backup” option, or use ' +
                           '<a href="https://openrepos.net/content/slava/my-backup">MyBackup</a> ' +
                           "to create a system backup.")
                placeAtTop: true
            }

            menu: ContextMenu {
                I.InfoMenuItem {
                    text: qsTr("Plain text")
                    property string kind: "txt"
                    info: "- print, but lines are not folded"
                }
                I.InfoMenuItem {
                    text: qsTr("Plain Markdown")
                    property string kind: "md"
                    info: "- print"
                }
                I.InfoMenuItem {
                    text: qsTr("Markdown for Pandoc")
                    property string kind: "tex.md"
                    info: "- convert to pdf"
                }
                I.InfoMenuItem {
                    text: qsTr("Comma-separated values (CSV)")
                    property string kind: "csv"
                    info: "- raw database extract in a single file, - cannot be imported"
                }
                I.InfoMenuItem {
                    text: qsTr("Database backup")
                    property string kind: "raw"
                    info: "- actual database in a zip file as a backup, - can be put back in place"
                }
            }

            onCurrentIndexChanged: {
                kind = fileTypeCombo.currentItem.kind
            }
        }
    }

    ExportTranslations {
        id: translations
    }

    onAccepted: {
        var filename = (filenameField.text.length > 0 ? filenameField.text : defaultFileName)

        showMessage(qsTr("Data exported to: %1").arg(filename)) // defined in harbour-captains-log.qml
        py.call("diary.export", [homePath + '/' + filename, kind, translations.translations])
    }
}
