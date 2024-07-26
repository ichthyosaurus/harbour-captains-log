/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.0
import Sailfish.Silica 1.0

Label {
    id: root

    property int index
    property var values: ([])

    readonly property double percentage: !!values && values.length > index ?
        values[index] : 0

    Layout.preferredWidth: parent.width / 4
    Layout.minimumWidth: implicitWidth
    font.pixelSize: Theme.fontSizeSmall
    color: Theme.highlightColor
    horizontalAlignment: Text.AlignRight

    text: spinner.visible ?
              " " : "%1 %".arg(Number(percentage).toLocaleString(Qt.locale(), "f", 1))

    BusyIndicator {
        id: spinner
        size: BusyIndicatorSize.ExtraSmall
        running: visible
        visible: !values || values.length < index || values.length == 0

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
        }
    }
}
