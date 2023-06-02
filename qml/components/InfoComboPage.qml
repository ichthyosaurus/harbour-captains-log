/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: root
    allowedOrientations: Orientation.All

    property string title
    property var sections: []
    property bool hasExtraSections: false

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: column.height + 2 * Theme.horizontalPageMargin

        VerticalScrollDecorator { flickable: flick }

        Column {
            id: column
            spacing: Theme.paddingLarge
            width: parent.width
            height: childrenRect.height

            PageHeader {
                title: root.title
                description: qsTr("Details")
            }

            Repeater {
                model: sections
                delegate: Column {
                    width: parent.width
                    spacing: Theme.paddingSmall
                    height: childrenRect.height

                    Item { width: 1; height: Theme.paddingMedium }

                    Label {
                        width: parent.width - 2*x
                        x: Theme.horizontalPageMargin
                        horizontalAlignment: Text.AlignRight
                        font.pixelSize: Theme.fontSizeSmall
                        truncationMode: TruncationMode.Fade
                        color: palette.highlightColor
                        text: modelData.title
                    }

                    Label {
                        width: parent.width - 2*x
                        x: Theme.horizontalPageMargin
                        horizontalAlignment: Text.AlignRight
                        font.pixelSize: Theme.fontSizeSmall
                        font.italic: true
                        truncationMode: TruncationMode.Fade
                        color: palette.secondaryHighlightColor
                        visible: !!modelData.isOption && root.hasExtraSections
                        text: qsTr("Option")
                    }

                    Label {
                        width: parent.width - 2*x
                        x: Theme.horizontalPageMargin
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.highlightColor
                        wrapMode: Text.Wrap
                        text: modelData.text
                    }
                }
            }
        }
    }
}
