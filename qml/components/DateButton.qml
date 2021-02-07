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

Button {
    id: button
    text: qsTr("Select", "fallback text on button to select a date")
    readonly property bool haveDate: selectedDateString !== ""
    property string selectedDateString: "" // in dbDateFormat
    property date _selectedDate: new Date(NaN)

    on_SelectedDateChanged: {
        if (!isNaN(_selectedDate.valueOf())) selectedDateString = _selectedDate.toLocaleString(Qt.locale(), dbDateFormat)
        else selectedDateString = ""
    }

    onSelectedDateStringChanged: if (selectedDateString !== "") text = formatDate(selectedDateString, dateFormat)

    onClicked: {
        var dialog = pageStack.push(pickerComponent, {
            date: haveDate ? _selectedDate : new Date()
        })
        dialog.accepted.connect(function() {
            _selectedDate = dialog.date
        })
    }

    Component {
        id: pickerComponent
        DatePickerDialog {}
    }
}
