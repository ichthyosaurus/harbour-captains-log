/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

// requires formatDate, parseDate, and fullDateTimeFormat from appWindow
ComboBox {
    id: root

    property string date
    property string timeZone

    value: formatDate(date, fullDateTimeFormat, timeZone, qsTr("never"))

    onClicked: {
        var dateParsed = parseDate(date)
        var newDate = ''

        var datePicker = pageStack.push(Qt.resolvedUrl("LimitedDatePickerDialog.qml"), {
            date: dateParsed,
            maximumDate: dateParsed,
            acceptDestination: "Sailfish.Silica.TimePickerDialog",
            acceptDestinationAction: PageStackAction.Replace,
            acceptDestinationProperties: {
                hour: dateParsed.getHours(),
                minute: dateParsed.getMinutes()
            }
        })

        datePicker.accepted.connect(function() {
            var timePicker = datePicker.acceptDestinationInstance
            newDate = Qt.formatDate(datePicker.date, 'yyyy-MM-dd')
            console.log("picked date:", newDate)

            timePicker.accepted.connect(function() {
                newDate += ' ' + Qt.formatTime(timePicker.time, 'hh:mm:ss')
                console.log("picked time:", newDate)
                date = newDate
            })
        })
    }
}
