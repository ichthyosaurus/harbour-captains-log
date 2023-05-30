/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2020-2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

// Requires appWindow.formatDate, appWindow.dateFormat, appWindow.dbDateFormat

ComboBox {
    id: root
    label: qsTr("Date")

    property string emptyText: qsTr("Select", "fallback text on button to select a date")
    property bool resetOnPressAndHold: true
    readonly property bool haveDate: selectedDateString !== ""
    property date selectedDate: new Date(NaN)
    property string selectedDateString: !isNaN(selectedDate.valueOf()) ?
        selectedDate.toLocaleString(Qt.locale(), appWindow.dbDateFormat) : ""

    value: !!selectedDateString ?
              appWindow.formatDate(selectedDateString, appWindow.dateFormat) :
              emptyText

    onPressAndHold: {
        if (resetOnPressAndHold) {
            selectedDate = new Date(NaN)
        }
    }

    onClicked: {
        var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
            date: haveDate ? selectedDate : new Date()
        })
        dialog.accepted.connect(function() {
            selectedDate = dialog.date
        })
    }
}
