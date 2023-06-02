/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6

QtObject {
    property string title
    property string text

    property bool placeAtTop: true

    readonly property int __is_info_combo_section: 0
}
