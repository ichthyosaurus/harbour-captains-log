/*
 * SPDX-FileCopyrightText: 2025 Smooth-E
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: root

    property alias icon: icon

    Icon {
        id: icon

        anchors {
            centerIn: parent
            verticalCenterOffset: -Theme.fontSizeExtraSmall / 3
        }

        highlighted: parent.highlighted
        color: Theme.primaryColor
    }
}
