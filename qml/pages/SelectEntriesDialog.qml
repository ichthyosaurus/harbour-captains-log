/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import io.thp.pyotherside 1.5
import "../components"

Dialog {
    id: root

    property var selected: ([])
    property string _filterQuery
    readonly property int _selectedCount: filteredModel.selectedCount

    allowedOrientations: Orientation.All
    canAccept: _selectedCount > 0

    SearchModel {
        id: filteredModel
        queries: SearchQueriesData {}
    }

    DiaryListView {
        id: listView
        anchors.fill: parent
        model: filteredModel
        showFullEntries: false
        selectable: true

        PullDownMenu {
            flickable: listView
            enabled: !loadingIndicator.running

            MenuItem {
                text: qsTr("Clear selection")
                visible: _selectedCount > 0
                onDelayedClick: {
                    filteredModel.clearCurrent()
                }
            }
            MenuItem {
                text: qsTr("Select all")
                visible: filteredModel.count > 0
                onDelayedClick: {
                    filteredModel.selectAll()
                }
            }
            MenuItem {
                text: listView.showFullEntries ?
                          qsTr("Show previews") :
                          qsTr("Show full entries")
                onDelayedClick: {
                    listView.showFullEntries = !listView.showFullEntries
                }
            }
        }

        header: Column {
            height: childrenRect.height
            width: root.width

            DialogHeader {
                acceptText: qsTr("Select %n", "", _selectedCount)
            }

            SearchField {
                onTextChanged: root._filterQuery = text
            }
        }

        ViewPlaceholder {
            enabled: filteredModel.count === 0
            text: qsTr("No entries found")
        }
    }
}
