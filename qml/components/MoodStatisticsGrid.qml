/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.0
import Sailfish.Silica 1.0

GridLayout {
    id: root

    property var values: ([])

    x: Theme.horizontalPageMargin
    width: parent.width - 2*x
    columns: 3
    columnSpacing: Theme.paddingMedium
    rowSpacing: Theme.paddingMedium

    MoodStatsText       { index: 0; values: root.values }
    MoodStatsBar        { index: 0; values: root.values }
    MoodStatsPercentage { index: 0; values: root.values }
    MoodStatsText       { index: 1; values: root.values }
    MoodStatsBar        { index: 1; values: root.values }
    MoodStatsPercentage { index: 1; values: root.values }
    MoodStatsText       { index: 2; values: root.values }
    MoodStatsBar        { index: 2; values: root.values }
    MoodStatsPercentage { index: 2; values: root.values }
    MoodStatsText       { index: 3; values: root.values }
    MoodStatsBar        { index: 3; values: root.values }
    MoodStatsPercentage { index: 3; values: root.values }
    MoodStatsText       { index: 4; values: root.values }
    MoodStatsBar        { index: 4; values: root.values }
    MoodStatsPercentage { index: 4; values: root.values }
    MoodStatsText       { index: 5; values: root.values }
    MoodStatsBar        { index: 5; values: root.values }
    MoodStatsPercentage { index: 5; values: root.values }
}
