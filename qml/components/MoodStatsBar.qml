/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.0
import Sailfish.Silica 1.0

Item {
    id: root

    property int index
    property var values: ([])

    readonly property double percentage: !!values && values.length > index ?
        values[index] : 0

    Layout.maximumWidth: parent.width / 2
    Layout.minimumWidth: parent.width / 4
    Layout.fillWidth: true

    height: Theme.paddingMedium

    Rectangle {
        width: parent.width / 100 * percentage
        height: parent.height
        radius: 100
        color: Theme.rgba(Theme.highlightColor, Math.min(1.0, Math.max(0.6, (percentage * 2) / 100)))

        Behavior on width {
            SmoothedAnimation { duration: 80 }
        }
    }
}
