/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0

QtObject {
    property var translations: ({
        "%A, %B %-d %Y (%-H:%M)": qsTr("%A, %B %-d %Y (%-H:%M)", "This string is used in export templates and uses Python formatting. See https://strftime.org for how to format dates and https://docs.python.org/3/library/stdtypes.html#str.format for more information."),
        "%A, %B %-d %Y (%-H:%M, {tz})": qsTr("%A, %B %-d %Y (%-H:%M, {tz})", "This string is used in export templates and uses Python formatting. See https://strftime.org for how to format dates and https://docs.python.org/3/library/stdtypes.html#str.format for more information."),
        "Addendum from {0}": qsTr("Addendum from {0}", "This string is used in export templates and uses Python formatting. See https://strftime.org for how to format dates and https://docs.python.org/3/library/stdtypes.html#str.format for more information."),
        "Diary from {0} to {1}": qsTr("Diary from {0} to {1}", "This string is used in export templates and uses Python formatting. See https://strftime.org for how to format dates and https://docs.python.org/3/library/stdtypes.html#str.format for more information."),
        "last changed on {0}": qsTr("last changed on {0}", "This string is used in export templates and uses Python formatting. See https://strftime.org for how to format dates and https://docs.python.org/3/library/stdtypes.html#str.format for more information."),
        "Mood: {0}": qsTr("Mood: {0}", "This string is used in export templates and uses Python formatting. See https://strftime.org for how to format dates and https://docs.python.org/3/library/stdtypes.html#str.format for more information."),
        "Note: this requires “pandoc” and “lualatex”.": qsTr("Note: this requires “pandoc” and “lualatex”.", "This string is used in export templates and uses Python formatting. See https://strftime.org for how to format dates and https://docs.python.org/3/library/stdtypes.html#str.format for more information."),
        "README.txt": qsTr("README.txt", "This string is used in export templates and uses Python formatting. See https://strftime.org for how to format dates and https://docs.python.org/3/library/stdtypes.html#str.format for more information."),
        "Tags: {0}": qsTr("Tags: {0}", "This string is used in export templates and uses Python formatting. See https://strftime.org for how to format dates and https://docs.python.org/3/library/stdtypes.html#str.format for more information."),
        "This file has been exported from Captain's Log on {0}.": qsTr("This file has been exported from Captain's Log on {0}.", "This string is used in export templates and uses Python formatting. See https://strftime.org for how to format dates and https://docs.python.org/3/library/stdtypes.html#str.format for more information."),
        "You can convert this file to PDF using the following command:": qsTr("You can convert this file to PDF using the following command:", "This string is used in export templates and uses Python formatting. See https://strftime.org for how to format dates and https://docs.python.org/3/library/stdtypes.html#str.format for more information."),
        "moodTexts": appWindow.moodTexts
    })
}
