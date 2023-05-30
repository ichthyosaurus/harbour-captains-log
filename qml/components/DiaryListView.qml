/*
 * This file is part of Captain's Log.
 *
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

SilicaListView {
    id: diaryList
    contentHeight: Theme.itemSizeHuge
    spacing: Theme.paddingMedium

    property bool editable: true

    VerticalScrollDecorator { flickable: diaryList }

    delegate: EntryElement {
        realModel: diaryList.model
        editable: diaryList.editable
    }

    section {
        property: "day"
        delegate: Item {
            width: parent.width
            height: childrenRect.height + Theme.paddingSmall

            Label {
                id: label
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                truncationMode: TruncationMode.Fade
                color: Theme.highlightColor
                text: formatDate(section, fullDateFormat)
            }
            Separator {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: label.baseline
                    topMargin: 8
                }
                width: parent.width-2*Theme.horizontalPageMargin
                horizontalAlignment: Qt.AlignHCenter
                color: Theme.highlightColor
            }
        }
    }

    footer: Item { width: parent.width; height: Theme.horizontalPageMargin }
}
