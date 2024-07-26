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

    Layout.preferredWidth: parent.width / 4
    Layout.minimumWidth: implicitWidth
    Layout.maximumWidth: parent.width / 3
    Layout.fillWidth: true

    wrapMode: Text.Wrap
    font.pixelSize: Theme.fontSizeSmall
    color: Theme.secondaryHighlightColor
    horizontalAlignment: Text.AlignRight

    text: appWindow.moodTexts[index]
}
