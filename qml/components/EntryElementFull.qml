/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2020-2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: root

    property var realModel

    ListView.onRemove: animateRemoval()
    contentHeight: textColumn.height
    openMenuOnPressAndHold: false
    enabled: false

    Column {
        id: textColumn
        spacing: Theme.paddingSmall
        anchors {
            left: parent.left; right: parent.right
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }

        Item { width: 1; height: 1 }

        SilicaItem {
            width: parent.width
            height: childrenRect.height

            Label {
                id: atTimeLabel
                anchors.left: parent.left
                color: Theme.highlightColor
                text: formatDate(model.entry_date, atTimeFormat, model.entry_tz)
                font.pixelSize: Theme.fontSizeMedium
            }

            Label {
                anchors {
                    left: atTimeLabel.right
                    leftMargin: Theme.paddingMedium
                    right: parent.right
                    baseline: atTimeLabel.baseline
                }
                color: Theme.highlightColor
                font.italic: true
                font.pixelSize: Theme.fontSizeExtraSmall
                text: model.is_addendum ?
                          qsTr("Addendum from %1", "as in “Addendum written on May 5th " +
                               "to a diary entry on May 10th”").arg(
                              formatDate(model.create_date, dateFormat, model.create_tz)) :
                          ""
                truncationMode: TruncationMode.Fade
            }
        }

        Label {
            color: Theme.highlightColor
            width: parent.width
            maximumLineCount: 2
            wrapMode: Text.Wrap
            text: model.title
            visible: !!text
            font.pixelSize: Theme.fontSizeSmall
            truncationMode: TruncationMode.Elide
        }

        Label {
            width: parent.width
            wrapMode: Text.Wrap
            text: model.entry
            visible: !!text
            font.pixelSize: Theme.fontSizeSmall
        }

        Label {
            width: parent.width
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeSmall
            text: "// " + qsTr("mood: %1").arg(moodTexts[model.mood])
            palette {
                primaryColor: Theme.secondaryColor
                highlightColor: Theme.secondaryHighlightColor
            }
        }

        Label {
            width: parent.width
            truncationMode: TruncationMode.Fade
            text: "// " + model.tags  // TODO RTL support
            visible: !!model.tags
            font.pixelSize: Theme.fontSizeExtraSmall
            palette {
                primaryColor: Theme.secondaryColor
                highlightColor: Theme.secondaryHighlightColor
            }
        }

        Item { width: 1; height: 1 }
    }
}
