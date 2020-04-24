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

CoverBackground {
    HighlightImage {
        id: appImage
        color: Theme.primaryColor
        source: Qt.resolvedUrl("../images/cover-bg.png")
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
        anchors.fill: parent
    }

    function open(pageUrl) {
        if(appWindow.unlocked === true) {
            pageStack.clear()
            pageStack.replace(Qt.resolvedUrl("../pages/FirstPage.qml"))
            pageStack.push(Qt.resolvedUrl(pageUrl))
            appWindow.activate()
        }
        else {
            appWindow.activate()
            pageStack.replace(Qt.resolvedUrl("../pages/PinPage.qml"))
        }
    }

    CoverActionList {
        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: open("../pages/WritePage.qml")
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            onTriggered: open("../pages/SearchPage.qml")
        }
    }
}
