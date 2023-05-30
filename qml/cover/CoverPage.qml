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
        if (appWindow.unlocked === true) {
            pageStack.replaceAbove(null, [
                Qt.resolvedUrl("../pages/FirstPage.qml"), Qt.resolvedUrl(pageUrl)
            ])
        } else {
            pageStack.replaceAbove(null, appWindow.pinPageComponent)
        }

        appWindow.activate()
    }

    CoverActionList {
        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: open("../pages/WritePage.qml")
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            onTriggered: open("../pages/SearchQueryPage.qml")
        }
    }
}
