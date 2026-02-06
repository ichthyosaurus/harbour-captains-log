/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import Opal.SortFilterProxyModel 1.0

Flow {
    id: root

    property var tagsList: ([])

    signal removeRequested(var tag)

    layoutDirection: Flow.LeftToRight
    spacing: Theme.paddingSmall
    leftPadding: Theme.horizontalPageMargin
    rightPadding: Theme.horizontalPageMargin

    Repeater {
        model: tagsList

        delegate: BackgroundItem {
            id: item
            width: tagLabel.width + tagRemove.width
            height: Theme.itemSizeExtraSmall
            contentItem.radius: 15
            onClicked: removeRequested(modelData)

            Rectangle {
                anchors.fill: parent
                color: appWindow.stringToColor(modelData)
                opacity: Theme.opacityFaint
                radius: 15
            }

            Label {
                id: tagLabel
                width: Math.min(implicitWidth, root.width -
                                tagRemove.width)
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: Theme.paddingMedium
                text: modelData
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
            }

            IconButton {
                id: tagRemove
                anchors {
                    left: tagLabel.right
                    verticalCenter: parent.verticalCenter
                }

                Binding on highlighted {
                    when: item.highlighted
                    value: true
                }

                width: Theme.iconSizeSmallPlus + Theme.paddingSmall
                height: width
                icon.source: "image://theme/icon-splus-clear"
                onClicked: item.clicked(mouse)
            }
        }
    }
}
