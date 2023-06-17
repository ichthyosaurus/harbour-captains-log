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

    property string defaultFileName: "%1 - %2".
        arg(appWindow.appName).
        arg((new Date()).toLocaleString(
            Qt.locale(), appWindow.dbDateFormat))

    Column {
        width: parent.width
        spacing: Theme.paddingMedium

        DialogHeader {
            title: qsTr("Export your data")
        }

        TextField {
            id: filenameField
            width: parent.width
            placeholderText: qsTr("Define the file name")
            label: qsTr("Filename")
            description: qsTr("The file will be saved in your documents " +
                              "folder. The name must not contain subfolders.")
            text: defaultFileName
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            validator: RegExpValidator {
                regExp: /[^\/]/gi
            }
        }

        I.InfoCombo {
            id: fileTypeCombo

            width: parent.width
            label: qsTr("Export file format")

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
                    info: qsTr("Export entries in a very simple style " +
                               "as a plain text file that can be printed " +
                               "directly. Note that long lines will not be " +
                               "folded.")
                }
                I.InfoMenuItem {
                    text: qsTr("Plain Markdown")
                    property string kind: "md"
                    info: qsTr("Export entries in a simple " +
                               '<a href="https://daringfireball.net/projects/markdown/syntax">Markdown</a> ' +
                               "format. This can later be converted into other " +
                               "formats for printing or for the web.")
                }
                I.InfoMenuItem {
                    text: qsTr("Markdown for Pandoc")
                    property string kind: "tex.md"
                    info: qsTr("Export entries using an extended format that " +
                               "can be converted to PDF using " +
                               '<a href="https://pandoc.org/">Pandoc</a>. ' +
                               "This format is not suitable to be printed without " +
                               "further conversion.")
                }
                I.InfoMenuItem {
                    text: qsTr("Comma-separated values (CSV)")
                    property string kind: "csv"
                    info: qsTr("Export the full database in a machine-readable " +
                               "plain text format.") + " " +
                          qsTr("Note that it is not yet possible to import this " +
                               "file type back into the app.")
                }
                I.InfoMenuItem {
                    text: qsTr("Database backup")
                    property string kind: "raw"
                    info: qsTr("Create a backup of the actual database files " +
                               "as an archive. This database can later be put " +
                               "back into place.")
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

        // defined in harbour-captains-log.qml
        showMessage(qsTr("Data exported to: %1").arg(homePath))

        py.call("diary.export", [homePath + '/' + filename, kind, translations.translations])
    }
}
