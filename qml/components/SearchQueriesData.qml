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
    property string text: ''
    property int textMatchSyntax: RegExpFilter.FixedString
    property int textMatchMode: matchSimplified
    property date dateMin: dateMinUnset
    property date dateMax: dateMaxUnset
    property int bookmark: Qt.PartiallyChecked
    property int selected: Qt.PartiallyChecked
    property var tags: ([])
    property var tagsNormalized: ([])
    property int moodMin: 0
    property int moodMax: appWindow.moodTexts.length - 1

    readonly property int matchSimplified: 0
    readonly property int matchStrict: 1
    readonly property date dateMinUnset: new Date('0000-01-01')
    readonly property date dateMaxUnset: new Date('9999-01-01')
    readonly property bool enableLogging: false

    function _logChange(name) {
        if (!enableLogging) return
        console.log("search query changed:", name, "=", root[name])
    }

    onMatchAllModeChanged: _logChange("matchAllMode")
    onTextChanged: _logChange("text")
    onTextMatchSyntaxChanged: _logChange("textMatchSyntax")
    onTextMatchModeChanged: _logChange("textMatchMode")
    onDateMinChanged: _logChange("dateMin")
    onDateMaxChanged: _logChange("dateMax")
    onBookmarkChanged: _logChange("bookmark")
    onSelectedChanged: _logChange("selected")
    onTagsChanged: _logChange("tags")
    onTagsNormalizedChanged: _logChange("tagsNormalized")
    onMoodMinChanged: _logChange("moodMin")
    onMoodMaxChanged: _logChange("moodMax")
}
