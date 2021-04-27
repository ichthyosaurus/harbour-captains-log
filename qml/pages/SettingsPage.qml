/*
 * This file is part of Captain's Log.
 *
 * SPDX-FileCopyrightText: 2020 Gabriel Berkigt
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
import Nemo.Configuration 1.0

Page {
    id: page

    onStatusChanged: {
        if(status == PageStatus.Deactivating) {
            if (protectionSwitch.checked && config.protectionCode !== "-1") {
                // if protection is switched on AND a protection code is set - save!
                config.useCodeProtection = true

                // if the code was just set, make sure the app knows it's unlocked
                appWindow.unlocked = true
            } else {
                // if not checked or code not set rollback all details
                config.useCodeProtection = false
                config.protectionCode = "-1"
            }
        }
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: listView
        anchors.fill: parent

        Column {
            spacing: Theme.paddingLarge
            width: parent.width

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("Security")
            }

            TextSwitch {
                id: protectionSwitch
                text: qsTr("activate code protection")
                checked: config.useCodeProtection
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: config.protectionCode === "-1" ? qsTr("Set Code") : qsTr("Change Code")
                visible: protectionSwitch.checked
                onClicked: pageStack.push(Qt.resolvedUrl("ChangePinPage.qml"), {
                                              expectedCode: config.protectionCode === "-1" ? "" : config.protectionCode,
                                              settingsPage: page
                                          })
            }

            SectionHeader {
                text: qsTr("Export features")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Export data")
                onClicked: pageStack.push(Qt.resolvedUrl("ExportPage.qml"))
            }
        }
    }
}
