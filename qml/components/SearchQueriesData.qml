/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import SortFilterProxyModel 0.2

// Requires appWindow.moodTexts

QtObject {
    id: root

    property bool matchAllMode: true
    property string text
    property int textMatchMode
    property date dateMin: dateMinUnset
    property date dateMax: dateMaxUnset
    property int bookmark: Qt.PartiallyChecked
    property string tags
    property int moodMin: 0
    property int moodMax: appWindow.moodTexts.length - 1

    readonly property date dateMinUnset: new Date('0000-01-01')
    readonly property date dateMaxUnset: new Date('9999-01-01')
    readonly property bool enableLogging: false

    function _logChange(name) {
        if (!enableLogging) return
        console.log("search query changed:", name, "=", root[name])
    }

    onMatchAllModeChanged: _logChange("matchAllMode")
    onTextChanged: _logChange("text")
    onTextMatchModeChanged: _logChange("textMatchMode")
    onDateMinChanged: _logChange("dateMin")
    onDateMaxChanged: _logChange("dateMax")
    onBookmarkChanged: _logChange("bookmark")
    onTagsChanged: _logChange("tags")
    onMoodMinChanged: _logChange("moodMin")
    onMoodMaxChanged: _logChange("moodMax")
}
