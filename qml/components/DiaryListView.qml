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

SilicaListView {
    id: diaryList
    VerticalScrollDecorator { flickable: diaryList }
    contentHeight: Theme.itemSizeHuge
    spacing: Theme.paddingMedium

    property bool editable: true

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
                text: formatDate(section+" | 0:0", fullDateFormat)
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
