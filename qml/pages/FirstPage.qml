/*
 * This file is part of harbour-captains-log.
 * Copyright (C) 2020  Gabriel Berkigt, Mirian Margiani
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

import "../components"
import "../sf-about-page/about.js" as About

Page {
    id: firstPage

    Connections {
        target: appWindow
        onLoadingStarted: {
            busy.running = true
            diaryList.visible = false
        }
        onLoadingFinished: {
            busy.running = false
            diaryList.visible = true
            if (entriesModel.count === 0) placeholder.enabled = true
            else placeholder.enabled = false
        }
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // don't allow navigation back to PinPage
    backNavigation: false

    // used to add the WritePage for a new entry
    forwardNavigation: true

    onStatusChanged: {
        if(status == PageStatus.Active) {
            // preload WritePage on PageStack
            pageStack.pushAttached(Qt.resolvedUrl("WritePage.qml"))
            if (_scheduleReload) loadModel()
        }
    }

    DiaryListView {
        id: diaryList
        anchors.fill: parent
        model: entriesModel

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: About.pushAboutPage(pageStack)
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
            id: placeholder
            enabled: false
            text: qsTr("No entries yet")
            hintText: qsTr("Swipe right to add entries")
        }
    }

    BusyIndicator {
        id: busy
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: false
    }
}
