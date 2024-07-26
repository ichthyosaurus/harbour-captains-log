/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2019-2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.2
import Sailfish.Silica 1.0

Column {
    id: root

    property alias title: _titleLabel.text
    property alias titleLabel: _titleLabel
    property bool isOpen: false
    property alias spacing: container.spacing
    property string exclusiveGroup

    readonly property alias titleHeight: viewGroup.height
    default property alias contentItem: container.data

    // used for identification
    property int __isGroupedDrawer

    function open() {
        if (isOpen) return

        openCloseAnimation.enabled = true
        isOpen = true
        openCloseAnimation.enabled = false
    }

    function close() {
        if (!isOpen) return

        openCloseAnimation.enabled = true
        isOpen = false
        openCloseAnimation.enabled = false
    }

    function __updateOpenedStatus(closeOthers) {
        if (!exclusiveGroup || !parent) return
        if (!isOpen) return

        for (var sibling in parent.children) {
            sibling = parent.children[sibling]

            if (sibling === root) continue
            if (!sibling.hasOwnProperty("__isGroupedDrawer")) continue

            if (closeOthers && sibling.isOpen === true) {
                sibling.isOpen = false
            }

            if (sibling.isOpen === true) {
                isOpen = false
            } else {
                sibling.__updateOpenedStatus()
            }
        }
    }

    onIsOpenChanged: {
        __updateOpenedStatus(isOpen)
    }

    onExclusiveGroupChanged: {
        __updateOpenedStatus()
    }

    width: parent.width
    height: isOpen ? (Theme.paddingMedium
                      + titleHeight
                      + container.height
                      + Theme.paddingLarge)
                   : titleHeight
    clip: true

    opacity: enabled ? 1.0 : Theme.opacityLow

    Behavior on height {
        id: openCloseAnimation
        enabled: false

        SmoothedAnimation {
            reversingMode: SmoothedAnimation.Eased
            duration: 100
        }
    }

    BackgroundItem {
        id: viewGroup
        width: parent.width
        height: Theme.itemSizeSmall
        onClicked: isOpen ? close() : open()

        Label {
            id: _titleLabel
            anchors {
                left: parent.left
                leftMargin: Theme.horizontalPageMargin
                right: moreImage.left
                rightMargin: Theme.paddingMedium
                verticalCenter: parent.verticalCenter
            }

            text: " "
            font.pixelSize: Theme.fontSizeLarge
            truncationMode: TruncationMode.Fade
        }

        HighlightImage {
            id: moreImage
            anchors {
                right: parent.right
                rightMargin: Screen.sizeCategory > Screen.Medium ? Theme.horizontalPageMargin : Theme.paddingMedium
                verticalCenter: parent.verticalCenter
            }

            source: "image://theme/icon-m-right"
            color: Theme.primaryColor
            transformOrigin: Item.Center
            rotation: isOpen ? 90 : 0

            Behavior on rotation {
                NumberAnimation { duration: 80 }
            }
        }

        Rectangle {
            anchors.fill: parent
            z: -1 // behind everything
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.15) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    Item {
        // top spacing
        width: parent.width
        height: Theme.paddingMedium
    }

    Column {
        id: container
        width: parent.width
        height: childrenRect.height
        opacity: isOpen ? 1.0 : 0.0

        Behavior on opacity { FadeAnimator { } }
    }

    Component.onCompleted: {
        __updateOpenedStatus()
    }
}
