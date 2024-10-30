/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2020-2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Opal.SmartScrollbar 1.0

SilicaListView {
    id: root

    property bool showFullEntries: false
    property bool selectable: false

    contentHeight: Theme.itemSizeHuge
    spacing: Theme.paddingMedium

    SmartScrollbar {
        flickable: root
        text: appWindow.formatDate(root.currentSection, appWindow.dateNoYearFormat)
        description: appWindow.formatDate(root.currentSection, 'yyyy')
    }

    Component {
        id: previewDelegate
        EntryElement {
            realModel: root.model
        }
    }

    Component {
        id: fullDelegate
        EntryElementFull {
            realModel: root.model
        }
    }

    Component {
        id: selectableDelegate
        EntryElementSelectable {
            realModel: root.model
            showFull: showFullEntries
        }
    }

    delegate: {
        if (selectable) selectableDelegate
        else if (showFullEntries) fullDelegate
        else previewDelegate
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
