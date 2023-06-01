/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

DatePickerDialog {
    property date maximumDate: new Date()
    property date _maximumDateClean: new Date(Qt.formatDate(maximumDate, 'yyyy-MM-dd'))
    property date _selectedDateClean: isNaN(selectedDate.getTime()) ?
        selectedDate : new Date(Qt.formatDate(selectedDate, 'yyyy-MM-dd'))

    canAccept: !isNaN(selectedDate.getTime()) && _selectedDateClean < _maximumDateClean
    onSelectedDateChanged: {
        if (_selectedDateClean > _maximumDateClean) {
            appWindow.showMessage(qsTr("It is not possible to add entries for the future."))
        }
    }
}
