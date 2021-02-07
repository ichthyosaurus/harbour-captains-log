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

ContextMenu {
    id: moodMenu
    property int selectedIndex: 2

    Flow {
        anchors.horizontalCenter: parent.horizontalCenter
        property int maxPerLine: Math.floor(parent.width / Theme.itemSizeMedium)
        property int itemsPerLine: ((maxPerLine > 3) ? 3 : maxPerLine)

        width: itemsPerLine*Theme.itemSizeMedium
        height: Math.ceil(moodTexts.length/itemsPerLine)*Theme.itemSizeMedium

        Repeater {
            model: moodTexts
            delegate: BackgroundItem {
                property bool selected: index === moodMenu.selectedIndex
                width: Theme.itemSizeMedium; height: width
                highlighted: down || selected

                HighlightImage {
                    anchors.centerIn: parent
                    source: "../images/mood-%1.png".arg(index)
                    highlighted: parent.highlighted
                    color: Theme.primaryColor
                    highlightColor: Theme.highlightColor
                }

                onClicked: {
                    moodMenu.selectedIndex = index
                    moodMenu.close()
                }
            }
        }
    }
}
