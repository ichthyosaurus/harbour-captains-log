/*
 * This file is part of Captain's Log.
 *
 * SPDX-FileCopyrightText: 2020 Gabriel Berkigt
 * SPDX-FileCopyrightText: 2020-2023 Mirian Margiani
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

import "../components"

Page {
    id: firstPage

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // don't allow navigation back to PinPage
    backNavigation: false

    // used to add the WritePage for a new entry
    forwardNavigation: true

    onStatusChanged: {
        if(status == PageStatus.Active) {
            // preload WritePage on PageStack
            pageStack.pushAttached(Qt.resolvedUrl("WritePage.qml"),
                                   {'acceptDestination': Qt.resolvedUrl("FirstPage.qml")})
        }
    }

    DiaryListView {
        id: diaryList
        anchors.fill: parent
        model: entriesModel

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings and Export")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: qsTr("Search")
                onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"))
            }
        }

        header: PageHeader {
            id: header
            title: qsTr("Add new entry")
        }

        ViewPlaceholder {
            id: busyPlaceholder
            enabled: appWindow.loading
            verticalOffset: -diaryList.originY - height

            BusyIndicator {
                anchors.centerIn: parent
                running: parent.enabled
                size: BusyIndicatorSize.Large
            }
        }

        ViewPlaceholder {
            id: emptyPlaceholder
            enabled: !appWindow.loading && entriesModel.count === 0
            text: qsTr("No entries yet")
            hintText: qsTr("Swipe left to add entries")
        }
    }
}
