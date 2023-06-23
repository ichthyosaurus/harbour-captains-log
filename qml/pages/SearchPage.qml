/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

SearchQueryDialog {
    id: root

    acceptDestination: Qt.resolvedUrl("SearchResultsPage.qml")
    acceptDestinationAction: PageStackAction.Push
    acceptDestinationProperties: ({queries: activeQueries})
}
