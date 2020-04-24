/*
 * This file is part of harbour-captains-log.
 * Copyright (C) 2020  Mirian Margiani
 *
 * harbour-captains-log is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * harbour-captains-log is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with harbour-captains-log.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

PinPage {
    ConfigurationValue {
        id: protectionCode
        key: "/protectionCode"
    }

    property var settingsPage // settings page instance
    expectedCode: "" // has to be set by settings page

    title: expectedCode !== "" ? qsTr("Enter your old security code") : qsTr("Enter a new security code")
    onAccepted: {
        if (expectedCode === "") {
            // set new pin
            protectionCode.value = enteredCode
            pageStack.pop(settingsPage) // pop back to settings page
            showMessage(qsTr("Saved your protection code."))
        } else {
            // ask for new pin
            pageStack.push(Qt.resolvedUrl("ChangePinPage.qml"), { settingsPage: settingsPage })
        }
    }
}
